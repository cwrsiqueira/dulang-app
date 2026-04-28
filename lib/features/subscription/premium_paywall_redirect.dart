import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/dulang_premium/dulang_premium_widget.dart';

/// Abre a paywall e retorna à tela anterior (substitui a antiga tela de bloqueio Premium).
class PremiumPaywallRedirectScaffold extends StatefulWidget {
  const PremiumPaywallRedirectScaffold({super.key});

  @override
  State<PremiumPaywallRedirectScaffold> createState() =>
      _PremiumPaywallRedirectScaffoldState();
}

class _PremiumPaywallRedirectScaffoldState
    extends State<PremiumPaywallRedirectScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPaywall());
  }

  Future<void> _openPaywall() async {
    if (!mounted) return;
    await context.pushNamed(DulangPremiumWidget.routeName);
    if (mounted) context.safePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
