import 'package:sqflite/sqflite.dart';

/// BEGIN DELETEVIDEO
Future performDeleteVideo(
  Database database, {
  String? id,
}) {
  final query = '''
DELETE FROM videos WHERE id = ${id}
''';
  return database.rawQuery(query);
}

/// END DELETEVIDEO

/// BEGIN TOGGLEFAVORITO
Future performToggleFavorito(
  Database database, {
  int? id,
  int? isFavorito,
}) {
  final query = '''
UPDATE videos SET is_favorito = ${isFavorito} WHERE id = ${id}
''';
  return database.rawQuery(query);
}

/// END TOGGLEFAVORITO
