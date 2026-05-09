import 'package:shared_preferences/shared_preferences.dart';

/// Marca a primeira vez que o app entra na casca principal ([NavBarPage]).
/// Usado pelo fluxo de avaliação na loja (contagem de dias), independente de
/// a criança ou o adulto estar usando o app.
abstract final class AppInstallMarkers {
  /// Chave compartilhada com [ParentReviewPrompt].
  static const String firstOpenPrefsKey = 'primeira_abertura_app';

  static Future<void> recordFirstOpenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(firstOpenPrefsKey) != null) return;
    await prefs.setString(firstOpenPrefsKey, DateTime.now().toIso8601String());
  }
}
