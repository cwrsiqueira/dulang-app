import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/aparencia/aparencia_widget.dart';
import '/pages/contato/contato_widget.dart';
import '/pages/dulang_premium/dulang_premium_widget.dart';
import '/pages/sobre_o_dulang/sobre_o_dulang_widget.dart';
import '/pages/termos_de_uso_e_politica_de_privacidade/termos_de_uso_e_politica_de_privacidade_widget.dart';
import '/pages/configuracoes/alterar_pin_widget.dart';
import '/pages/configuracoes/horarios_acesso_widget.dart';
import '/pages/configuracoes/perfis_gerenciar_widget.dart';
import '/pages/selecionar_perfil/selecionar_perfil_widget.dart';
import 'package:flutter/material.dart';

class ConfiguracoesWidget extends StatelessWidget {
  const ConfiguracoesWidget({super.key});

  static String routeName = 'Configuracoes';
  static String routePath = '/configuracoes';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, 'Conta e família'),
          _tile(
            context,
            icon: Icons.switch_account_rounded,
            title: 'Quem está assistindo?',
            subtitle: 'Escolher perfil antes de ver a Home',
            onTap: () => context.pushNamed(SelecionarPerfilWidget.routeName),
          ),
          _tile(
            context,
            icon: Icons.people_outline_rounded,
            title: 'Gerenciar perfis',
            subtitle: 'Adicionar, remover e renomear',
            onTap: () => context.pushNamed(PerfisGerenciarWidget.routeName),
          ),
          _tile(
            context,
            icon: Icons.lock_reset_rounded,
            title: 'Alterar PIN parental',
            subtitle: 'Exige o PIN atual',
            onTap: () => context.pushNamed(AlterarPinWidget.routeName),
          ),
          _tile(
            context,
            icon: Icons.schedule_rounded,
            title: 'Horários e tempo de uso',
            subtitle: 'Janela do dia e limite diário',
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
            onTap: () =>
                context.pushNamed(TermosDeUsoEPoliticaDePrivacidadeWidget.routeName),
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
            title: 'Dulang Premium',
            onTap: () => context.pushNamed(DulangPremiumWidget.routeName),
          ),
        ],
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

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: FlutterFlowTheme.of(context).tertiary),
        title: Text(title, style: FlutterFlowTheme.of(context).bodyLarge),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: FlutterFlowTheme.of(context).bodySmall,
              ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
        onTap: onTap,
      ),
    );
  }
}
