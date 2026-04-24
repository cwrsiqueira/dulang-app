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
                      Text(
                        'Última atualização: Fevereiro de 2026',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.readexPro(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '\n1. Introdução\nBem-vindo ao Dulang - Inglês Natural e Divertido para Crianças. Este documento apresenta os Termos de Uso e a Política de Privacidade aplicáveis ao uso do nosso aplicativo. Ao utilizar nosso serviço, você concorda com os termos aqui descritos.\n\n2. Dados Coletados\nNão coletamos dados do usuário.\n\n3. Uso e Armazenamento dos Dados\nNão armazenamos dados doss usuários.\n\n4. Uso de Conteúdo do YouTube\nO Dulang utiliza a API de Dados do YouTube para exibir miniaturas e informações relacionadas a vídeos hospedados no YouTube.\n\nInformações fornecidas pela API: Miniaturas, títulos e descrições de vídeos são obtidos diretamente da API do YouTube.\nPropriedade do conteúdo: As miniaturas e informações dos vídeos pertencem aos respectivos criadores e estão protegidas por direitos autorais. Este aplicativo exibe essas informações exclusivamente como permitido pelos Termos de Serviço da API do YouTube.\nAo utilizar este aplicativo, você reconhece e concorda que:\n\nO conteúdo exibido está sujeito às políticas e termos do YouTube.\nPara mais informações sobre o tratamento de dados pelo YouTube, consulte a Política de Privacidade do YouTube.\n\n5. Direitos do Usuário\nDe acordo com a LGPD (Lei Geral de Proteção de Dados Pessoais), você tem o direito de ser informado caso existam coleta e armazenamento de dados do usuário. O que não é o caso do nosso aplicativo. Qualquer dúvida entre em contato conosco no e-mail:\nsuporte@carlosdev.com.br.\n\n6. Segurança dos Dados\nNão coletamos nem armazenamos dados dos usuários.\n\n7. Atualizações desta Política\nReservamo-nos o direito de atualizar esta Política de Privacidade a qualquer momento. Informaremos os usuários sobre alterações significativas através do próprio aplicativo ou por e-mail.\n\n8. Contato\nCaso tenha dúvidas, solicitações ou preocupações sobre nossos Termos de Uso ou Política de Privacidade, entre em contato com nosso suporte:\n\nE-mail: contato@carlosdev.com.br\n\n© 2024 Dulang. Todos os direitos reservados.\n',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
