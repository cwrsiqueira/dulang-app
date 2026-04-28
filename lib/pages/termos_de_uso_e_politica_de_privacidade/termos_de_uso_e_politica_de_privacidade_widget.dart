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
                          '\n1. Introdução\nBem-vindo ao Dulang — inglês natural e divertido para crianças. Este documento reúne os Termos de Uso e a Política de Privacidade do aplicativo. Ao usar o Dulang, você concorda com o que está descrito aqui.\n\n2. Dados no dispositivo (favoritos, histórico e perfis locais)\nFavoritos, histórico de reprodução, perfis infantis e preferências parentais (como PIN e limites de uso) podem ser guardados apenas no seu aparelho, para melhorar a experiência. Esses dados não são enviados automaticamente aos nossos servidores como perfil de navegação; tratamos o mínimo necessário para o funcionamento do app.\n\n3. Conta e assinaturas\nQuando houver login ou compras por meio de lojas de aplicativos (Apple/Google) ou provedores como RevenueCat, aplicam-se também as políticas dessas plataformas.\n\n4. Uso de conteúdo do YouTube\nO Dulang usa a API de dados do YouTube para exibir miniaturas, títulos e metadados de vídeos publicados no YouTube. O conteúdo audiovisual pertence aos criadores e à plataforma YouTube; exibimos de acordo com as regras da API. Consulte a Política de Privacidade do Google/YouTube para o tratamento de dados pelo YouTube.\n\n5. LGPD e seus direitos\nNa medida em que houver tratamento de dados pessoais, você pode solicitar informações ou apoio pelo e-mail de contato indicado abaixo, nos termos da LGPD.\n\n6. Segurança\nEmpregamos boas práticas para proteger o app e integrações (por exemplo, armazenamento seguro do PIN parental no dispositivo). Nenhum sistema é 100% invulnerável; mantenha o sistema operacional atualizado.\n\n7. Alterações\nPodemos atualizar estes termos; mudanças relevantes serão comunicadas pelo app ou por outros meios razoáveis.\n\n8. Contato\nDúvidas sobre estes termos ou privacidade: use o canal de contato informado na área Contato do aplicativo.\n\n© Dulang. Todos os direitos reservados.\n',
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
