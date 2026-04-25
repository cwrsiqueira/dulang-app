import 'package:shared_preferences/shared_preferences.dart';

class ParentalService {
  static const String _pinKey = 'parental_pin';
  static const String _onboardingKey = 'onboarding_done';

  // Sinaliza que o usuário está na tela de vídeo — resume lock não deve disparar.
  static bool isOnVideoScreen = false;

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> completeOnboarding(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  static Future<bool> verifyPin(String input) async {
    final pin = await getPin();
    return pin != null && pin == input;
  }
}
