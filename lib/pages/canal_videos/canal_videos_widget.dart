import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lista de vídeos filtrada por canal (nome) ou todos se [channelName] vazio.
class CanalVideosWidget extends StatefulWidget {
  const CanalVideosWidget({
    super.key,
    this.channelName,
  });

  final String? channelName;

  static const String routeName = 'CanalVideos';
  static const String routePath = '/canalVideos';

  @override
  State<CanalVideosWidget> createState() => _CanalVideosWidgetState();
}

class _CanalVideosWidgetState extends State<CanalVideosWidget> {
  late final Future<List<VideoRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.instance.getVideos();
  }

  @override
  Widget build(BuildContext context) {
    final label = (widget.channelName == null || widget.channelName!.isEmpty)
        ? 'Todos os vídeos'
        : widget.channelName!;
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          label,
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
      ),
      body: FutureBuilder<List<VideoRow>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var list = snap.data!;
          final cn = widget.channelName;
          if (cn != null && cn.isNotEmpty) {
            list = list.where((v) => v.channelName == cn).toList();
          }
          if (list.isEmpty) {
            return Center(
              child: Text(
                'Nenhum vídeo neste canal.',
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final v = list[i];
              return Material(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    ParentalService.warnIfPlaybackBlocked(context)
                        .then((blocked) {
                      if (blocked || !context.mounted) return;
                      context.pushNamed(
                        DulangVideoWidget.routeName,
                        queryParameters: {
                          'url': serializeParam(
                            v.youtubeVideoId,
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            v.thumbnailHigh,
                            width: 120,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120,
                              height: 68,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.readexPro(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              Text(
                                v.channelName,
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.play_circle_fill_rounded,
                          color: FlutterFlowTheme.of(context).tertiary,
                          size: 36,
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
