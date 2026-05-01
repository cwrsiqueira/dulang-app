import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/dulang_premium/dulang_premium_widget.dart';

/// Tela de bloqueio exibida para usuários do plano gratuito ao tentar acessar
/// features exclusivas do Premium (Favoritos, Histórico, etc.).
class PremiumGateScreen extends StatelessWidget {
  const PremiumGateScreen({
    super.key,
    required this.featureName,
    required this.featureIcon,
  });

  final String featureName;
  final IconData featureIcon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tertiary = theme.tertiary;
    final onCard = theme.primaryText;
    final onMuted = theme.secondaryText;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        title: Text(featureName, style: theme.headlineSmall),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(featureIcon, size: 64, color: tertiary.withValues(alpha: 0.5)),
              const SizedBox(height: 20),
              Text(
                '$featureName é exclusivo do Premium',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: onCard,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Assine o Premium para acessar $featureName e muito mais, sem limites de tempo.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: onMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tertiary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () =>
                    context.pushNamed(DulangPremiumWidget.routeName),
                child: Text(
                  'Ver planos Premium',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
