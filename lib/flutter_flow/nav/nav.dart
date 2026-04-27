import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/schema/structs/index.dart';

import '/features/auth/login_widget.dart';
import '/features/parental/onboarding_widget.dart';
import '/features/subscription/subscription_service.dart';
import '/main.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';
import '/pages/configuracoes/alterar_pin_widget.dart';
import '/pages/configuracoes/horarios_acesso_widget.dart';
import '/pages/configuracoes/perfis_gerenciar_widget.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;
  bool onboardingDone = false;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }

  void setOnboardingDone() {
    onboardingDone = true;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) {
  final refresh = Listenable.merge([
    appStateNotifier,
    SubscriptionService.instance,
  ]);

  return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: refresh,
      navigatorKey: appNavigatorKey,
      redirect: (context, state) {
        final notifier = appStateNotifier;
        if (notifier.showSplashImage) {
          return null;
        }

        final path = state.uri.path;

        if (!notifier.onboardingDone) {
          if (path == LoginWidget.routePath) {
            return '/';
          }
          return null;
        }

        final session = Supabase.instance.client.auth.currentSession;
        const publicWhenLoggedOut = <String>{
          LoginWidget.routePath,
          TermosDeUsoEPoliticaDePrivacidadeWidget.routePath,
          SobreODulangWidget.routePath,
          ContatoWidget.routePath,
        };

        if (session == null) {
          if (publicWhenLoggedOut.contains(path)) {
            return null;
          }
          if (path != LoginWidget.routePath) {
            return LoginWidget.routePath;
          }
          return null;
        }

        if (path == LoginWidget.routePath) {
          return '/';
        }

        return null;
      },
      errorBuilder: (context, state) => appStateNotifier.showSplashImage
          ? Builder(
              builder: (context) => Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/dulang.webp',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : appStateNotifier.onboardingDone
              ? NavBarPage()
              : const OnboardingWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.showSplashImage
              ? Builder(
                  builder: (context) => Container(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/dulang.webp',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : appStateNotifier.onboardingDone
                  ? NavBarPage()
                  : const OnboardingWidget(),
        ),
        FFRoute(
          name: LoginWidget.routeName,
          path: LoginWidget.routePath,
          builder: (context, params) => const LoginWidget(),
        ),
        FFRoute(
          name: TermosDeUsoEPoliticaDePrivacidadeWidget.routeName,
          path: TermosDeUsoEPoliticaDePrivacidadeWidget.routePath,
          builder: (context, params) =>
              TermosDeUsoEPoliticaDePrivacidadeWidget(),
        ),
        FFRoute(
          name: SobreODulangWidget.routeName,
          path: SobreODulangWidget.routePath,
          builder: (context, params) => const SobreODulangWidget(),
        ),
        FFRoute(
          name: DulangWidget.routeName,
          path: DulangWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? NavBarPage(initialPage: 'Dulang')
              : const DulangWidget(),
        ),
        FFRoute(
          name: DulangVideoWidget.routeName,
          path: DulangVideoWidget.routePath,
          builder: (context, params) {
            final url = params.getParam(
              'url',
              ParamType.String,
            );
            return DulangVideoWidget(
              key: ValueKey(url ?? 'none'),
              url: url,
            );
          },
        ),
        FFRoute(
          name: ContatoWidget.routeName,
          path: ContatoWidget.routePath,
          builder: (context, params) => const ContatoWidget(),
        ),
        FFRoute(
          name: DulangPremiumWidget.routeName,
          path: DulangPremiumWidget.routePath,
          builder: (context, params) => const DulangPremiumWidget(),
        ),
        FFRoute(
          name: CanalVideosWidget.routeName,
          path: CanalVideosWidget.routePath,
          builder: (context, params) {
            final channelName = params.getParam(
              'channelName',
              ParamType.String,
            );
            return CanalVideosWidget(channelName: channelName);
          },
        ),
        FFRoute(
          name: AparenciaWidget.routeName,
          path: AparenciaWidget.routePath,
          builder: (context, params) => const AparenciaWidget(),
        ),
        FFRoute(
          name: AlterarPinWidget.routeName,
          path: AlterarPinWidget.routePath,
          builder: (context, params) => const AlterarPinWidget(),
        ),
        FFRoute(
          name: HorariosAcessoWidget.routeName,
          path: HorariosAcessoWidget.routePath,
          builder: (context, params) => const HorariosAcessoWidget(),
        ),
        FFRoute(
          name: PerfisGerenciarWidget.routeName,
          path: PerfisGerenciarWidget.routePath,
          builder: (context, params) => const PerfisGerenciarWidget(),
        ),
        FFRoute(
          name: SelecionarPerfilWidget.routeName,
          path: SelecionarPerfilWidget.routePath,
          builder: (context, params) => const SelecionarPerfilWidget(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
      observers: [routeObserver],
    );
}

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
