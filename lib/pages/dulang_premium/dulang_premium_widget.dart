import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/termos_de_uso_e_politica_de_privacidade/termos_de_uso_e_politica_de_privacidade_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';

import 'dulang_premium_model.dart';
export 'dulang_premium_model.dart';

/// Paywall em Flutter (sem UI nativa do RevenueCat). Preços vêm da loja via SDK.
class DulangPremiumWidget extends StatefulWidget {
  const DulangPremiumWidget({super.key});

  static String routeName = 'DulangPremium';
  static String routePath = '/dulangPremium';

  @override
  State<DulangPremiumWidget> createState() => _DulangPremiumWidgetState();
}

class _DulangPremiumWidgetState extends State<DulangPremiumWidget> {
  late DulangPremiumModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _annualSelected = true;
  Offerings? _offerings;
  bool _loadingOfferings = true;
  String? _offeringsError;
  bool _purchasing = false;

  static const _benefits = <(IconData, String)>[
    (Icons.shield_moon_rounded, 'Vídeos em inglês curados, sem navegação solta fora do app'),
    (Icons.child_care_rounded, 'Ambiente pensado para crianças pequenas (0 a 5 anos)'),
    (Icons.verified_user_rounded, 'Controle parental com PIN para áreas sensíveis'),
    (Icons.favorite_rounded, 'Favoritos para guardar o que mais gostam'),
    (Icons.history_rounded, 'Histórico do que já assistiram'),
    (Icons.video_library_rounded, 'Catálogo em inglês sem anúncios no app'),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DulangPremiumModel());
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _offeringsError = null;
    });
    final o = await SubscriptionService.instance.getOfferings();
    if (!mounted) return;
    setState(() {
      _offerings = o;
      _loadingOfferings = false;
      if (o?.current == null &&
          SubscriptionService.instance.isConfigured) {
        _offeringsError =
            'Ofertas ainda não configuradas. Verifique o painel RevenueCat e as lojas.';
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Offering? get _currentOffering => _offerings?.current;

  Package? get _monthly =>
      SubscriptionService.monthlyPackage(_currentOffering);

  Package? get _annual => SubscriptionService.annualPackage(_currentOffering);

  Package? get _selectedPackage =>
      _annualSelected ? (_annual ?? _monthly) : (_monthly ?? _annual);

  Future<void> _onPurchase() async {
    final pkg = _selectedPackage;
    if (pkg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar os planos. Tente de novo.'),
        ),
      );
      return;
    }
    setState(() => _purchasing = true);
    try {
      await SubscriptionService.instance.purchasePackage(pkg);
      if (!mounted) return;
      if (SubscriptionService.instance.hasPremiumAccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assinatura ativa. Bem-vindo ao Premium!')),
        );
        context.safePop();
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (SubscriptionService.instance.isUserCancelled(e)) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Compra não concluída.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _onRestore() async {
    setState(() => _purchasing = true);
    try {
      await SubscriptionService.instance.restorePurchases();
      if (!mounted) return;
      if (SubscriptionService.instance.hasPremiumAccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compras restauradas com sucesso.')),
        );
        context.safePop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhuma assinatura ativa encontrada para esta conta da loja.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível restaurar: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tertiary = theme.tertiary;
    final onCard = theme.primaryText;
    final onCardMuted = theme.secondaryText;
    final sub = context.watch<SubscriptionService>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Dulang Premium',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: tertiary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Text(
            'Inglês de verdade, com segurança para quem você mais ama.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: onCard,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '7 dias grátis para experimentar. Cancele quando quiser antes de ser cobrado, nas regras da App Store ou Google Play.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: onCardMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cancele quando quiser. Sem taxas escondidas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: onCardMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),
          if (!sub.isConfigured)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Compras não estão ativas neste ambiente (sem chave RevenueCat ou plataforma não suportada).',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: theme.warning, fontSize: 13),
              ),
            ),
          if (_loadingOfferings)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_offeringsError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _offeringsError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: theme.error, fontSize: 13),
              ),
            ),
          _planToggle(context, tertiary, onCard, onCardMuted),
          const SizedBox(height: 14),
          _planDetailCard(context, tertiary, onCard, onCardMuted),
          const SizedBox(height: 20),
          Text(
            'O que está incluído',
            style: GoogleFonts.inter(
              color: onCard,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          for (final b in _benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(b.$1, color: tertiary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      b.$2,
                      style: GoogleFonts.inter(
                        color: onCard,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pushNamed(
              TermosDeUsoEPoliticaDePrivacidadeWidget.routeName,
            ),
            child: Text(
              'Termos de uso, privacidade e renovação automática',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: onCardMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          TextButton(
            onPressed: _purchasing ? null : _onRestore,
            child: Text(
              'Restaurar compras',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: tertiary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tertiary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (_purchasing ||
                        _loadingOfferings ||
                        !sub.isConfigured ||
                        _selectedPackage == null)
                    ? null
                    : _onPurchase,
                child: _purchasing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Começar teste grátis de 7 dias',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
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

  Widget _planToggle(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onCardMuted,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(
              context,
              label: 'Plano anual',
              selected: _annualSelected,
              tertiary: tertiary,
              onCard: onCard,
              onTap: () => setState(() => _annualSelected = true),
            ),
          ),
          Expanded(
            child: _segment(
              context,
              label: 'Plano mensal',
              selected: !_annualSelected,
              tertiary: tertiary,
              onCard: onCard,
              onTap: () => setState(() => _annualSelected = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context, {
    required String label,
    required bool selected,
    required Color tertiary,
    required Color onCard,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? tertiary.withValues(alpha: 0.22) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? tertiary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: selected ? onCard : FlutterFlowTheme.of(context).secondaryText,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _planDetailCard(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onCardMuted,
  ) {
    final monthly = _monthly;
    final annual = _annual;
    final pkg = _selectedPackage;

    if (pkg == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tertiary.withValues(alpha: 0.35)),
        ),
        child: Text(
          SubscriptionService.instance.isConfigured
              ? 'Não encontramos pacotes mensal e anual na oferta atual do RevenueCat. Confira os tipos de pacote no painel (mensal e anual).'
              : 'Ative a chave RevenueCat para ver preços e assinar.',
          style: GoogleFonts.inter(color: onCardMuted, fontSize: 14),
        ),
      );
    }

    final isAnnual = pkg == annual;
    final priceLine = pkg.storeProduct.priceString;
    final periodLabel = isAnnual ? '/ano' : '/mês';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tertiary, width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAnnual) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tertiary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Melhor valor — 2 meses grátis',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tertiary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Mais flexível',
                style: GoogleFonts.inter(
                  color: onCard,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          if (!isAnnual) const SizedBox(height: 12),
          Text(
            isAnnual ? 'Cobrança anual' : 'Cobrança mensal',
            style: GoogleFonts.inter(
              color: onCardMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceLine,
                style: GoogleFonts.inter(
                  color: onCard,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  periodLabel,
                  style: GoogleFonts.inter(
                    color: onCardMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.check_circle, color: tertiary, size: 32),
            ],
          ),
          if (isAnnual && monthly != null) ...[
            const SizedBox(height: 12),
            Text(
              'Economize o equivalente a 2 mensalidades: o anual custa o mesmo que 10 meses do plano mensal (${monthly.storeProduct.priceString}/mês).',
              style: GoogleFonts.inter(
                color: onCardMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (!isAnnual && annual != null) ...[
            const SizedBox(height: 12),
            Text(
              'Quer pagar menos no ano? Veja o plano anual (${annual.storeProduct.priceString}/ano) com desconto de 2 meses.',
              style: GoogleFonts.inter(
                color: onCardMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
