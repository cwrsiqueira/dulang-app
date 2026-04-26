import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dulang_premium_model.dart';
export 'dulang_premium_model.dart';

/// Paywall estilo streaming; integração RevenueCat em etapa futura.
class DulangPremiumWidget extends StatefulWidget {
  const DulangPremiumWidget({super.key});

  static String routeName = 'DulangPremium';
  static String routePath = '/dulangPremium';

  @override
  State<DulangPremiumWidget> createState() => _DulangPremiumWidgetState();
}

class _DulangPremiumWidgetState extends State<DulangPremiumWidget> {
  late DulangPremiumModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const _priceLabel = r'$9,97';
  static const _period = '/mês';

  static const _benefits = <(IconData, String)>[
    (Icons.favorite_rounded, 'Favoritos para salvar o que mais gostam'),
    (Icons.history_rounded, 'Histórico de tudo que já assistiram'),
    (Icons.verified_user_rounded, 'Bloqueio parental com PIN e limites'),
    (Icons.schedule_rounded, 'Horários de uso e tempo diário configuráveis'),
    (Icons.groups_rounded, 'Vários perfis de criança na mesma conta'),
    (Icons.video_library_rounded, 'Catálogo completo em inglês, sem sair do app'),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DulangPremiumModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _onSubscribePlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Assinaturas pela loja (RevenueCat) chegam em breve. Obrigado por apoiar o Dulang!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tertiary = theme.tertiary;
    final onCard = theme.primaryText;
    final onCardMuted = theme.secondaryText;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Dulang',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: tertiary,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Text(
            'Cancele quando quiser. Sem taxas escondidas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: onCardMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tertiary, width: 2),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tertiary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Acesso completo',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Plano mensal',
                  style: GoogleFonts.inter(
                    color: onCardMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _priceLabel,
                      style: GoogleFonts.inter(
                        color: onCard,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        _period,
                        style: GoogleFonts.inter(
                          color: onCardMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.check_circle, color: tertiary, size: 32),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Tudo o que o Dulang oferece hoje, com suporte contínuo ao aprendizado em inglês.',
                  style: GoogleFonts.inter(
                    color: onCardMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'O que está incluído',
                  style: GoogleFonts.inter(
                    color: onCard,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                for (final b in _benefits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(b.$1, color: tertiary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            b.$2,
                            style: GoogleFonts.inter(
                              color: onCard,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: tertiary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _onSubscribePlaceholder,
            child: Text(
              'Assinar agora',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
