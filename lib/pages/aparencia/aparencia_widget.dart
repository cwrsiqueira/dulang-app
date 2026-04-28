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
    final mode = MyApp.of(context).themePreference;

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
          _ThemeOptionTile(
            icon: Icons.light_mode_outlined,
            title: 'Claro',
            subtitle: 'Sempre tema claro no app',
            selected: mode == ThemeMode.light,
            tertiary: theme.tertiary,
            onTap: () => MyApp.of(context).setThemeMode(ThemeMode.light),
          ),
          _ThemeOptionTile(
            icon: Icons.dark_mode_outlined,
            title: 'Escuro',
            subtitle: 'Sempre tema escuro no app',
            selected: mode == ThemeMode.dark,
            tertiary: theme.tertiary,
            onTap: () => MyApp.of(context).setThemeMode(ThemeMode.dark),
          ),
          _ThemeOptionTile(
            icon: Icons.settings_suggest_outlined,
            title: 'Sistema',
            subtitle: 'Segue o claro ou escuro configurado no aparelho',
            selected: mode == ThemeMode.system,
            tertiary: theme.tertiary,
            onTap: () => MyApp.of(context).setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.tertiary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color tertiary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    selected ? tertiary : theme.secondaryText.withValues(alpha: 0.2),
                width: selected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: selected ? tertiary : theme.primaryText, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.titleSmall.override(
                          color: theme.primaryText,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.bodySmall.override(color: theme.secondaryText),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: tertiary, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
