import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

/// Limite de itens persistidos. Ordem: mais recente no indice 0 (MRU); o excedente
/// remove os itens mais antigos (fim da lista).
const int kMaxHistoryEntries = 100;
const int kMaxFavorites = 60;

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _history = prefs.getStringList('ff_history')?.map((x) {
            try {
              return jsonDecode(x);
            } catch (e) {
              print("Can't decode persisted json. Error: $e.");
              return {};
            }
          }).toList() ??
          _history;
    });
    _safeInit(() {
      _favorites = prefs.getStringList('ff_favorites')?.map((x) {
            try {
              return jsonDecode(x);
            } catch (e) {
              print("Can't decode persisted json. Error: $e.");
              return {};
            }
          }).toList() ??
          _favorites;
    });
    _applyPersistedListCapsIfNeeded();
  }

  void _applyPersistedListCapsIfNeeded() {
    var changed = false;
    if (_history.length > kMaxHistoryEntries) {
      _history = _history.sublist(0, kMaxHistoryEntries);
      changed = true;
    }
    if (_favorites.length > kMaxFavorites) {
      _favorites = _favorites.sublist(0, kMaxFavorites);
      changed = true;
    }
    if (changed) {
      prefs.setStringList(
        'ff_history',
        _history.map((x) => jsonEncode(x)).toList(),
      );
      prefs.setStringList(
        'ff_favorites',
        _favorites.map((x) => jsonEncode(x)).toList(),
      );
    }
  }

  void _capHistoryRecencyNewestFirst() {
    if (_history.length > kMaxHistoryEntries) {
      _history = _history.sublist(0, kMaxHistoryEntries);
    }
  }

  void _capHistoryAppendedRemoveOldest() {
    while (_history.length > kMaxHistoryEntries) {
      _history.removeAt(0);
    }
  }

  void _capFavoritesRecencyNewestFirst() {
    if (_favorites.length > kMaxFavorites) {
      _favorites = _favorites.sublist(0, kMaxFavorites);
    }
  }

  void _capFavoritesAppendedRemoveOldest() {
    while (_favorites.length > kMaxFavorites) {
      _favorites.removeAt(0);
    }
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<dynamic> _history = [];
  List<dynamic> get history => _history;
  set history(List<dynamic> value) {
    _history = value;
    _capHistoryRecencyNewestFirst();
    prefs.setStringList(
        'ff_history', _history.map((x) => jsonEncode(x)).toList());
  }

  void addToHistory(dynamic value) {
    _history.add(value);
    _capHistoryAppendedRemoveOldest();
    prefs.setStringList(
        'ff_history', _history.map((x) => jsonEncode(x)).toList());
  }

  void removeFromHistory(dynamic value) {
    history.remove(value);
    prefs.setStringList(
        'ff_history', _history.map((x) => jsonEncode(x)).toList());
  }

  void removeAtIndexFromHistory(int index) {
    history.removeAt(index);
    prefs.setStringList(
        'ff_history', _history.map((x) => jsonEncode(x)).toList());
  }

  void updateHistoryAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    history[index] = updateFn(_history[index]);
    prefs.setStringList(
        'ff_history', _history.map((x) => jsonEncode(x)).toList());
  }

  void insertAtIndexInHistory(int index, dynamic value) {
    _history.insert(index, value);
    _capHistoryRecencyNewestFirst();
    prefs.setStringList(
        'ff_history', _history.map((x) => jsonEncode(x)).toList());
  }

  List<dynamic> _favorites = [];
  List<dynamic> get favorites => _favorites;
  set favorites(List<dynamic> value) {
    _favorites = value;
    _capFavoritesRecencyNewestFirst();
    prefs.setStringList(
        'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
  }

  void addToFavorites(dynamic value) {
    _favorites.add(value);
    _capFavoritesAppendedRemoveOldest();
    prefs.setStringList(
        'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
  }

  void removeFromFavorites(dynamic value) {
    favorites.remove(value);
    prefs.setStringList(
        'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
  }

  void removeAtIndexFromFavorites(int index) {
    favorites.removeAt(index);
    prefs.setStringList(
        'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
  }

  void updateFavoritesAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    favorites[index] = updateFn(_favorites[index]);
    prefs.setStringList(
        'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
  }

  void insertAtIndexInFavorites(int index, dynamic value) {
    _favorites.insert(index, value);
    _capFavoritesRecencyNewestFirst();
    prefs.setStringList(
        'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
  }

  String? _youtubeIdOf(dynamic e) {
    if (e is! Map) return null;
    final m = Map<String, dynamic>.from(e);
    return m['youtube_video_id'] as String?;
  }

  void addOrUpdateHistoryEntry(Map<String, dynamic> engagement) {
    update(() {
      final id = engagement['youtube_video_id'] as String?;
      if (id == null || id.isEmpty) return;
      _history.removeWhere((e) => _youtubeIdOf(e) == id);
      _history.insert(0, engagement);
      _capHistoryRecencyNewestFirst();
      prefs.setStringList(
          'ff_history', _history.map((x) => jsonEncode(x)).toList());
    });
  }

  bool isFavoriteVideoId(String youtubeVideoId) {
    return _favorites.any((e) => _youtubeIdOf(e) == youtubeVideoId);
  }

  void toggleFavoriteEntry(Map<String, dynamic> engagement) {
    final id = engagement['youtube_video_id'] as String?;
    if (id == null || id.isEmpty) return;
    update(() {
      final exists = _favorites.any((e) => _youtubeIdOf(e) == id);
      if (exists) {
        _favorites.removeWhere((e) => _youtubeIdOf(e) == id);
      } else {
        _favorites.insert(0, engagement);
        _capFavoritesRecencyNewestFirst();
      }
      prefs.setStringList(
          'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
    });
  }

  void removeFavoriteByVideoId(String youtubeVideoId) {
    update(() {
      _favorites.removeWhere((e) => _youtubeIdOf(e) == youtubeVideoId);
      prefs.setStringList(
          'ff_favorites', _favorites.map((x) => jsonEncode(x)).toList());
    });
  }

  void clearHistory() {
    update(() {
      _history = [];
      prefs.setStringList('ff_history', []);
    });
  }

  void clearFavorites() {
    update(() {
      _favorites = [];
      prefs.setStringList('ff_favorites', []);
    });
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

