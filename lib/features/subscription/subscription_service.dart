import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/environment_values.dart';
import 'access_code_service.dart';
import 'subscription_constants.dart';

/// Estado global da assinatura (RevenueCat). Identidade de compra = conta da loja; restaurar compras no mesmo ou outro aparelho.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();

  static final SubscriptionService instance = SubscriptionService._();

  CustomerInfo? _customerInfo;
  bool _configured = false;

  /// Usado como [refreshListenable] no GoRouter **em vez de** [SubscriptionService] diretamente.
  ///
  /// O SDK do RevenueCat atualiza [CustomerInfo] em toda retomada do app
  /// (applicationDidBecomeActive). Se [SubscriptionService] fosse o refreshListenable,
  /// cada retomada dispararia [GoRouter.go(currentUri)] durante a transição do iOS
  /// → rebuild de NavBarPage no meio do frame de retomada → crash nativo.
  ///
  /// Este notifier só muda quando [hasPremiumAccess] realmente altera de valor,
  /// garantindo que o GoRouter só re-avalia rotas em eventos semanticamente relevantes
  /// (compra, restauração, cupom, expiração) — nunca em refreshes de rotina.
  final ValueNotifier<bool> premiumStatusNotifier = ValueNotifier(false);

  void _syncPremiumNotifier() {
    final current = hasPremiumAccess;
    if (premiumStatusNotifier.value != current) {
      premiumStatusNotifier.value = current;
    }
  }

  bool get isConfigured => _configured;

  /// Só em debug: força [hasPremiumAccess] a retornar `false` (simula sem premium).
  static bool debugBypassPremium = false;

  /// Só em debug: força [hasPremiumAccess] a retornar `true` (simula premium).
  static bool debugForcePremium = false;

  void debugToggleBypass() {
    if (!kDebugMode) return;
    debugBypassPremium = !debugBypassPremium;
    if (debugBypassPremium) debugForcePremium = false;
    notifyListeners();
  }

  void debugToggleForcePremium() {
    if (!kDebugMode) return;
    debugForcePremium = !debugForcePremium;
    if (debugForcePremium) debugBypassPremium = false;
    notifyListeners();
  }

  /// Assinatura paga ou período de teste/introdução ativo para o entitlement premium.
  bool get hasPremiumAccess {
    if (kDebugMode && debugForcePremium) return true;
    if (kDebugMode && debugBypassPremium) return false;
    if (AccessCodeService.instance.isGranted) return true;
    final id = SubscriptionConstants.premiumEntitlementId;
    final e = _customerInfo?.entitlements.all[id];
    return e?.isActive == true;
  }

  /// Premium via loja (RevenueCat) com entitlement ativo — **não** inclui cupom local.
  /// Use para “Gerenciar assinatura” e link `managementURL` da loja.
  bool get hasActiveStorePremiumEntitlement {
    if (kDebugMode && debugBypassPremium) return false;
    final id = SubscriptionConstants.premiumEntitlementId;
    return _customerInfo?.entitlements.all[id]?.isActive == true;
  }

  CustomerInfo? get customerInfo => _customerInfo;

  bool get _supportsNativeStore {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String _apiKey(FFDevEnvironmentValues env) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return env.revenueCatIosKey;
      case TargetPlatform.android:
        return env.revenueCatAndroidKey;
      default:
        return '';
    }
  }

  Future<void> initRevenueCat(FFDevEnvironmentValues env) async {
    if (!_supportsNativeStore) return;

    final key = _apiKey(env);
    if (key.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'SubscriptionService: chave RevenueCat vazia para esta plataforma; compras desativadas.',
        );
      }
      return;
    }

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
    await Purchases.configure(PurchasesConfiguration(key));
    _configured = true;

    Purchases.addCustomerInfoUpdateListener((info) {
      _customerInfo = info;
      notifyListeners();
      // Só dispara o GoRouter quando o status premium muda de fato.
      _syncPremiumNotifier();
    });

    await refreshCustomerInfo();
  }

  Future<void> refreshCustomerInfo() async {
    if (!_configured) return;
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
      _syncPremiumNotifier();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SubscriptionService.refreshCustomerInfo: $e');
      }
    }
  }

  Future<Offerings?> getOfferings() async {
    if (!_configured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SubscriptionService.getOfferings: $e');
      }
      return null;
    }
  }

  /// Ordena [PackageType.monthly] / [PackageType.annual] primeiro; se a oferta
  /// usar pacotes `CUSTOM` no RevenueCat, infere por [StoreProduct.subscriptionPeriod],
  /// depois por palavras-chave no id do pacote/produto.
  static (Package?, Package?) _monthlyAndAnnualFromOffering(Offering? offering) {
    if (offering == null) return (null, null);
    Package? monthly;
    Package? annual;
    for (final p in offering.availablePackages) {
      if (p.packageType == PackageType.monthly) monthly ??= p;
      if (p.packageType == PackageType.annual) annual ??= p;
    }
    if (monthly != null && annual != null) {
      return (monthly, annual);
    }

    final ranked = <(Package, int)>[];
    for (final p in offering.availablePackages) {
      final d = _approxDaysFromSubscriptionPeriod(p.storeProduct.subscriptionPeriod);
      if (d != null) ranked.add((p, d));
    }
    ranked.sort((a, b) => a.$2.compareTo(b.$2));
    if (ranked.length >= 2) {
      monthly ??= ranked.first.$1;
      annual ??= ranked.last.$1;
    } else if (ranked.length == 1) {
      final single = ranked.first;
      if (monthly == null && annual == null) {
        if (single.$2 >= 280) {
          annual = single.$1;
        } else {
          monthly = single.$1;
        }
      } else if (monthly == null && single.$1 != annual) {
        monthly = single.$1;
      } else if (annual == null && single.$1 != monthly) {
        annual = single.$1;
      }
    }

    for (final p in offering.availablePackages) {
      final bundle = '${p.identifier} ${p.storeProduct.identifier}'.toLowerCase();
      final looksAnnual =
          bundle.contains('annual') || bundle.contains('year') || bundle.contains('anual');
      final looksMonthly = bundle.contains('month') || bundle.contains('mensal');
      if (looksAnnual) annual ??= p;
      if (looksMonthly) monthly ??= p;
    }
    return (monthly, annual);
  }

  static int? _approxDaysFromSubscriptionPeriod(String? period) {
    if (period == null || period.isEmpty) return null;
    final u = period.toUpperCase();
    final year = RegExp(r'P(\d+)Y').firstMatch(u)?.group(1);
    if (year != null) return (int.tryParse(year) ?? 1) * 365;
    final month = RegExp(r'P(\d+)M').firstMatch(u)?.group(1);
    if (month != null && !u.contains('T')) {
      return (int.tryParse(month) ?? 1) * 30;
    }
    final week = RegExp(r'P(\d+)W').firstMatch(u)?.group(1);
    if (week != null) return (int.tryParse(week) ?? 1) * 7;
    final day = RegExp(r'P(\d+)D').firstMatch(u)?.group(1);
    if (day != null) return int.tryParse(day);
    return null;
  }

  static Package? monthlyPackage(Offering? offering) =>
      _monthlyAndAnnualFromOffering(offering).$1;

  static Package? annualPackage(Offering? offering) =>
      _monthlyAndAnnualFromOffering(offering).$2;

  static const Duration _purchaseTimeout = Duration(seconds: 120);

  Future<void> purchasePackage(Package pkg) async {
    if (!_configured) return;
    final info = await Purchases.purchasePackage(pkg).timeout(_purchaseTimeout);
    _customerInfo = info;
    notifyListeners();
    _syncPremiumNotifier();
  }

  /// Texto para exibir ao usuário (SnackBar) a partir de [PlatformException] da loja/RC.
  static String userMessageForPurchaseError(PlatformException e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Compra cancelada.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Este plano não está disponível para esta conta ou região da loja no momento. Você pode usar o plano gratuito (card “Plano gratuito”, botão Continuar) ou tentar outra conta Google Play.';
      case PurchasesErrorCode.storeProblemError:
        return 'A Google Play respondeu com erro. Tente de novo em alguns minutos ou use o plano gratuito no card acima.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Esta conta ou aparelho não pode comprar agora (restrição da loja).';
      case PurchasesErrorCode.networkError:
        return 'Sem conexão estável. Verifique a internet e tente de novo.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'A loja não aceitou o pedido. Atualize o app e a Play Store e tente de novo.';
      default:
        final raw = e.message ?? '';
        final lower = raw.toLowerCase();
        if (lower.contains('could not be found') ||
            lower.contains('item you were attempting') ||
            lower.contains('item unavailable')) {
          return 'A loja não encontrou este produto (publicação, conta ou região). Use o plano gratuito no card “Plano gratuito” ou tente outra conta Google Play.';
        }
        if (raw.isNotEmpty) return raw;
        return 'Não foi possível concluir a compra. Tente de novo.';
    }
  }

  /// Compra cancelada pela loja ou pelo usuário.
  bool isUserCancelled(Object error) {
    if (error is! PlatformException) return false;
    return PurchasesErrorHelper.getErrorCode(error) ==
        PurchasesErrorCode.purchaseCancelledError;
  }

  Future<void> restorePurchases() async {
    if (!_configured) return;
    final info = await Purchases.restorePurchases();
    _customerInfo = info;
    notifyListeners();
    _syncPremiumNotifier();
  }
}
