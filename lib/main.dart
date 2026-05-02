import 'dart:async' show Timer, unawaited;
import 'dart:ui' show PlatformDispatcher;

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '/features/parental/parental_service.dart';
import '/features/parental/pin_dialog.dart';
import '/pages/configuracoes/alterar_pin_widget.dart';
import '/features/profiles/child_profile_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/features/subscription/freemium_service.dart';
import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'index.dart';

void _installGlobalErrorLogging() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[Dulang FlutterError] ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint('[Dulang FlutterError stack]\n${details.stack}');
    }
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[Dulang async] $error\n$stack');
    return true;
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorLogging();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  final environmentValues = FFDevEnvironmentValues();
  await environmentValues.initialize();

  await Supabase.initialize(
    url: environmentValues.supabaseUrl,
    anonKey: environmentValues.supabaseAnonKey,
  );

  await FreemiumService.instance.init();
  await SubscriptionService.instance.initRevenueCat(environmentValues);

  await FlutterFlowTheme.initialize();

  // Defaults para não-premium: tema claro + controles parentais desativados.
  // Controles parentais são exclusivos do premium; freemium só usa o 1h/dia do FreemiumService.
  if (!SubscriptionService.instance.hasPremiumAccess) {
    if (FlutterFlowTheme.themeMode != ThemeMode.light) {
      FlutterFlowTheme.saveThemeMode(ThemeMode.light);
    }
    await ParentalService.setAccessWindowEnabled(false);
    await ParentalService.setDailyLimitEnabled(false);
  }

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();
  await ChildProfileService.instance.syncActiveProfileWithStoredList();

  final onboardingDone = await ParentalService.isOnboardingDone();
  AppStateNotifier.instance.onboardingDone = onboardingDone;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => appState),
      ChangeNotifierProvider.value(value: SubscriptionService.instance),
      ChangeNotifierProvider.value(value: FreemiumService.instance),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  bool displaySplashImage = true;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    Future.delayed(Duration(milliseconds: 1000),
        () => safeSetState(() => _appStateNotifier.stopShowingSplashImage()));
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  /// Troca o [ThemeMode] do [MaterialApp] **após** o frame atual.
  ///
  /// Atualizar o ancestral no mesmo frame do `onTap` do [InkWell] (Aparência)
  /// pode disparar assert esporádico `renderObject.child == child` ao combinar
  /// com splash / tema / [AnimatedContainer] nos tiles.
  void setThemeMode(ThemeMode mode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });
    });
  }

  /// Preferência de tema exibida pela UI (mantida em lockstep com [MaterialApp.themeMode]).
  /// Não usar [FlutterFlowTheme.themeMode] em telas para “selecionado”: o persistido em disco
  /// pode atrasar uma leitura após [setString].
  ThemeMode get themePreference => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dulang',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('pt'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFA130),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFA130),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> with WidgetsBindingObserver {
  String _currentPageName = 'Dulang';
  late Widget? _currentPage;
  /// Marca o último instante em que creditamos minutos pelo ticker (uso em primeiro plano).
  DateTime? _lastUsageAccountedAt;
  Timer? _foregroundUsageTicker;
  bool _playbackLocked = false;
  bool _freemiumLimitReached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _enforceFreemiumTheme();
      _startForegroundUsageAccounting();
      await _checkParentalLimits();
      await _openProfileSelectionIfNeeded();
    });
  }

  void _enforceFreemiumTheme() {
    if (!SubscriptionService.instance.hasPremiumAccess &&
        MyApp.of(context).themePreference != ThemeMode.light) {
      MyApp.of(context).setThemeMode(ThemeMode.light);
    }
  }

  Future<void> _showInAppMessagesIfNeeded() async {
    if (!SubscriptionService.instance.isConfigured) return;
    try {
      await Purchases.showInAppMessages();
    } catch (_) {
      // Silencioso — o dialog do sistema é opcional.
    }
  }

  /// Abre a seleção de perfil se não houver criança definida (ou pós-onboarding) e
  /// se a rota ainda não estiver aberta.
  Future<void> _openProfileSelectionIfNeeded() async {
    final pending = await ParentalService.consumePendingProfilePicker();
    final profiles = await ChildProfileService.instance.loadProfiles();
    if (!mounted) return;
    if (ChildProfileService.instance.isProfilePickerRouteOpen) {
      return;
    }
    if (pending || profiles.isEmpty) {
      context.pushNamed(SelecionarPerfilWidget.routeName);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopForegroundUsageAccounting();
    unawaited(_flushPartialForegroundUsage());
    super.dispose();
  }

  /// Conta minutos de uso com o app em primeiro plano (além do que já entra ao ir para segundo plano).
  void _startForegroundUsageAccounting() {
    _foregroundUsageTicker?.cancel();
    _lastUsageAccountedAt = DateTime.now();
    _foregroundUsageTicker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(_tickForegroundUsageMinute()),
    );
  }

  void _stopForegroundUsageAccounting() {
    _foregroundUsageTicker?.cancel();
    _foregroundUsageTicker = null;
  }

  Future<void> _tickForegroundUsageMinute() async {
    await ParentalService.addUsedMinutes(1);
    if (FreemiumService.instance.isEnrolled &&
        !SubscriptionService.instance.hasPremiumAccess) {
      await FreemiumService.instance.addUsedMinutes(1);
    }
    _lastUsageAccountedAt = DateTime.now();
    await _checkParentalLimits();
  }

  /// Sobra desde o último tick de 1 minuto (ex.: usuário minimizou o app no meio do minuto).
  Future<void> _flushPartialForegroundUsage() async {
    if (_lastUsageAccountedAt == null) return;
    final secs = DateTime.now().difference(_lastUsageAccountedAt!).inSeconds;
    final mins = secs ~/ 60;
    if (mins > 0) {
      await ParentalService.addUsedMinutes(mins);
      if (FreemiumService.instance.isEnrolled &&
          !SubscriptionService.instance.hasPremiumAccess) {
        await FreemiumService.instance.addUsedMinutes(mins);
      }
    }
    _lastUsageAccountedAt = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startForegroundUsageAccounting();
      unawaited(_checkParentalLimits());
      unawaited(_openProfileSelectionIfNeeded());
      unawaited(_showInAppMessagesIfNeeded());
    } else if (state == AppLifecycleState.paused) {
      _stopForegroundUsageAccounting();
      unawaited(_flushPartialForegroundUsage());
    }
  }

  Future<void> _checkParentalLimits() async {
    if (!mounted) return;
    if (ParentalService.isOnVideoScreen) return;

    final inWindow = await ParentalService.isWithinAllowedAccessHours();
    final underParental = await ParentalService.isUnderDailyLimit();
    final parentalLocked = !inWindow || !underParental;

    final isFreemiumOnly = FreemiumService.instance.isEnrolled &&
        !SubscriptionService.instance.hasPremiumAccess;
    final underFreemium = isFreemiumOnly
        ? await FreemiumService.instance.isUnderDailyLimit()
        : true;
    final freemiumLimitReached = isFreemiumOnly && !underFreemium;

    final wasParentalLocked = _playbackLocked;
    final wasFreemiumLocked = _freemiumLimitReached;

    if (!mounted) return;
    setState(() {
      _playbackLocked = parentalLocked;
      _freemiumLimitReached = freemiumLimitReached;
    });

    if (parentalLocked && !wasParentalLocked) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(!inWindow ? 'Horário de uso' : 'Tempo do dia'),
          content: Text(
            !inWindow
                ? 'Está fora da janela permitida pelos pais. Os vídeos ficam bloqueados até o horário configurado em Ajustes.'
                : 'O tempo de uso diário configurado pelos pais foi atingido. Os vídeos ficam bloqueados até amanhã ou até um adulto ajustar em Ajustes.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (freemiumLimitReached && !wasFreemiumLocked) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sua hora acabou por hoje'),
          content: const Text(
            'Você usou 1 hora de Dulang hoje. O acesso volta automaticamente amanhã. Para uso ilimitado, assine o Premium.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendi'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pushNamed('DulangPremium');
              },
              child: const Text('Ver planos'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _onBackPressed() async {
    if (!mounted) return;
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String, Widget>{
      'Dulang': const DulangWidget(),
      'Favoritos': const FavoritosWidget(),
      'Historico': const HistoricoWidget(),
      'Configuracoes': const ConfiguracoesWidget(),
    };
    final keys = tabs.keys.toList();
    final currentIndex =
        keys.indexOf(_currentPageName).clamp(0, keys.length - 1);
    final tabBody = _currentPage ?? tabs[_currentPageName]!;
    final showPlaybackLock = _playbackLocked && currentIndex != 3;
    final showFreemiumLock = _freemiumLimitReached && currentIndex != 3;

    return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
              return;
            }
            await _onBackPressed();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
            body: Stack(
              fit: StackFit.expand,
              children: [
                tabBody,
                if (showPlaybackLock)
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.88),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 56,
                                  color: FlutterFlowTheme.of(context).tertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Pausa no Dulang',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Um adulto pode revisar horários e limites em Ajustes (ícone de engrenagem).',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        color: Colors.white70,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showFreemiumLock)
                  Positioned.fill(
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.92),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.hourglass_bottom_rounded,
                                size: 56,
                                color: FlutterFlowTheme.of(context).tertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sua hora acabou por hoje',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'O acesso volta automaticamente amanhã. Para uso ilimitado, assine o Premium.',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(color: Colors.white70),
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).tertiary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  minimumSize: const Size(200, 48),
                                ),
                                onPressed: () =>
                                    context.pushNamed('DulangPremium'),
                                child: const Text(
                                  'Ver planos Premium',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) async {
                final prev = currentIndex;
                if (i == 3) {
                  final pinResult = await showPinDialog(context);
                  if (!mounted) return;
                  if (pinResult == PinDialogResult.forgotPin) {
                    context.pushNamed(AlterarPinWidget.routeName);
                    return;
                  }
                  if (pinResult != PinDialogResult.verified) return;
                }
                safeSetState(() {
                  _currentPage = null;
                  _currentPageName = keys[i];
                });
                if (i == 0 || (prev == 3 && i != 3)) {
                  await _checkParentalLimits();
                }
              },
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              selectedItemColor: FlutterFlowTheme.of(context).tertiary,
              unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  activeIcon: Icon(Icons.history_rounded),
                  label: 'Histórico',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Ajustes',
                ),
              ],
            ),
          ),
        );
  }
}
