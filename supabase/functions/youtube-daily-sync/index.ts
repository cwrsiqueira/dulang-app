import { createClient } from "npm:@supabase/supabase-js@2";

type ChannelRow = {
  id: string;
  name: string;
  youtube_channel_id: string;
};

type SyncRunRow = {
  id: number;
};

const YT_BASE = "https://www.googleapis.com/youtube/v3";
const INCREMENTAL_MAX_PER_CHANNEL = 20;
const STALE_INTERVAL = "36 hours";
const RETENTION_INTERVAL = "90 days";

function getEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value || !value.trim()) {
    throw new Error(`Missing required env var: ${name}`);
  }
  return value;
}

async function fetchJson(url: string) {
  const res = await fetch(url);
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`YouTube API error ${res.status}: ${body}`);
  }
  return await res.json();
}

function toIsoOrNull(input?: string): string | null {
  if (!input) return null;
  const d = new Date(input);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

Deno.serve(async () => {
  try {
    const supabaseUrl = getEnv("SUPABASE_URL");
    const supabaseServiceRoleKey = getEnv("SUPABASE_SERVICE_ROLE_KEY");
    const youtubeApiKey = getEnv("YOUTUBE_API_KEY");

    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    const runStart = new Date().toISOString();
    const { data: runData, error: runErr } = await supabase
      .from("sync_runs")
      .insert({ source: "youtube_daily_sync", status: "running" })
      .select("id")
      .single<SyncRunRow>();
    if (runErr || !runData) throw new Error(`sync_runs start failed: ${runErr?.message}`);

    let channelsProcessed = 0;
    let videosInserted = 0;
    let videosUpdated = 0;
    let errorCount = 0;

    const { data: channels, error: channelsErr } = await supabase
      .from("channels")
      .select("id, name, youtube_channel_id")
      .eq("active", true);
    if (channelsErr) throw new Error(`channels query failed: ${channelsErr.message}`);

    for (const channel of (channels ?? []) as ChannelRow[]) {
      try {
        const searchUrl =
          `${YT_BASE}/search?part=id,snippet` +
          `&channelId=${encodeURIComponent(channel.youtube_channel_id)}` +
          `&maxResults=${INCREMENTAL_MAX_PER_CHANNEL}` +
          `&order=date&type=video&key=${encodeURIComponent(youtubeApiKey)}`;
        const search = await fetchJson(searchUrl);
        const ids: string[] = (search.items ?? [])
          .map((item: any) => item?.id?.videoId as string | undefined)
          .filter((id: string | undefined): id is string => Boolean(id));

        if (ids.length === 0) {
          await supabase
            .from("channels")
            .update({
              last_synced_at: runStart,
              last_sync_status: "ok",
              last_sync_error: null,
            })
            .eq("id", channel.id);
          channelsProcessed += 1;
          continue;
        }

        const videosUrl =
          `${YT_BASE}/videos?part=snippet,status` +
          `&id=${encodeURIComponent(ids.join(","))}` +
          `&key=${encodeURIComponent(youtubeApiKey)}`;
        const details = await fetchJson(videosUrl);

        const rows = (details.items ?? []).map((item: any) => {
          const snippet = item?.snippet ?? {};
          const status = item?.status ?? {};
          const thumbs = snippet?.thumbnails ?? {};
          const high = thumbs?.high?.url ?? thumbs?.medium?.url ?? thumbs?.default?.url ?? "";
          const basic = thumbs?.default?.url ?? high ?? "";
          const privacy = status?.privacyStatus as string | undefined;
          const upload = status?.uploadStatus as string | undefined;
          const active = privacy === "public" && upload === "processed";

          return {
            youtube_video_id: item.id as string,
            channel_id: channel.id,
            title: (snippet?.title as string | undefined) ?? "",
            description: (snippet?.description as string | undefined) ?? "",
            thumbnail_default: basic,
            thumbnail_high: high,
            published_at: toIsoOrNull(snippet?.publishedAt as string | undefined),
            is_active: active,
            last_seen_at: runStart,
            last_checked_at: runStart,
            unavailable_reason: active ? null : `${privacy ?? "unknown"}:${upload ?? "unknown"}`,
            deactivated_at: active ? null : runStart,
          };
        });

        const youtubeIds = rows.map((r: any) => r.youtube_video_id);
        const { data: existingRows, error: existingErr } = await supabase
          .from("videos")
          .select("youtube_video_id")
          .in("youtube_video_id", youtubeIds);
        if (existingErr) throw new Error(`videos precheck failed: ${existingErr.message}`);
        const existingSet = new Set((existingRows ?? []).map((r: any) => r.youtube_video_id));

        const { data: upserted, error: upsertErr } = await supabase
          .from("videos")
          .upsert(rows, { onConflict: "youtube_video_id" })
          .select("youtube_video_id");
        if (upsertErr) throw new Error(`videos upsert failed: ${upsertErr.message}`);

        for (const id of youtubeIds) {
          if (existingSet.has(id)) {
            videosUpdated += 1;
          } else {
            videosInserted += 1;
          }
        }

        await supabase
          .from("channels")
          .update({
            last_synced_at: runStart,
            last_sync_status: "ok",
            last_sync_error: null,
          })
          .eq("id", channel.id);
        channelsProcessed += 1;
      } catch (channelErr) {
        errorCount += 1;
        await supabase
          .from("channels")
          .update({
            last_synced_at: runStart,
            last_sync_status: "error",
            last_sync_error: String(channelErr),
          })
          .eq("id", channel.id);
      }
    }

    const { data: inactivatedData, error: inactivatedErr } = await supabase.rpc(
      "mark_stale_videos_inactive",
      { p_stale_interval: STALE_INTERVAL },
    );
    if (inactivatedErr) throw new Error(`mark stale failed: ${inactivatedErr.message}`);
    const videosInactivated = Number(inactivatedData ?? 0);

    const { error: purgeErr } = await supabase.rpc("purge_inactive_videos", {
      p_retention: RETENTION_INTERVAL,
    });
    if (purgeErr) throw new Error(`purge inactive failed: ${purgeErr.message}`);

    await supabase
      .from("sync_runs")
      .update({
        finished_at: new Date().toISOString(),
        status: errorCount > 0 ? "partial" : "ok",
        channels_processed: channelsProcessed,
        videos_inserted: videosInserted,
        videos_updated: videosUpdated,
        videos_inactivated: videosInactivated,
        error_count: errorCount,
        notes: "daily sync completed",
      })
      .eq("id", runData.id);

    return new Response(
      JSON.stringify({
        ok: true,
        channelsProcessed,
        videosInserted,
        videosUpdated,
        videosInactivated,
        errorCount,
      }),
      { headers: { "content-type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ ok: false, error: String(err) }),
      { status: 500, headers: { "content-type": "application/json" } },
    );
  }
});
