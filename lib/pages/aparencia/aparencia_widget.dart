import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/main.dart';
import 'package:flutter/material.dart';

/// Tema: claro, escuro ou sistema.
class AparenciaWidget extends StatelessWidget {
  const AparenciaWidget({super.key});

  static String routeName = 'Aparencia';
  static String routePath = '/aparencia';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final mode = FlutterFlowTheme.themeMode;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Aparência',
          style: theme.headlineSmall.override(color: theme.primaryText),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.primaryText),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tema do app',
            style: theme.titleMedium.override(color: theme.primaryText),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            key: ValueKey(mode),
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Escuro'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.settings_suggest_outlined),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (s) {
              MyApp.of(context).setThemeMode(s.first);
            },
          ),
        ],
      ),
    );
  }
}
