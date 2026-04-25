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
}
