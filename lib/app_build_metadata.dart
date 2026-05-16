import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Alinhar `marketingVersion` com releases; `lastContentUpdate` = data do texto legal/informativo.
abstract final class AppBuildMetadata {
  /// Versão “de marketing” exibida em termos/sobre/contato (alinhar ao release).
  static const String marketingVersion = '1.0.52';
  /// Data do texto legal/informativo exibido no rodapé.
  static const String lastContentUpdate = '16/05/2026';
}

/// Rodapé comum em termos, sobre e contato.
class AppLegalFootnote extends StatelessWidget {
  const AppLegalFootnote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 36),
      child: Text(
        'Versão ${AppBuildMetadata.marketingVersion}\n'
        'Última atualização: ${AppBuildMetadata.lastContentUpdate}',
        textAlign: TextAlign.center,
        style: theme.bodySmall.copyWith(
          color: theme.secondaryText,
          height: 1.4,
        ),
      ),
    );
  }
}
