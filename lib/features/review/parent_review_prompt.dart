import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_install_markers.dart';

/// Solicitação de avaliação na loja (in-app review), **somente** a partir de
/// superfície parental (ex.: aba Ajustes após PIN). Não chamar na Home/vídeos.
///
/// O tipo de Premium (mensal, anual, cupom, etc.) **não** entra na conta: basta
/// o usuário já ter passado pela [NavBarPage] (marcador em [AppInstallMarkers])
/// e decorrer o prazo; o gatilho é só na tela de configurações.
abstract final class ParentReviewPrompt {
  static const _prefsKeyAsked = 'avaliacao_pedida';

  /// Produção: dias após a primeira abertura registrada por [AppInstallMarkers].
  static const int minDaysBeforePrompt = 5;

  /// Debug: mesmo fluxo, prazo curto para testar no `flutter run`.
  static const Duration _debugMinDelayBeforePrompt = Duration(minutes: 5);

  static bool _elapsedEnoughSinceFirstOpen(DateTime start) {
    final elapsed = DateTime.now().difference(start);
    if (kDebugMode) {
      return elapsed >= _debugMinDelayBeforePrompt;
    }
    return elapsed.inDays >= minDaysBeforePrompt;
  }

  static Future<void> maybeRequestOnParentSettingsSurface() async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefsKeyAsked) ?? false) return;

    final primeira = prefs.getString(AppInstallMarkers.firstOpenPrefsKey);
    if (primeira == null) return;

    final dataInicio = DateTime.tryParse(primeira);
    if (dataInicio == null) return;

    if (!_elapsedEnoughSinceFirstOpen(dataInicio)) return;

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      await prefs.setBool(_prefsKeyAsked, true);
    }
  }
}
