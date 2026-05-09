import 'dart:async';

import 'package:flutter/foundation.dart';

import '/features/review/parent_review_prompt.dart';
import '/features/subscription/access_code_service.dart';
import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/aparencia/aparencia_widget.dart';
import '/pages/contato/contato_widget.dart';
import '/pages/dulang_premium/dulang_premium_codigo_info_widget.dart';
import '/pages/dulang_premium/dulang_premium_widget.dart';
import '/pages/dulang_premium/dulang_subscription_manage_widget.dart';
import '/pages/sobre_o_dulang/sobre_o_dulang_widget.dart';
import '/pages/termos_de_uso_e_politica_de_privacidade/termos_de_uso_e_politica_de_privacidade_widget.dart';
import '/pages/configuracoes/alterar_pin_widget.dart';
import '/pages/configuracoes/horarios_acesso_widget.dart';
import '/pages/selecionar_perfil/selecionar_perfil_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfiguracoesWidget extends StatefulWidget {
  const ConfiguracoesWidget({super.key});

  static String routeName = 'Configuracoes';
  static String routePath = '/configuracoes';

  @override
  State<ConfiguracoesWidget> createState() => _ConfiguracoesWidgetState();
}

class _ConfiguracoesWidgetState extends State<ConfiguracoesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ParentReviewPrompt.maybeRequestOnParentSettingsSurface());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: Text(
          'Configurações',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Consumer2<SubscriptionService, AccessCodeService>(
        builder: (context, sub, accessCodes, _) {
          accessCodes.isGranted;
          final showManageSubscription = sub.hasActiveStorePremiumEntitlement;
          final premiumPorCupom =
              accessCodes.isGranted && !showManageSubscription;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle(context, 'Família'),
              _tile(
                context,
                icon: Icons.switch_account_rounded,
                title: 'Quem está assistindo?',
                subtitle: 'Escolher, criar, renomear ou remover perfil',
                onTap: () => context.pushNamed(SelecionarPerfilWidget.routeName),
              ),
              _tile(
                context,
                icon: Icons.lock_reset_rounded,
                title: 'Alterar PIN parental',
                subtitle: 'Biometria ou PIN do aparelho ao salvar',
                onTap: () => context.pushNamed(AlterarPinWidget.routeName),
              ),
              _tile(
                context,
                icon: Icons.schedule_rounded,
                title: 'Horários e tempo de uso',
                subtitle: 'Janela do dia e limite diário',
                locked: false,
                onTap: () => context.pushNamed(HorariosAcessoWidget.routeName),
              ),
              _tile(
                context,
                icon: Icons.palette_outlined,
                title: 'Aparência',
                subtitle: 'Claro, escuro ou sistema',
                onTap: () => context.pushNamed(AparenciaWidget.routeName),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Informações'),
              _tile(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Sobre o Dulang',
                onTap: () => context.pushNamed(SobreODulangWidget.routeName),
              ),
              _tile(
                context,
                icon: Icons.policy_outlined,
                title: 'Termos e privacidade',
                onTap: () => context.pushNamed(
                    TermosDeUsoEPoliticaDePrivacidadeWidget.routeName),
              ),
              _tile(
                context,
                icon: Icons.mail_outline_rounded,
                title: 'Contato',
                onTap: () => context.pushNamed(ContatoWidget.routeName),
              ),
              _tile(
                context,
                icon: Icons.workspace_premium_outlined,
                title: showManageSubscription
                    ? 'Gerenciar assinatura'
                    : 'Dulang Premium',
                onTap: () {
                  if (showManageSubscription) {
                    context.pushNamed(
                        DulangSubscriptionManageWidget.routeName);
                  } else if (premiumPorCupom) {
                    context.pushNamed(DulangPremiumCodigoInfoWidget.routeName);
                  } else {
                    context.pushNamed(DulangPremiumWidget.routeName);
                  }
                },
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 32),
                _sectionTitle(context, '🛠 Debug'),
                _debugTile(
                  context,
                  title: SubscriptionService.debugForcePremium
                      ? 'PREMIUM FORÇADO — toque para desativar'
                      : 'Simular premium',
                  color: SubscriptionService.debugForcePremium
                      ? Colors.green
                      : Colors.grey,
                  onTap: () =>
                      SubscriptionService.instance.debugToggleForcePremium(),
                ),
                _debugTile(
                  context,
                  title: SubscriptionService.debugBypassPremium
                      ? 'Premium: BYPASSADO — toque para restaurar'
                      : 'Simular sem premium',
                  color: SubscriptionService.debugBypassPremium
                      ? Colors.orange
                      : Colors.grey,
                  onTap: () =>
                      SubscriptionService.instance.debugToggleBypass(),
                ),
                _debugTile(
                  context,
                  title: 'Limpar flag local do código de acesso (debug)',
                  color: Colors.redAccent,
                  onTap: () => AccessCodeService.instance.debugClearLocal(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        t,
        style: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily: 'Readex Pro',
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
      ),
    );
  }

  Widget _debugTile(
    BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        leading: Icon(Icons.bug_report_outlined, color: color),
        title: Text(title,
            style: FlutterFlowTheme.of(context)
                .bodyLarge
                .override(color: color, fontWeight: FontWeight.w700)),
        onTap: onTap,
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool locked = false,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.tertiary),
        title: Text(title, style: theme.bodyLarge),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: theme.bodySmall),
        trailing: locked
            ? Icon(Icons.lock_outline_rounded,
                color: theme.secondaryText, size: 20)
            : Icon(Icons.chevron_right_rounded, color: theme.secondaryText),
        onTap: onTap,
      ),
    );
  }
}
