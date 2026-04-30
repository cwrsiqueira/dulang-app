import '/app_build_metadata.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'termos_de_uso_e_politica_de_privacidade_model.dart';
export 'termos_de_uso_e_politica_de_privacidade_model.dart';

/// Termos de uso
class TermosDeUsoEPoliticaDePrivacidadeWidget extends StatefulWidget {
  const TermosDeUsoEPoliticaDePrivacidadeWidget({super.key});

  static String routeName = 'TermosDeUsoEPoliticaDePrivacidade';
  static String routePath = '/termosDeUsoEPoliticaDePrivacidade';

  @override
  State<TermosDeUsoEPoliticaDePrivacidadeWidget> createState() =>
      _TermosDeUsoEPoliticaDePrivacidadeWidgetState();
}

class _TermosDeUsoEPoliticaDePrivacidadeWidgetState
    extends State<TermosDeUsoEPoliticaDePrivacidadeWidget> {
  late TermosDeUsoEPoliticaDePrivacidadeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => TermosDeUsoEPoliticaDePrivacidadeModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: responsiveVisibility(
          context: context,
          tabletLandscape: false,
        )
            ? AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primaryText,
                automaticallyImplyLeading: false,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 60.0,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 30.0,
                  ),
                  onPressed: () async {
                    context.pop();
                  },
                ),
                title: Text(
                  '',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).alternate,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                ),
                actions: [],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/dulang1_bgtransparent.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                centerTitle: false,
                elevation: 2.0,
              )
            : null,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                        child: Text(
                          'Termos de Uso e Política de Privacidade',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.readexPro(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '\n1. Introdução\nBem-vindo ao Dulang — curadoria de vídeos em inglês para crianças. Este documento reúne os Termos de Uso e a Política de Privacidade do aplicativo Dulang (Android e iOS). Ao usar o Dulang, o responsável legal concorda com o que está descrito aqui.\n\n2. Público e uso supervisionado\nO Dulang é voltado ao público infantil e deve ser configurado e supervisionado por um adulto responsável. O PIN parental disponível no app é uma ferramenta de controle exclusiva do responsável — não é acessível pela criança.\n\n3. Dados armazenados no dispositivo\nFavoritos, histórico de reprodução, perfis infantis, preferências de tema e o PIN parental são armazenados localmente no seu aparelho. Esses dados não são enviados aos nossos servidores como perfil de navegação. O PIN parental é armazenado de forma segura (armazenamento criptografado no dispositivo).\n\n4. O que não coletamos\nO Dulang não coleta dados pessoais de crianças. Não exibimos publicidade no app. Não rastreamos comportamento para fins publicitários. Não vendemos dados.\n\n5. Conta e assinaturas\nO Dulang não exige criação de conta para usar o catálogo. As assinaturas Dulang Premium são gerenciadas diretamente pela Google Play ou App Store, na conta do responsável. O controle de assinatura é processado pelo RevenueCat. Consulte a política de privacidade do RevenueCat em revenuecat.com.\n\n6. Uso da API do YouTube\nO Dulang usa a API do YouTube para exibir vídeos, miniaturas e metadados de canais curados. O conteúdo audiovisual pertence aos criadores e à plataforma YouTube. A reprodução ocorre dentro do app — a criança não navega livremente na internet pelo Dulang. Consulte a Política de Privacidade do Google em policies.google.com.\n\n7. Dados mínimos de operação\nPara sincronização do catálogo, nossa infraestrutura (Supabase) pode processar dados técnicos mínimos — como versão do app e identificadores anônimos de dispositivo — exclusivamente para operar o serviço. Esses dados não são vinculados a identidade pessoal.\n\n8. LGPD e seus direitos\nNa medida em que houver tratamento de dados pessoais, você pode solicitar confirmação, acesso, correção ou exclusão de dados pelo canal de contato abaixo, nos termos da Lei nº 13.709/2018 (LGPD). Solicitações relacionadas a dados de crianças devem ser feitas pelo responsável legal.\n\n9. Segurança\nEmpregamos boas práticas para proteger o app: armazenamento seguro do PIN parental, chaves de API protegidas e comunicações criptografadas. Nenhum sistema é 100% invulnerável — mantenha o sistema operacional atualizado.\n\n10. Alterações\nPodemos atualizar esta política. Mudanças relevantes serão comunicadas pelo app ou por outros meios razoáveis. A versão mais recente estará sempre disponível na Play Store e no menu Termos e Privacidade do app.\n\n11. Contato\nDúvidas sobre privacidade ou estes termos: contato@carlosdev.com.br ou o canal de contato na área Contato do aplicativo.\n\n© Dulang. Todos os direitos reservados.\n',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.readexPro(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const AppLegalFootnote(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
