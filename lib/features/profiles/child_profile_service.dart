import 'dart:convert';

import 'package:flutter/foundation.dart';
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
///
/// Uso atual: nome na Home (`Olá, …`); escolha e edição na tela "Quem está assistindo?".
/// Não separa ainda favoritos, histórico ou recomendação por criança (tudo comum no app).
class ChildProfileService {
  ChildProfileService._();
  static final ChildProfileService instance = ChildProfileService._();

  static const _profilesKey = 'child_profiles_v1';
  static const _activeIdKey = 'child_profile_active_id_v1';

  /// Incrementa após mudar perfil ativo / lista; a Home escuta e atualiza a saudação.
  final ValueNotifier<int> profileChangeCount = ValueNotifier<int>(0);

  void _notifyProfileChanged() {
    profileChangeCount.value = profileChangeCount.value + 1;
  }

  /// Rota "Quem está assistindo?" montada: evita `push` duplicado a partir da [NavBarPage].
  bool _profilePickerRouteOpen = false;
  bool get isProfilePickerRouteOpen => _profilePickerRouteOpen;
  void setProfilePickerRouteOpen(bool value) {
    _profilePickerRouteOpen = value;
  }

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
    _notifyProfileChanged();
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

  /// Ajusta o perfil ativo se a lista tiver itens. **Não** cria perfil sozinho
  /// (evita "Perfil 1" sem o adulto escolher o nome — fluxo estilo Netflix).
  Future<void> syncActiveProfileWithStoredList() async {
    final list = await loadProfiles();
    if (list.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeIdKey);
      _notifyProfileChanged();
      return;
    }
    final active = await activeProfileId();
    if (active == null || !list.any((e) => e.id == active)) {
      await setActiveProfileId(list.first.id);
    } else {
      _notifyProfileChanged();
    }
  }

  /// Cria o perfil, grava, define como **ativo** (para a Home mostrar o nome) e
  /// notifica ouvintes. Retorna o id do novo perfil.
  Future<String> addProfile(String name, int colorValue) async {
    final list = await loadProfiles();
    final id = const Uuid().v4();
    list.add(ChildProfile(
      id: id,
      name: name.trim().isEmpty ? 'Novo perfil' : name.trim(),
      colorValue: colorValue,
    ));
    await saveProfiles(list);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeIdKey, id);
    _notifyProfileChanged();
    return id;
  }

  /// Remove o perfil. Retorna `false` se for o **único** (não exclui; evita app sem criança ativa).
  Future<bool> removeProfile(String id) async {
    var list = await loadProfiles();
    if (list.length <= 1) {
      return false;
    }
    list.removeWhere((p) => p.id == id);
    await saveProfiles(list);
    final active = await activeProfileId();
    if (active == id) {
      await setActiveProfileId(list.first.id);
    } else {
      _notifyProfileChanged();
    }
    return true;
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
    _notifyProfileChanged();
  }
}
