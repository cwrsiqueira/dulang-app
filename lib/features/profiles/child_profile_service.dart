import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChildProfile {
  ChildProfile({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': colorValue,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Perfil',
      colorValue: json['color'] as int? ?? 0xFF36B4FF,
    );
  }
}

/// Local child profiles (multiple kids); no server sync in v1.
class ChildProfileService {
  ChildProfileService._();
  static final ChildProfileService instance = ChildProfileService._();

  static const _profilesKey = 'child_profiles_v1';
  static const _activeIdKey = 'child_profile_active_id_v1';

  Future<List<ChildProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChildProfile.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfiles(List<ChildProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  Future<String?> activeProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeIdKey);
  }

  Future<void> setActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeIdKey, id);
  }

  Future<ChildProfile?> activeProfile() async {
    final id = await activeProfileId();
    if (id == null) return null;
    final all = await loadProfiles();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> ensureDefaultProfile() async {
    var list = await loadProfiles();
    if (list.isEmpty) {
      final p = ChildProfile(
        id: const Uuid().v4(),
        name: 'Perfil 1',
        colorValue: 0xFFFFA130,
      );
      list = [p];
      await saveProfiles(list);
      await setActiveProfileId(p.id);
      return;
    }
    final active = await activeProfileId();
    if (active == null || !list.any((e) => e.id == active)) {
      await setActiveProfileId(list.first.id);
    }
  }

  Future<void> addProfile(String name, int colorValue) async {
    final list = await loadProfiles();
    list.add(ChildProfile(
      id: const Uuid().v4(),
      name: name.trim().isEmpty ? 'Novo perfil' : name.trim(),
      colorValue: colorValue,
    ));
    await saveProfiles(list);
  }

  Future<void> removeProfile(String id) async {
    var list = await loadProfiles();
    list.removeWhere((p) => p.id == id);
    if (list.isEmpty) {
      await saveProfiles([]);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeIdKey);
      await ensureDefaultProfile();
      return;
    }
    await saveProfiles(list);
    final active = await activeProfileId();
    if (active == id) {
      await setActiveProfileId(list.first.id);
    }
  }

  Future<void> renameProfile(String id, String name) async {
    final list = await loadProfiles();
    final i = list.indexWhere((p) => p.id == id);
    if (i < 0) return;
    list[i] = ChildProfile(
      id: list[i].id,
      name: name.trim().isEmpty ? list[i].name : name.trim(),
      colorValue: list[i].colorValue,
    );
    await saveProfiles(list);
  }
}
