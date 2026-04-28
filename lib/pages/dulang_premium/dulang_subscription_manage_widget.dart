import 'package:flutter/foundation.dart';
import '/features/subscription/subscription_constants.dart';
import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/dulang_premium/dulang_premium_widget.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gestão de assinatura: status (RevenueCat) e abertura da tela nativa da loja.
class DulangSubscriptionManageWidget extends StatefulWidget {
  const DulangSubscriptionManageWidget({super.key});

  static String routeName = 'DulangSubscriptionManage';
  static String routePath = '/dulangSubscriptionManage';

  @override
  State<DulangSubscriptionManageWidget> createState() =>
      _DulangSubscriptionManageWidgetState();
}

class _DulangSubscriptionManageWidgetState
    extends State<DulangSubscriptionManageWidget> {
  bool _opening = false;
  Package? _activePackage;

  static String? _formatExpirationPt(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return null;
    return DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(dt.toLocal());
  }

  static String _periodLabel(PeriodType p) {
    switch (p) {
      case PeriodType.trial:
        return 'Período de teste';
      case PeriodType.intro:
        return 'Preço promocional';
      case PeriodType.normal:
        return 'Assinatura ativa';
      case PeriodType.prepaid:
        return 'Pré-pago';
      case PeriodType.unknown:
        return 'Assinatura';
    }
  }

  static String _storeLabel(Store s) {
    switch (s) {
      case Store.appStore:
      case Store.macAppStore:
        return 'App Store';
      case Store.playStore:
        return 'Google Play';
      case Store.stripe:
        return 'Stripe';
      case Store.rcBilling:
        return 'RevenueCat';
      default:
        return 'Loja';
    }
  }

  Future<void> _openStoreManagement(String? url) async {
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Link da loja indisponível. Atualize a página ou tente em instantes.',
          ),
        ),
      );
      await SubscriptionService.instance.refreshCustomerInfo();
      if (mounted) setState(() {});
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço da loja inválido.')),
      );
      return;
    }
    setState(() => _opening = true);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir a loja neste aparelho.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  static String _friendlyPlanName(
    String productId,
    PackageType? packageType,
  ) {
    if (packageType == PackageType.annual) return 'Plano anual';
    if (packageType == PackageType.monthly) return 'Plano mensal';

    final id = productId.toLowerCase();
    if (id.contains('annual') || id.contains('year') || id.contains('anual')) {
      return 'Plano anual';
    }
    if (id.contains('month') || id.contains('mensal')) return 'Plano mensal';
    return 'Dulang Premium';
  }

  static String _billingSuffix(PackageType? packageType, String productId) {
    if (packageType == PackageType.annual) return '/ano';
    if (packageType == PackageType.monthly) return '/mês';
    if (packageType == PackageType.weekly) return '/semana';

    final id = productId.toLowerCase();
    if (id.contains('annual') || id.contains('year') || id.contains('anual')) {
      return '/ano';
    }
    if (id.contains('month') || id.contains('mensal')) return '/mês';
    return '';
  }

  static Package? _findPackageByProductId(Offerings? offerings, String id) {
    if (offerings == null) return null;
    Package? match;

    if (offerings.current != null) {
      for (final p in offerings.current!.availablePackages) {
        if (p.storeProduct.identifier == id) return p;
      }
    }

    offerings.all.forEach((_, offering) {
      if (match != null) return;
      for (final p in offering.availablePackages) {
        if (p.storeProduct.identifier == id) {
          match = p;
          return;
        }
      }
    });
    return match;
  }

  Future<void> _loadCurrentPlanInfo(String productId) async {
    final offerings = await SubscriptionService.instance.getOfferings();
    final pkg = _findPackageByProductId(offerings, productId);
    if (!mounted) return;
    setState(() => _activePackage = pkg);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!SubscriptionService.instance.hasPremiumAccess) {
        context.safePop();
        context.pushNamed(DulangPremiumWidget.routeName);
        return;
      }
      await SubscriptionService.instance.refreshCustomerInfo();
      if (!mounted) return;
      final info = SubscriptionService.instance.customerInfo;
      final entitlement =
          info?.entitlements.all[SubscriptionConstants.premiumEntitlementId];
      if (entitlement != null) {
        await _loadCurrentPlanInfo(entitlement.productIdentifier);
      } else {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    context.watch<SubscriptionService>();

    final info = SubscriptionService.instance.customerInfo;
    final id = SubscriptionConstants.premiumEntitlementId;
    final ent = info?.entitlements.all[id];
    final hasAccess = SubscriptionService.instance.hasPremiumAccess;
    final planName = ent == null
        ? null
        : _friendlyPlanName(ent.productIdentifier, _activePackage?.packageType);
    final price = _activePackage?.storeProduct.priceString;
    final billingSuffix = ent == null
        ? ''
        : _billingSuffix(_activePackage?.packageType, ent.productIdentifier);
    final recurringLabel = price == null
        ? null
        : billingSuffix.isEmpty
            ? price
            : '$price $billingSuffix';
    final storeName = ent == null ? null : _storeLabel(ent.store);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Gerenciar assinatura',
          style: theme.headlineSmall.override(color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!hasAccess || ent == null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Carregando informações da assinatura…',
                      style: theme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              'Plano atual',
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
                      planName ?? 'Dulang Premium',
                      style: theme.titleSmall.override(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (recurringLabel != null)
                      Text(
                        ent.periodType == PeriodType.trial
                            ? 'Após o teste grátis: $recurringLabel'
                            : recurringLabel,
                        style: theme.bodyMedium.override(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        _periodLabel(ent.periodType),
                        style: theme.bodyMedium,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Loja: $storeName',
                      style: theme.bodySmall.override(color: theme.secondaryText),
                    ),
                    if (_formatExpirationPt(ent.expirationDate) != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        ent.willRenew
                            ? 'Renova em ${_formatExpirationPt(ent.expirationDate)}'
                            : 'Acesso até ${_formatExpirationPt(ent.expirationDate)}',
                        style: theme.bodyMedium.override(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gerenciar na loja',
              style: theme.titleMedium.override(color: theme.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              defaultTargetPlatform == TargetPlatform.iOS
                  ? 'Siga para a App Store para desativar a renovação automática, trocar de plano ou ver recibos.'
                  : 'Siga para o Google Play para desativar a renovação automática, trocar de plano ou ver recibos.',
              style: theme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _opening
                  ? null
                  : () => _openStoreManagement(info?.managementURL),
              icon: _opening
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.open_in_new_rounded),
              label: Text(_opening ? 'Abrindo…' : 'Abrir na loja'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.tertiary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
