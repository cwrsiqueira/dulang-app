import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ParentalService {
  static const String _legacyPinKey = 'parental_pin';
  static const String _onboardingKey = 'onboarding_done';
  static const String _securePinHashKey = 'parental_pin_hash_v1';
  static const String _securePinSaltKey = 'parental_pin_salt_v1';
  static const _secureStorage = FlutterSecureStorage();

  // Sinaliza que o usuário está na tela de vídeo — resume lock não deve disparar.
  static bool isOnVideoScreen = false;

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> completeOnboarding(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await _savePinSecure(pin);
    // Remove plaintext legacy pin after secure save.
    await prefs.remove(_legacyPinKey);
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> verifyPin(String input) async {
    await _migrateLegacyPinIfNeeded();
    final storedHash = await _secureStorage.read(key: _securePinHashKey);
    final storedSalt = await _secureStorage.read(key: _securePinSaltKey);
    if (storedHash == null || storedSalt == null) {
      return false;
    }
    final inputHash = _hashPin(input, storedSalt);
    return inputHash == storedHash;
  }

  static Future<void> _migrateLegacyPinIfNeeded() async {
    final secureHash = await _secureStorage.read(key: _securePinHashKey);
    if (secureHash != null) return;

    final prefs = await SharedPreferences.getInstance();
    final legacyPin = prefs.getString(_legacyPinKey);
    if (legacyPin == null || legacyPin.isEmpty) return;

    await _savePinSecure(legacyPin);
    await prefs.remove(_legacyPinKey);
  }

  static Future<void> _savePinSecure(String pin) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hashPin(pin, salt);
    await _secureStorage.write(key: _securePinSaltKey, value: salt);
    await _secureStorage.write(key: _securePinHashKey, value: hash);
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt');
    return sha256.convert(bytes).toString();
  }

  /// Replaces PIN after verifying the current one.
  static Future<bool> changePin(String currentPin, String newPin) async {
    final ok = await verifyPin(currentPin);
    if (!ok) return false;
    await _savePinSecure(newPin);
    return true;
  }

  // --- Horário de acesso (mesmo dia, hora local) ---

  static const _kAccessEnabled = 'parental_access_window_enabled_v1';
  static const _kAccessStartHour = 'parental_access_start_hour_v1';
  static const _kAccessEndHour = 'parental_access_end_hour_v1';
  static const _kDailyLimitEnabled = 'parental_daily_limit_enabled_v1';
  static const _kDailyLimitMinutes = 'parental_daily_limit_minutes_v1';
  static const _kUsageDate = 'parental_usage_date_v1';
  static const _kUsageMinutes = 'parental_usage_minutes_used_v1';

  static Future<bool> isAccessWindowEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kAccessEnabled) ?? false;
  }

  static Future<void> setAccessWindowEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAccessEnabled, v);
  }

  static Future<int> accessStartHour() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kAccessStartHour) ?? 8;
  }

  static Future<int> accessEndHour() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kAccessEndHour) ?? 22;
  }

  static Future<void> setAccessWindowHours(int startHour, int endHour) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kAccessStartHour, startHour.clamp(0, 23));
    await p.setInt(_kAccessEndHour, endHour.clamp(0, 23));
  }

  /// When window is enabled, returns false outside [start, end) on the same calendar day.
  static Future<bool> isWithinAllowedAccessHours() async {
    if (!await isAccessWindowEnabled()) return true;
    final start = await accessStartHour();
    final end = await accessEndHour();
    final h = DateTime.now().hour;
    if (start == end) return true;
    if (start < end) {
      return h >= start && h < end;
    }
    // overnight e.g. 22–8
    return h >= start || h < end;
  }

  static Future<bool> isDailyLimitEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kDailyLimitEnabled) ?? false;
  }

  static Future<void> setDailyLimitEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDailyLimitEnabled, v);
  }

  static Future<int> dailyLimitMinutes() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kDailyLimitMinutes) ?? 120;
  }

  static Future<void> setDailyLimitMinutes(int minutes) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kDailyLimitMinutes, minutes.clamp(15, 24 * 60));
  }

  static Future<int> todayUsedMinutes() async {
    final p = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (p.getString(_kUsageDate) != today) {
      await p.setString(_kUsageDate, today);
      await p.setInt(_kUsageMinutes, 0);
      return 0;
    }
    return p.getInt(_kUsageMinutes) ?? 0;
  }

  static Future<void> addUsedMinutes(int delta) async {
    if (delta <= 0) return;
    final p = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (p.getString(_kUsageDate) != today) {
      await p.setString(_kUsageDate, today);
      await p.setInt(_kUsageMinutes, 0);
    }
    final cur = p.getInt(_kUsageMinutes) ?? 0;
    await p.setInt(_kUsageMinutes, cur + delta);
  }

  static Future<bool> isUnderDailyLimit() async {
    if (!await isDailyLimitEnabled()) return true;
    final limit = await dailyLimitMinutes();
    final used = await todayUsedMinutes();
    return used < limit;
  }

  /// `true` se a criança pode assistir (janela e limite diário, quando ativos).
  static Future<bool> isPlaybackAllowed() async {
    return await isWithinAllowedAccessHours() && await isUnderDailyLimit();
  }

  /// Mostra um SnackBar e retorna `true` se o uso está bloqueado (não pode abrir vídeo).
  static Future<bool> warnIfPlaybackBlocked(BuildContext context) async {
    if (await isPlaybackAllowed()) return false;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O Dulang está pausado: horário ou limite de tempo do dia. Um adulto pode ajustar em Ajustes.',
          ),
        ),
      );
    }
    return true;
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  static const _kPendingProfilePicker = 'pending_profile_picker_v1';

  /// Após o primeiro onboarding, a [NavBarPage] abre a seleção de perfil uma vez.
  static Future<void> requestProfilePickerAfterOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPendingProfilePicker, true);
  }

  static Future<bool> consumePendingProfilePicker() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_kPendingProfilePicker) ?? false;
    if (v) {
      await prefs.setBool(_kPendingProfilePicker, false);
    }
    return v;
  }
}
