import '/features/subscription/freemium_service.dart';
import '/features/subscription/subscription_service.dart';
import '/pages/dulang_premium/free_plan_email_sheet.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/dulang_premium/dulang_subscription_manage_widget.dart';
import '/pages/termos_de_uso_e_politica_de_privacidade/termos_de_uso_e_politica_de_privacidade_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';

import 'dulang_premium_model.dart';
export 'dulang_premium_model.dart';

/// Paywall Flutter focada em conversão (RevenueCat: preços reais ou placeholders).
/// [isGate] = true quando a paywall é o gate inicial da rota (sem plano selecionado);
/// oculta o botão voltar e não faz safePop após enroll (o router redireciona sozinho).
class DulangPremiumWidget extends StatefulWidget {
  const DulangPremiumWidget({super.key, this.isGate = false});

  final bool isGate;

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

  static const double _placeholderMonthlyBrl = 9.99;
  static const double _placeholderAnnualBrl = 99.99;

  static String _fmtBrl(num value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
      decimalDigits: 2,
    ).format(value);
  }

  /// Rodapé fixo: texto de confiança conforme a loja do dispositivo.
  static String _securePurchaseStoreLine() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Compra segura na Google Play Store';
      case TargetPlatform.iOS:
        return 'Compra segura na Apple App Store';
      default:
        return 'Compra segura na loja de aplicativos';
    }
  }

  static const _valueBullets = <(IconData, String)>[
    (Icons.translate_rounded, 'Aprendizado natural com inglês nativo'),
    (Icons.psychology_outlined, 'Aumenta o desenvolvimento cognitivo'),
    (Icons.school_outlined, 'Facilita o aprendizado no futuro'),
    (Icons.savings_outlined, 'Evita gastos com cursos caros depois'),
    (Icons.shield_outlined, 'Ambiente 100% seguro e sem anúncios'),
  ];

  static const _trustChips = <String>[
    'Sem anúncios',
    'Sem navegação externa',
    'Conteúdo seguro para crianças',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DulangPremiumModel());
    if (SubscriptionService.instance.hasPremiumAccess) {
      if (!widget.isGate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.safePop();
          context.pushNamed(DulangSubscriptionManageWidget.routeName);
        });
      }
      return;
    }
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _offeringsError = null;
    });
    try {
      final o = await SubscriptionService.instance.getOfferings();
      if (!mounted) return;
      setState(() {
        _offerings = o;
        _loadingOfferings = false;
        _offeringsError = null;
        _applyDefaultPlanSelection();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offerings = null;
        _loadingOfferings = false;
        _offeringsError = 'Não foi possível carregar. Tente de novo.';
      });
    }
  }

  /// Anual como padrão quando existir pacote anual na oferta atual.
  void _applyDefaultPlanSelection() {
    final offering = _currentOffering;
    final annual = SubscriptionService.annualPackage(offering);
    final monthly = SubscriptionService.monthlyPackage(offering);
    if (annual != null) {
      _annualSelected = true;
    } else if (monthly != null) {
      _annualSelected = false;
    }
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
      _annualSelected ? _annual : _monthly;

  bool get _storePurchasesAvailable => SubscriptionService.instance.isConfigured;

  String get _displayMonthlyPrice =>
      _monthly?.storeProduct.priceString ?? _fmtBrl(_placeholderMonthlyBrl);

  String get _displayAnnualPrice =>
      _annual?.storeProduct.priceString ?? _fmtBrl(_placeholderAnnualBrl);

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

  Future<void> _onFreePlan() async {
    final enrolled = await showFreePlanEmailSheet(context);
    if (enrolled && mounted && !widget.isGate) {
      context.safePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tertiary = theme.tertiary;
    final onCard = theme.primaryText;
    final onMuted = theme.secondaryText;
    final cardBg = theme.secondaryBackground;
    context.watch<SubscriptionService>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.isGate
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: onCard),
                onPressed: () => context.safePop(),
              ),
        title: Text(
          'Premium',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: tertiary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
              children: [
                Text(
                  'Quanto mais cedo seu filho começa, mais fácil é aprender inglês',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: onCard,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Cada dia conta no desenvolvimento. Comece hoje com segurança.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: onMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                ..._valueBullets.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(b.$1, color: tertiary, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            b.$2,
                            style: GoogleFonts.inter(
                              color: onCard,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _trialBlock(context, tertiary, onCard, onMuted, cardBg),
                const SizedBox(height: 28),
                Text(
                  'Escolha o plano',
                  style: GoogleFonts.inter(
                    color: onCard,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Anual recomendado para economizar',
                  style: GoogleFonts.inter(
                    color: onMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _annualPlanCard(context, tertiary, onCard, onMuted, cardBg),
                const SizedBox(height: 12),
                _monthlyPlanCard(context, tertiary, onCard, onMuted, cardBg),
                if (!FreemiumService.instance.isEnrolled) ...[
                  const SizedBox(height: 24),
                  _freePlanDivider(onMuted),
                  const SizedBox(height: 20),
                  _freePlanCard(context, tertiary, onCard, onMuted, cardBg),
                ],
                const SizedBox(height: 28),
                _trustSection(context, tertiary, onCard, onMuted, cardBg),
                const SizedBox(height: 28),
                TextButton(
                  onPressed: () => context.pushNamed(
                    TermosDeUsoEPoliticaDePrivacidadeWidget.routeName,
                  ),
                  child: Text(
                    'Termos, privacidade e renovação automática',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: onMuted,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _purchasing ? null : _onRestore,
                  child: Text(
                    'Restaurar compras',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: tertiary,
                    ),
                  ),
                ),
                // Espaço extra para o último conteúdo não colar visualmente no rodapé fixo.
                SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
              ],
            ),
          ),
          _stickyCta(context, tertiary, onCard, onMuted, theme.primaryBackground),
        ],
      ),
    );
  }

  Widget _trialBlock(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onMuted,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: tertiary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tertiary, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '7 dias grátis para testar',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: onCard,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sem compromisso. Cancele quando quiser.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: onMuted,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _annualPlanCard(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onMuted,
    Color cardBg,
  ) {
    final selected = _annualSelected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _annualSelected = true),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? tertiary : onMuted.withValues(alpha: 0.25),
              width: selected ? 3 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: tertiary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tertiary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Melhor valor',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Plano anual',
                style: GoogleFonts.inter(
                  color: onCard,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '2 meses grátis',
                style: GoogleFonts.inter(
                  color: tertiary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Menor custo mensal e mais economia',
                style: GoogleFonts.inter(
                  color: onMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _displayAnnualPrice,
                    style: GoogleFonts.inter(
                      color: onCard,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 4),
                    child: Text(
                      '/ano',
                      style: GoogleFonts.inter(
                        color: onMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: tertiary, size: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthlyPlanCard(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onMuted,
    Color cardBg,
  ) {
    final selected = !_annualSelected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _annualSelected = false),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? tertiary : onMuted.withValues(alpha: 0.2),
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tertiary.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mais flexível',
                        style: GoogleFonts.inter(
                          color: onCard,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Plano mensal',
                      style: GoogleFonts.inter(
                        color: onCard,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cobrança mensal',
                      style: GoogleFonts.inter(
                        color: onMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _displayMonthlyPrice,
                    style: GoogleFonts.inter(
                      color: onCard,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '/mês',
                    style: GoogleFonts.inter(
                      color: onMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 6),
                    Icon(Icons.check_circle_rounded, color: tertiary, size: 24),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _freePlanDivider(Color onMuted) {
    return Row(
      children: [
        Expanded(child: Divider(color: onMuted.withValues(alpha: 0.25))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou comece grátis',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: onMuted.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: onMuted.withValues(alpha: 0.25))),
      ],
    );
  }

  Widget _freePlanCard(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onMuted,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onMuted.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plano gratuito',
                  style: GoogleFonts.inter(
                    color: onCard,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1 hora por dia • Todo o conteúdo • Vitalício',
                  style: GoogleFonts.inter(
                    color: onMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _purchasing ? null : _onFreePlan,
            style: TextButton.styleFrom(
              foregroundColor: tertiary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: tertiary.withValues(alpha: 0.6)),
              ),
            ),
            child: Text(
              'Continuar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustSection(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onMuted,
    Color cardBg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por que confiar no Dulang',
          style: GoogleFonts.inter(
            color: onCard,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trustChips.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tertiary.withValues(alpha: 0.35)),
              ),
              child: Text(
                t,
                style: GoogleFonts.inter(
                  color: onCard,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _stickyCta(
    BuildContext context,
    Color tertiary,
    Color onCard,
    Color onMuted,
    Color surfaceBg,
  ) {
    final bg = surfaceBg;
    final borderTop = onMuted.withValues(alpha: 0.22);

    final bool buttonBusy = _purchasing;
    final bool buttonLoadingPlans = _loadingOfferings;
    final bool buttonNoPlans = !_loadingOfferings &&
        _offeringsError == null &&
        _storePurchasesAvailable &&
        _selectedPackage == null;
    final bool buttonStoreOff = !_storePurchasesAvailable && !_loadingOfferings;

    final bool showMainPurchaseFooter =
        _offeringsError == null && !buttonStoreOff;

    VoidCallback? onPressed;
    if (!showMainPurchaseFooter) {
      onPressed = null;
    } else if (buttonBusy || buttonLoadingPlans) {
      onPressed = null;
    } else if (buttonNoPlans) {
      onPressed = null;
    } else {
      onPressed = _onPurchase;
    }

    Widget buttonChild;
    if (buttonLoadingPlans) {
      buttonChild = SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.black.withValues(alpha: 0.85),
        ),
      );
    } else if (buttonBusy) {
      buttonChild = const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.black,
        ),
      );
    } else {
      buttonChild = Text(
        'Começar grátis',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          fontSize: 17,
        ),
      );
    }

    return Material(
      color: bg,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border(top: BorderSide(color: borderTop, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_offeringsError != null) ...[
                  Text(
                    _offeringsError!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: onCard,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _loadingOfferings || _purchasing
                        ? null
                        : _loadOfferings,
                    child: Text(
                      'Tentar novamente',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        color: tertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (buttonStoreOff) ...[
                  Text(
                    'Assinaturas não estão disponíveis neste dispositivo.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: onMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (showMainPurchaseFooter) ...[
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: tertiary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      disabledBackgroundColor: tertiary.withValues(alpha: 0.45),
                      disabledForegroundColor: Colors.black54,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: onPressed,
                    child: buttonChild,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '7 dias grátis • Cancele quando quiser',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: onMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_securePurchaseStoreLine()}.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: onMuted.withValues(alpha: 0.92),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
