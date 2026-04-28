import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Ajuda para ativar PIN/senha/biometria do aparelho (usado ao alterar PIN parental).
class DeviceAuthHelpWidget extends StatelessWidget {
  const DeviceAuthHelpWidget({super.key});

  static String routeName = 'DeviceAuthHelp';
  static String routePath = '/deviceAuthHelp';

  Future<void> _openSystemSecurity(BuildContext context) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await AppSettings.openAppSettings(
          type: AppSettingsType.lockAndPassword,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await AppSettings.openAppSettings();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir os ajustes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Confirmar no aparelho',
          style: theme.headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Por que o Dulang pede isso?',
            style: theme.titleMedium.override(color: theme.primaryText),
          ),
          const SizedBox(height: 10),
          Text(
            'Para trocar o PIN parental, o Dulang precisa saber que é um adulto no aparelho. '
            'Por isso usamos a mesma confirmação que você já usa no dia a dia — biometria, '
            'Face ID, Touch ID ou o código/PIN do aparelho — quando o sistema permite.',
            style: theme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (isAndroid || isIos) ...[
            FilledButton.icon(
              onPressed: () => _openSystemSecurity(context),
              icon: const Icon(Icons.settings_rounded),
              label: Text(
                isAndroid
                    ? 'Abrir tela de bloqueio e segurança'
                    : 'Abrir Ajustes do iPhone',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.tertiary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isAndroid
                  ? 'Configure PIN, senha ou padrão para desbloquear o aparelho (o menu pode se chamar “Segurança”, “Biometria” ou parecido, conforme o fabricante).'
                  : 'Em Ajustes, use “Face ID e código” ou “Touch ID e código” e defina um código.',
              style: theme.bodySmall.override(color: theme.secondaryText),
            ),
          ] else
            Text(
              'Neste ambiente não dá para abrir as configurações do sistema.',
              style: theme.bodySmall.override(color: theme.secondaryText),
            ),
        ],
      ),
    );
  }
}
