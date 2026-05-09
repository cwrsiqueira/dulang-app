import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '/features/subscription/access_code_service.dart';
import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:provider/provider.dart';

/// Quando existirem URLs públicos do app, preencher e usar em “Página na loja”.
/// Enquanto `null`, o botão correspondente explica que o link virá em breve.
const String? kDulangPlayStoreListingUrl = null;
const String? kDulangAppStoreListingUrl = null;

/// Informações para quem tem Premium por **código de acesso** (sem paywall).
class DulangPremiumCodigoInfoWidget extends StatefulWidget {
  const DulangPremiumCodigoInfoWidget({super.key});

  static String routeName = 'DulangPremiumCodigoInfo';
  static String routePath = '/dulangPremiumCodigoInfo';

  @override
  State<DulangPremiumCodigoInfoWidget> createState() =>
      _DulangPremiumCodigoInfoWidgetState();
}

class _DulangPremiumCodigoInfoWidgetState
    extends State<DulangPremiumCodigoInfoWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cupom = AccessCodeService.instance.isGranted;
      final loja = SubscriptionService.instance.hasActiveStorePremiumEntitlement;
      if (!cupom || loja) {
        context.safePop();
      }
    });
  }

  static String _nomeLojaAlvo() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Google Play';
      case TargetPlatform.iOS:
        return 'App Store';
      default:
        return 'loja de aplicativos';
    }
  }

  Future<void> _compartilharTexto() async {
    final msg =
        'Conheça o Dulang — inglês para crianças com conteúdo seguro e sem anúncios. '
        '(${_nomeLojaAlvo()}: link da página do app em breve.)';
    try {
      await Share.share(msg);
    } on PlatformException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o compartilhamento neste aparelho.'),
        ),
      );
    }
  }

  void _paginaNaLojaEmBreve() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Em breve você poderá abrir a página do Dulang na ${_nomeLojaAlvo()} a partir daqui.',
        ),
      ),
    );
  }

  Future<void> _abrirPaginaNaLojaOuAviso() async {
    final raw = switch (defaultTargetPlatform) {
      TargetPlatform.android => kDulangPlayStoreListingUrl,
      TargetPlatform.iOS => kDulangAppStoreListingUrl,
      _ => null,
    };
    if (raw != null && raw.isNotEmpty) {
      final uri = Uri.tryParse(raw);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    _paginaNaLojaEmBreve();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    context.watch<AccessCodeService>();
    context.watch<SubscriptionService>();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Premium por código',
          style: theme.headlineSmall.override(color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Seu acesso Premium',
            style: theme.titleMedium.override(color: theme.primaryText),
          ),
          const SizedBox(height: 8),
          Card(
            color: theme.secondaryBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código de acesso ativo',
                    style: theme.titleSmall.override(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Este Premium foi liberado com um código de uso único. '
                    'Não há cobrança recorrente na ${_nomeLojaAlvo()} nem renovação automática pela loja.',
                    style: theme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Na prática, o acesso é contínuo neste aparelho enquanto o app '
                    'permanecer instalado — sem mensalidade. Se o app for desinstalado '
                    'e instalado de novo, o mesmo código não pode ser usado outra vez; '
                    'nesse caso é possível assinar pelo plano pago ou obter um novo código.',
                    style: theme.bodyMedium.copyWith(
                      color: theme.secondaryText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Indicar o Dulang',
            style: theme.titleMedium.override(color: theme.primaryText),
          ),
          const SizedBox(height: 8),
          Text(
            'Compartilhe uma mensagem com quem você quiser. '
            'O link direto para a página do app na ${_nomeLojaAlvo()} será adicionado depois.',
            style: theme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _compartilharTexto,
            icon: const Icon(Icons.share_rounded),
            label: const Text('Compartilhar texto sobre o Dulang'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.tertiary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _abrirPaginaNaLojaOuAviso,
            icon: const Icon(Icons.store_mall_directory_outlined),
            label: Text('Página na ${_nomeLojaAlvo()} (em breve)'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}
