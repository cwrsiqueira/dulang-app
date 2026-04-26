import '/flutter_flow/flutter_flow_theme.dart';
import '/services/supabase_service.dart';
import 'package:flutter/material.dart';

/// Miniatura de favorito/histórico com fallback YouTube e placeholder.
Widget engagementListThumbnail(
  BuildContext context,
  VideoRow v, {
  double width = 72,
  double height = 108,
}) {
  final url = v.displayThumbnailUrl;
  if (url.isEmpty) {
    return _engagementPlaceholder(context, v, width, height);
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          _engagementPlaceholder(context, v, width, height),
    ),
  );
}

Widget _engagementPlaceholder(
  BuildContext context,
  VideoRow v,
  double width,
  double height,
) {
  final tertiary = FlutterFlowTheme.of(context).tertiary;
  final secondary = FlutterFlowTheme.of(context).secondary;
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tertiary.withValues(alpha: 0.55),
            secondary.withValues(alpha: 0.4),
            FlutterFlowTheme.of(context).primary.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline_rounded,
            size: width * 0.38,
            color: Colors.white.withValues(alpha: 0.95),
          ),
          if (v.youtubeVideoId.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                v.youtubeVideoId,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
