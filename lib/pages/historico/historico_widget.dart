import '/features/parental/parental_service.dart';
import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/supabase_service.dart';
import '/widgets/engagement_list_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HistoricoWidget extends StatelessWidget {
  const HistoricoWidget({super.key});

  static String routeName = 'Historico';
  static String routePath = '/historico';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: Text(
          'Histórico',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Limpar histórico?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                context.read<FFAppState>().clearHistory();
              }
            },
            child: Text(
              'Limpar',
              style: TextStyle(color: FlutterFlowTheme.of(context).tertiary),
            ),
          ),
        ],
      ),
      body: Consumer<FFAppState>(
        builder: (context, app, _) {
          final raw = app.history;
          if (raw.isEmpty) {
            return Center(
              child: Text(
                'Ainda não há vídeos assistidos.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
            );
          }
          final rows = raw
              .map((e) => VideoRow.fromEngagementMap(
                  Map<String, dynamic>.from(e as Map)))
              .whereType<VideoRow>()
              .toList();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final v = rows[i];
              return Material(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    if (await ParentalService.warnIfPlaybackBlocked(context)) {
                      return;
                    }
                    if (!context.mounted) return;
                    if (!SubscriptionService.instance.hasPremiumAccess) {
                      await context.pushNamed(DulangPremiumWidget.routeName);
                      return;
                    }
                    if (!context.mounted) return;
                    context.pushNamed(
                      DulangVideoWidget.routeName,
                      queryParameters: {
                        'url': serializeParam(
                          v.youtubeVideoId,
                          ParamType.String,
                        ),
                      }.withoutNulls,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        engagementListThumbnail(context, v),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.displayTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.readexPro(
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                v.displayChannelLabel,
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.play_circle_fill_rounded,
                          color: FlutterFlowTheme.of(context).tertiary,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
