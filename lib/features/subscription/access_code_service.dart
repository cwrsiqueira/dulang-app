import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acesso premium concedido por código de uso único validado no Supabase (Edge Function).
/// Persistido localmente: se o usuário desinstalar o app, o acesso local some (o código já foi consumido no servidor).
class AccessCodeService extends ChangeNotifier {
  AccessCodeService._();

  static final AccessCodeService instance = AccessCodeService._();

  static const _kGranted = 'premium_access_code_granted_v1';

  bool _granted = false;

  bool get isGranted => _granted;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _granted = prefs.getBool(_kGranted) ?? false;
  }

  /// Chame após fechar o diálogo de código com sucesso, para o router atualizar sem assert.
  void notifyAfterDialogClosed() {
    notifyListeners();
  }

  /// Remove o flag local (só para debug). O código no servidor continua usado.
  Future<void> debugClearLocal() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGranted);
    _granted = false;
    notifyListeners();
  }

  /// Valida o código no servidor e grava acesso local em caso de sucesso.
  /// Retorna `null` se ok, ou mensagem de erro em pt-BR.
  Future<String?> redeem(String rawCode) async {
    final normalized = rawCode.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (normalized.length < 4) {
      return 'Digite um código válido.';
    }

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'validate-access-code',
        body: {'code': normalized},
      );

      if (res.status != 200) {
        final d = res.data;
        if (d is Map && d['error'] != null) {
          return d['error'].toString();
        }
        return 'Código inválido ou já utilizado.';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kGranted, true);
      _granted = true;
      // Notifique com [notifyAfterDialogClosed] depois do Navigator.pop do diálogo —
      // nunca aqui, senão o GoRouter troca a rota com o overlay do AlertDialog ainda ativo.
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AccessCodeService.redeem: $e');
      }
      return 'Erro de rede. Verifique a conexão e tente novamente.';
    }
  }
}
