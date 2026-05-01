import '/features/subscription/freemium_service.dart';
import '/features/subscription/premium_paywall_redirect.dart';
import '/features/subscription/subscription_service.dart';
import '/services/supabase_service.dart';
import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_youtube_player.dart';
import '/pages/dulang_premium/dulang_premium_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dulang_video_model.dart';
export 'dulang_video_model.dart';

class DulangVideoWidget extends StatefulWidget {
  const DulangVideoWidget({
    super.key,
    required this.url,
  });

  final String? url;

  static String routeName = 'DulangVideo';
  static String routePath = '/dulangVideo';

  @override
  State<DulangVideoWidget> createState() => _DulangVideoWidgetState();
}

class _DulangVideoWidgetState extends State<DulangVideoWidget>
    with WidgetsBindingObserver {
  late DulangVideoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final Future<List<VideoRow>> _videosFuture;
  bool _historyRecorded = false;

  Future<void> _onInPlayerVideoSelected(String videoId) async {
    if (!mounted) return;
    if (videoId.isEmpty) return;
    if (await ParentalService.warnIfPlaybackBlocked(context)) return;
    if (!mounted) return;
    if (!SubscriptionService.instance.hasPremiumAccess && !FreemiumService.instance.isEnrolled) {
      await context.pushNamed(DulangPremiumWidget.routeName);
      return;
    }

    context.goNamed(
      DulangVideoWidget.routeName,
      queryParameters: {
        'url': serializeParam(
          videoId,
          ParamType.String,
        ),
      }.withoutNulls,
    );
  }

  Future<void> _enforcePlaybackIfNeeded() async {
    if (!mounted) return;
    if (await ParentalService.isPlaybackAllowed()) return;
    if (mounted) context.go('/');
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DulangVideoModel());
    _videosFuture = SupabaseService.instance.getVideos();
    WidgetsBinding.instance.addObserver(this);
    ParentalService.isOnVideoScreen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enforcePlaybackIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ParentalService.isOnVideoScreen = false;
    _model.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ParentalService.isOnVideoScreen = true;
      _enforcePlaybackIfNeeded();
    }
  }

  /// Lista vertical de carrosséis, um por canal (como na Home).
  Widget _buildChannelCarousels(
    BuildContext context,
    List<VideoRow> videos,
  ) {
    final byChannel = <String, List<VideoRow>>{};
    for (final v in videos) {
      final key =
          v.channelName.trim().isEmpty ? 'Dulang' : v.channelName.trim();
      byChannel.putIfAbsent(key, () => []).add(v);
    }
    final names = byChannel.keys.toList()..sort();
    final thumbWidth = MediaQuery.sizeOf(context).width * 0.42;
    final children = <Widget>[];
    for (final name in names) {
      final list = byChannel[name]!;
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 8));
      }
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.readexPro(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ],
          ),
        ),
      );
      children.add(
        SizedBox(
          height: 210,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final videoItem = list[i];
              return _VideoRailCard(
                width: thumbWidth,
                video: videoItem,
                onTap: () async {
                  if (await ParentalService.warnIfPlaybackBlocked(context)) {
                    return;
                  }
                  if (!context.mounted) return;
                  if (!SubscriptionService.instance.hasPremiumAccess && !FreemiumService.instance.isEnrolled) {
                    await context.pushNamed(DulangPremiumWidget.routeName);
                    return;
                  }
                  if (!context.mounted) return;
                  context.goNamed(
                    DulangVideoWidget.routeName,
                    queryParameters: {
                      'url': serializeParam(
                        videoItem.youtubeVideoId,
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                },
              );
            },
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!SubscriptionService.instance.hasPremiumAccess && !FreemiumService.instance.isEnrolled) {
      return const PremiumPaywallRedirectScaffold();
    }

    return FutureBuilder<List<VideoRow>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final videos = snapshot.data!;
        final url = widget.url;
        if (!_historyRecorded && url != null && url.isNotEmpty) {
          _historyRecorded = true;
          VideoRow? current;
          for (final v in videos) {
            if (v.youtubeVideoId == url) {
              current = v;
              break;
            }
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final app = context.read<FFAppState>();
            if (current != null) {
              app.addOrUpdateHistoryEntry(current.toEngagementMap());
            } else {
              app.addOrUpdateHistoryEntry({
                'youtube_video_id': url,
                'title': 'Vídeo',
                'thumbnail_high': '',
                'thumbnail_default': '',
                'channel_name': '',
                'at': DateTime.now().toIso8601String(),
              });
            }
          });
        }

        return YoutubeFullScreenWrapper(
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              // Pop normal: volta ao feed sem pedir PIN.
              context.safePop();
            },
            child: Scaffold(
                key: scaffoldKey,
                appBar: responsiveVisibility(
                              context: context,
                              tabletLandscape: false,
                            ) &&
                            (MediaQuery.sizeOf(context).width > kBreakpointSmall
                                ? false
                                : true)
                    ? AppBar(
                        backgroundColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        automaticallyImplyLeading: false,
                        leading: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 60.0,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 30.0,
                          ),
                          onPressed: () => context.safePop(),
                        ),
                        actions: [
                          if (widget.url != null && widget.url!.isNotEmpty)
                            Consumer<FFAppState>(
                              builder: (context, app, _) {
                                final fav = app.isFavoriteVideoId(widget.url!);
                                return IconButton(
                                  icon: Icon(
                                    fav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: fav
                                        ? FlutterFlowTheme.of(context).tertiary
                                        : FlutterFlowTheme.of(context).primaryText,
                                  ),
                                  onPressed: () {
                                    VideoRow? row;
                                    for (final v in videos) {
                                      if (v.youtubeVideoId == widget.url) {
                                        row = v;
                                        break;
                                      }
                                    }
                                    if (row != null) {
                                      app.toggleFavoriteEntry(row.toEngagementMap());
                                    } else {
                                      app.toggleFavoriteEntry({
                                        'youtube_video_id': widget.url!,
                                        'title': 'Vídeo',
                                        'thumbnail_high': '',
                                        'thumbnail_default': '',
                                        'channel_name': '',
                                        'at': DateTime.now().toIso8601String(),
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          title: Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: Text(
                                '',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .headlineMedium
                                                .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 22.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          background: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/dulang1_bgtransparent.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          centerTitle: true,
                          expandedTitleScale: 1.0,
                        ),
                        elevation: 2.0,
                      )
                    : null,
                body: SafeArea(
                  top: true,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Material(
                            color: Colors.transparent,
                            elevation: 2.0,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: FlutterFlowYoutubePlayer(
                                url: widget.url!,
                                width: double.infinity,
                                height: double.infinity,
                                autoPlay: true,
                                looping: true,
                                mute: false,
                                showControls: false,
                                showFullScreen: true,
                                strictRelatedVideos: true,
                                onVideoIdChanged: _onInPlayerVideoSelected,
                              ),
                            ),
                          ),
                        ),
                        if ((MediaQuery.sizeOf(context).width > kBreakpointSmall
                                ? false
                                : true) &&
                            responsiveVisibility(
                              context: context,
                              tabletLandscape: false,
                            ))
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: const BoxDecoration(),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _buildChannelCarousels(context, videos),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ),
        );
      },
    );
  }
}

class _VideoRailCard extends StatelessWidget {
  const _VideoRailCard({
    required this.width,
    required this.video,
    required this.onTap,
  });

  final double width;
  final VideoRow video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  video.displayThumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade800,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 40,
                      color: FlutterFlowTheme.of(context).tertiary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.readexPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
