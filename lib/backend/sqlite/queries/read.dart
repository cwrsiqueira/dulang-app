import '/backend/sqlite/queries/sqlite_row.dart';
import 'package:sqflite/sqflite.dart';

Future<List<T>> _readQuery<T>(
  Database database,
  String query,
  T Function(Map<String, dynamic>) create,
) =>
    database.rawQuery(query).then((r) => r.map((e) => create(e)).toList());

/// BEGIN GETVIDEOS
Future<List<GetVideosRow>> performGetVideos(
  Database database,
) {
  final query = '''
SELECT * FROM videos ORDER BY RANDOM();
''';
  return _readQuery(database, query, (d) => GetVideosRow(d));
}

class GetVideosRow extends SqliteRow {
  GetVideosRow(Map<String, dynamic> data) : super(data);

  String get videoId => data['video_id'] as String;
  String get datetime => data['datetime'] as String;
  String get channelTitle => data['channel_title'] as String;
  String get title => data['title'] as String;
  String get description => data['description'] as String;
  String get thumbnailDefault => data['thumbnail_default'] as String;
  String get thumbnailHigh => data['thumbnail_high'] as String;
  DateTime get createdAt => data['created_at'] as DateTime;
  int get id => data['id'] as int;
  int? get isFavorito => data['is_favorito'] as int?;
}

/// END GETVIDEOS

/// BEGIN GETFAVORITOS
Future<List<GetFavoritosRow>> performGetFavoritos(
  Database database,
) {
  final query = '''
SELECT * FROM videos WHERE is_favorito = 1 ORDER BY RANDOM();
''';
  return _readQuery(database, query, (d) => GetFavoritosRow(d));
}

class GetFavoritosRow extends SqliteRow {
  GetFavoritosRow(Map<String, dynamic> data) : super(data);

  String get videoId => data['video_id'] as String;
  DateTime get datetime => data['datetime'] as DateTime;
  String get channelTitle => data['channel_title'] as String;
  String get title => data['title'] as String;
  String get description => data['description'] as String;
  String get thumbnailDefault => data['thumbnail_default'] as String;
  String get thumbnailHigh => data['thumbnail_high'] as String;
  DateTime get createdAt => data['created_at'] as DateTime;
  int get id => data['id'] as int;
  bool get isFavorito => data['is_favorito'] as bool;
}

/// END GETFAVORITOS

/// BEGIN QTVIDEOS
Future<List<QtVideosRow>> performQtVideos(
  Database database,
) {
  final query = '''
SELECT sum(*) as qtVideos FROM videos
''';
  return _readQuery(database, query, (d) => QtVideosRow(d));
}

class QtVideosRow extends SqliteRow {
  QtVideosRow(Map<String, dynamic> data) : super(data);

  int get qtVideos => data['qtVideos'] as int;
}

/// END QTVIDEOS
