import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/environment_values.dart';
import 'subscription_constants.dart';

/// Estado global da assinatura (RevenueCat) + sincronização com usuário Supabase.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();

  static final SubscriptionService instance = SubscriptionService._();

  CustomerInfo? _customerInfo;
  bool _configured = false;

  bool get isConfigured => _configured;

  /// Assinatura paga ou período de teste/introdução ativo para o entitlement premium.
  bool get hasPremiumAccess {
    final id = SubscriptionConstants.premiumEntitlementId;
    final e = _customerInfo?.entitlements.all[id];
    return e?.isActive == true;
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
    });

    await refreshCustomerInfo();
  }

  Future<void> refreshCustomerInfo() async {
    if (!_configured) return;
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SubscriptionService.refreshCustomerInfo: $e');
      }
    }
  }

  /// Chamar após login/logout no Supabase (`Session?`).
  Future<void> onAuthSession(Session? session) async {
    if (!_configured) {
      _customerInfo = null;
      notifyListeners();
      return;
    }
    try {
      if (session?.user.id != null && session!.user.id.isNotEmpty) {
        await Purchases.logIn(session.user.id);
      } else {
        await Purchases.logOut();
      }
      await refreshCustomerInfo();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SubscriptionService.onAuthSession: $e');
      }
    }
    notifyListeners();
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

  static Package? monthlyPackage(Offering? offering) {
    if (offering == null) return null;
    for (final p in offering.availablePackages) {
      if (p.packageType == PackageType.monthly) return p;
    }
    return null;
  }

  static Package? annualPackage(Offering? offering) {
    if (offering == null) return null;
    for (final p in offering.availablePackages) {
      if (p.packageType == PackageType.annual) return p;
    }
    return null;
  }

  Future<void> purchasePackage(Package pkg) async {
    if (!_configured) return;
    final result = await Purchases.purchasePackage(pkg);
    _customerInfo = result.customerInfo;
    notifyListeners();
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
  }
}
