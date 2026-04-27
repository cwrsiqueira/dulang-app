import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  Future<List<VideoRow>> getVideos() async {
    final data = await _withRetry(
      () => client
          .from('videos')
          .select('*, channels(name)')
          .eq('is_active', true)
          .timeout(const Duration(seconds: 8)),
    );
    final list = data.map((e) => VideoRow.fromJson(e)).toList();
    list.shuffle(Random());
    return list;
  }

  Future<List<VideoRow>> getFavoritos(List<String> videoIds) async {
    if (videoIds.isEmpty) return [];
    final data = await _withRetry(
      () => client
          .from('videos')
          .select('*, channels(name)')
          .eq('is_active', true)
          .inFilter('youtube_video_id', videoIds)
          .timeout(const Duration(seconds: 8)),
    );
    return data.map((e) => VideoRow.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> _withRetry(
    Future<List<Map<String, dynamic>>> Function() op,
  ) async {
    try {
      return await op();
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      try {
        return await op();
      } catch (_) {
        throw const CatalogUnavailableException();
      }
    }
  }
}

class CatalogUnavailableException implements Exception {
  const CatalogUnavailableException();

  @override
  String toString() {
    return 'Não foi possível carregar o catálogo agora. Verifique a internet e tente novamente.';
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

  /// Map for [FFAppState] favorites/history persistence.
  Map<String, dynamic> toEngagementMap() {
    return {
      'youtube_video_id': youtubeVideoId,
      'title': title,
      'thumbnail_high': thumbnailHigh,
      'thumbnail_default': thumbnailDefault,
      'channel_name': channelName,
      'at': DateTime.now().toIso8601String(),
    };
  }

  static VideoRow? fromEngagementMap(Map<String, dynamic> m) {
    final vid = m['youtube_video_id'] as String?;
    if (vid == null || vid.isEmpty) return null;
    return VideoRow(
      id: m['id'] as String? ?? vid,
      youtubeVideoId: vid,
      channelId: m['channel_id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      description: '',
      thumbnailDefault: m['thumbnail_default'] as String? ?? '',
      thumbnailHigh: m['thumbnail_high'] as String? ?? '',
      publishedAt: null,
      channelName: m['channel_name'] as String? ?? '',
    );
  }

  /// URL para exibição: usa thumb salva ou padrão do YouTube pelo id.
  String get displayThumbnailUrl {
    final t = thumbnailHigh.trim();
    if (t.isNotEmpty) return t;
    final d = thumbnailDefault.trim();
    if (d.isNotEmpty) return d;
    final id = youtubeVideoId.trim();
    if (id.isEmpty) return '';
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  String get displayTitle {
    final t = title.trim();
    if (t.isNotEmpty) return t;
    return 'Vídeo';
  }

  String get displayChannelLabel {
    final c = channelName.trim();
    if (c.isNotEmpty) return c;
    return 'Dulang';
  }
}
