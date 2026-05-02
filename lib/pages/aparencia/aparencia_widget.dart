import '/features/subscription/freemium_service.dart';
import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String _savedThemeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Escuro',
      ThemeMode.system => 'Sistema',
    };

class AparenciaWidget extends StatefulWidget {
  const AparenciaWidget({super.key});

  static String routeName = 'Aparencia';
  static String routePath = '/aparencia';

  @override
  State<AparenciaWidget> createState() => _AparenciaWidgetState();
}

class _AparenciaWidgetState extends State<AparenciaWidget> {
  // Lido uma vez no init para evitar subscriptions reativas que conflitam
  // com setThemeMode e causam o assert renderObject.child == child.
  late bool _freemium;

  @override
  void initState() {
    super.initState();
    final premium = context.read<SubscriptionService>().hasPremiumAccess;
    _freemium = context.read<FreemiumService>().isEnrolled && !premium;
  }

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
          const SizedBox(height: 4),
          Text(
            _freemium
                ? 'Plano gratuito: tema claro fixo. Assine o Premium para personalizar.'
                : 'Salvo: ${_savedThemeLabel(mode)} — pode coincidir com o visual '
                    'quando "Sistema" e o aparelho já estão no mesmo claro ou escuro.',
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 12),
          _ThemeOptionTile(
            icon: Icons.light_mode_outlined,
            title: 'Claro',
            subtitle: 'Sempre tema claro no app',
            selected: mode == ThemeMode.light,
            locked: false,
            tertiary: theme.tertiary,
            onTap: () => MyApp.of(context).setThemeMode(ThemeMode.light),
          ),
          _ThemeOptionTile(
            icon: Icons.dark_mode_outlined,
            title: 'Escuro',
            subtitle: 'Sempre tema escuro no app',
            selected: mode == ThemeMode.dark,
            locked: _freemium,
            tertiary: theme.tertiary,
            onTap: _freemium
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tema escuro é exclusivo do Premium.'),
                      ),
                    )
                : () => MyApp.of(context).setThemeMode(ThemeMode.dark),
          ),
          _ThemeOptionTile(
            icon: Icons.settings_suggest_outlined,
            title: 'Sistema',
            subtitle: 'Segue o claro ou escuro configurado no aparelho',
            selected: mode == ThemeMode.system,
            locked: _freemium,
            tertiary: theme.tertiary,
            onTap: _freemium
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Tema automático é exclusivo do Premium.'),
                      ),
                    )
                : () => MyApp.of(context).setThemeMode(ThemeMode.system),
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
    required this.locked,
    required this.tertiary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool locked;
  final Color tertiary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final effectiveColor = locked
        ? theme.secondaryText.withValues(alpha: 0.45)
        : selected
            ? tertiary
            : theme.primaryText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: locked
                    ? theme.secondaryText.withValues(alpha: 0.12)
                    : selected
                        ? tertiary
                        : theme.secondaryText.withValues(alpha: 0.2),
                width: selected && !locked ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: effectiveColor, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.titleSmall.override(
                          color: locked
                              ? theme.secondaryText.withValues(alpha: 0.5)
                              : theme.primaryText,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.bodySmall.override(
                          color: theme.secondaryText
                              .withValues(alpha: locked ? 0.45 : 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
                if (locked)
                  Icon(Icons.lock_outline_rounded,
                      color: theme.secondaryText.withValues(alpha: 0.4),
                      size: 20)
                else if (selected)
                  Icon(Icons.check_circle_rounded, color: tertiary, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
