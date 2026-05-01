import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia o estado do plano gratuito (1h/dia, vitalício).
/// Separado do ParentalService para não misturar controle de negócio com controle parental.
class FreemiumService extends ChangeNotifier {
  FreemiumService._();
  static final FreemiumService instance = FreemiumService._();

  static const int dailyLimitMinutes = 60;

  static const _kEnrolled = 'free_plan_enrolled_v1';
  static const _kEmail = 'free_plan_email_v1';
  static const _kUsageDate = 'free_usage_date_v1';
  static const _kUsageMinutes = 'free_usage_minutes_v1';

  bool _enrolled = false;

  /// `true` se o usuário escolheu o plano gratuito neste aparelho.
  bool get isEnrolled => _enrolled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enrolled = prefs.getBool(_kEnrolled) ?? false;
  }

  Future<void> enroll(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, email.trim().toLowerCase());
    await prefs.setBool(_kEnrolled, true);
    _enrolled = true;
    notifyListeners();
  }

  Future<String?> enrolledEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail);
  }

  Future<int> todayUsedMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (prefs.getString(_kUsageDate) != today) {
      await prefs.setString(_kUsageDate, today);
      await prefs.setInt(_kUsageMinutes, 0);
      return 0;
    }
    return prefs.getInt(_kUsageMinutes) ?? 0;
  }

  Future<void> addUsedMinutes(int delta) async {
    if (delta <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (prefs.getString(_kUsageDate) != today) {
      await prefs.setString(_kUsageDate, today);
      await prefs.setInt(_kUsageMinutes, 0);
    }
    final cur = prefs.getInt(_kUsageMinutes) ?? 0;
    await prefs.setInt(_kUsageMinutes, cur + delta);
  }

  Future<bool> isUnderDailyLimit() async {
    final used = await todayUsedMinutes();
    return used < dailyLimitMinutes;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEnrolled);
    await prefs.remove(_kEmail);
    await prefs.remove(_kUsageDate);
    await prefs.remove(_kUsageMinutes);
    _enrolled = false;
    notifyListeners();
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
