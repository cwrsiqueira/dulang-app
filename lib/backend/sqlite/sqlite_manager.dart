import 'package:flutter/foundation.dart';

import '/backend/sqlite/init.dart';
import 'queries/read.dart';
import 'queries/update.dart';

import 'package:sqflite/sqflite.dart';
export 'queries/read.dart';
export 'queries/update.dart';

class SQLiteManager {
  SQLiteManager._();

  static SQLiteManager? _instance;
  static SQLiteManager get instance => _instance ??= SQLiteManager._();

  static late Database _database;
  Database get database => _database;

  static Future initialize() async {
    if (kIsWeb) {
      return;
    }
    _database = await initializeDatabaseFromDbFile(
      'videos2024121601',
      'dulang.db',
    );
  }

  /// START READ QUERY CALLS

  Future<List<GetVideosRow>> getVideos() => performGetVideos(
        _database,
      );

  Future<List<GetFavoritosRow>> getFavoritos() => performGetFavoritos(
        _database,
      );

  Future<List<QtVideosRow>> qtVideos() => performQtVideos(
        _database,
      );

  /// END READ QUERY CALLS

  /// START UPDATE QUERY CALLS

  Future deleteVideo({
    String? id,
  }) =>
      performDeleteVideo(
        _database,
        id: id,
      );

  Future toggleFavorito({
    int? id,
    int? isFavorito,
  }) =>
      performToggleFavorito(
        _database,
        id: id,
        isFavorito: isFavorito,
      );

  /// END UPDATE QUERY CALLS
}
