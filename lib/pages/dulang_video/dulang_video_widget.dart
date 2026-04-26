import '/services/supabase_service.dart';
import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_youtube_player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dulang_video_model.dart';
export 'dulang_video_model.dart';

class DulangVideoWidget extends StatefulWidget {
  const DulangVideoWidget({
    super.key,
    required this.url,
  });

  final String? url;

  static String routeName = 'DulangVideo';
  static String routePath = '/dulangVideo';

  @override
  State<DulangVideoWidget> createState() => _DulangVideoWidgetState();
}

class _DulangVideoWidgetState extends State<DulangVideoWidget>
    with WidgetsBindingObserver {
  late DulangVideoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final Future<List<VideoRow>> _videosFuture;

  void _onInPlayerVideoSelected(String videoId) {
    if (!mounted) return;
    if (videoId.isEmpty) return;

    context.goNamed(
      DulangVideoWidget.routeName,
      queryParameters: {
        'url': serializeParam(
          videoId,
          ParamType.String,
        ),
      }.withoutNulls,
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DulangVideoModel());
    _videosFuture = SupabaseService.instance.getVideos();
    WidgetsBinding.instance.addObserver(this);
    ParentalService.isOnVideoScreen = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ParentalService.isOnVideoScreen = false;
    _model.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Garante que o flag está correto ao retornar ao app enquanto no player.
    if (state == AppLifecycleState.resumed) {
      ParentalService.isOnVideoScreen = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoRow>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final videos = snapshot.data!;

        return YoutubeFullScreenWrapper(
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              // Pop normal: volta ao feed sem pedir PIN.
              context.safePop();
            },
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                appBar: responsiveVisibility(
                              context: context,
                              tabletLandscape: false,
                            ) &&
                            (MediaQuery.sizeOf(context).width > kBreakpointSmall
                                ? false
                                : true)
                    ? AppBar(
                        backgroundColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
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
                          onPressed: () => context.safePop(),
                        ),
                        actions: [],
                        flexibleSpace: FlexibleSpaceBar(
                          title: Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: Text(
                                '',
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .headlineMedium
                                                .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
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
                            ),
                          ),
                          background: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/dulang1_bgtransparent.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          centerTitle: true,
                          expandedTitleScale: 1.0,
                        ),
                        elevation: 2.0,
                      )
                    : null,
                body: SafeArea(
                  top: true,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Material(
                            color: Colors.transparent,
                            elevation: 2.0,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: FlutterFlowYoutubePlayer(
                                url: widget.url!,
                                width: double.infinity,
                                height: double.infinity,
                                autoPlay: true,
                                looping: true,
                                mute: false,
                                showControls: false,
                                showFullScreen: true,
                                strictRelatedVideos: true,
                                onVideoIdChanged: _onInPlayerVideoSelected,
                              ),
                            ),
                          ),
                        ),
                        if ((MediaQuery.sizeOf(context).width > kBreakpointSmall
                                ? false
                                : true) &&
                            responsiveVisibility(
                              context: context,
                              tabletLandscape: false,
                            ))
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children:
                                      List.generate(videos.length, (videoIndex) {
                                    final videoItem = videos[videoIndex];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        // goNamed substitui a rota atual pelo novo vídeo.
                                        context.goNamed(
                                          DulangVideoWidget.routeName,
                                          queryParameters: {
                                            'url': serializeParam(
                                              videoItem.youtubeVideoId,
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.network(
                                                    videoItem.thumbnailHigh,
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        1.0,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      width: double.infinity,
                                                      height: 120.0,
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: const Icon(
                                                          Icons
                                                              .play_circle_outline,
                                                          size: 40,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 36.0,
                                                    height: 36.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                      child: Image.network(
                                                        videoItem
                                                            .thumbnailDefault,
                                                        width: 36.0,
                                                        height: 36.0,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_,
                                                                __,
                                                                ___) =>
                                                            const CircleAvatar(
                                                                radius: 18,
                                                                child: Icon(
                                                                    Icons
                                                                        .tv,
                                                                    size: 18)),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          videoItem.title,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .readexPro(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                        ),
                                                        Text(
                                                          videoItem.channelName,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .readexPro(),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).divide(SizedBox(height: 8.0)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
