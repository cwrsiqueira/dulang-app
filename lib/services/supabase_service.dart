import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  Future<List<VideoRow>> getVideos() async {
    final data = await client
        .from('videos')
        .select('*, channels(name)')
        .eq('is_active', true);
    final list = data.map((e) => VideoRow.fromJson(e)).toList();
    list.shuffle(Random());
    return list;
  }

  Future<List<VideoRow>> getFavoritos(List<String> videoIds) async {
    if (videoIds.isEmpty) return [];
    final data = await client
        .from('videos')
        .select('*, channels(name)')
        .eq('is_active', true)
        .inFilter('youtube_video_id', videoIds);
    return data.map((e) => VideoRow.fromJson(e)).toList();
  }
}

class VideoRow {
  final String id;
  final String youtubeVideoId;
  final String channelId;
  final String title;
  final String description;
  final String thumbnailDefault;
  final String thumbnailHigh;
  final DateTime? publishedAt;
  final String channelName;

  VideoRow({
    required this.id,
    required this.youtubeVideoId,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnailDefault,
    required this.thumbnailHigh,
    required this.publishedAt,
    required this.channelName,
  });

  factory VideoRow.fromJson(Map<String, dynamic> json) {
    return VideoRow(
      id: json['id'] as String,
      youtubeVideoId: json['youtube_video_id'] as String,
      channelId: json['channel_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailDefault: json['thumbnail_default'] as String? ?? '',
      thumbnailHigh: json['thumbnail_high'] as String? ?? '',
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      channelName: (json['channels'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    );
  }
}
