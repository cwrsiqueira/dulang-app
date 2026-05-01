import 'dart:async';

import '/features/parental/parental_service.dart';
import '/features/subscription/freemium_service.dart';
import '/features/subscription/subscription_service.dart';
import '/features/profiles/child_profile_service.dart';
import '/services/supabase_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dulang_model.dart';
export 'dulang_model.dart';

class DulangWidget extends StatefulWidget {
  const DulangWidget({super.key});

  static String routeName = 'Dulang';
  static String routePath = '/dulang';

  @override
  State<DulangWidget> createState() => _DulangWidgetState();
}

class _DulangWidgetState extends State<DulangWidget> {
  late DulangModel _model;
  late Future<List<VideoRow>> _videosFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _profileGreeting = '';

  void _onActiveProfileListenable() {
    unawaited(_loadProfileGreeting());
  }

  Future<void> _loadProfileGreeting() async {
    final p = await ChildProfileService.instance.activeProfile();
    if (!mounted) return;
    setState(() {
      _profileGreeting = p == null ? '' : 'Olá, ${p.name}';
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DulangModel());
    _videosFuture = SupabaseService.instance.getVideos();
    ChildProfileService.instance.profileChangeCount
        .addListener(_onActiveProfileListenable);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.lockOrientation();
      await _loadProfileGreeting();
    });
  }

  @override
  void dispose() {
    ChildProfileService.instance.profileChangeCount
        .removeListener(_onActiveProfileListenable);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoRow>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Não foi possível carregar os vídeos agora.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verifique sua internet e tente novamente.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _videosFuture = SupabaseService.instance.getVideos();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final videos = snapshot.data!;
        if (videos.isEmpty) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Catálogo em atualização',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ainda não há vídeos disponíveis. Puxe para atualizar ou tente novamente em instantes.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _videosFuture = SupabaseService.instance.getVideos();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Atualizar catálogo'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final hero = videos[_stableHeroIndex(videos)];

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
                    backgroundColor:
                        FlutterFlowTheme.of(context).secondaryBackground,
                    automaticallyImplyLeading: false,
                    actions: [],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Align(
                        alignment: AlignmentDirectional(1.0, 1.0),
                        child: Text(
                          _profileGreeting,
                          textAlign: TextAlign.start,
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
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
                      background: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/dulang1_bgtransparent.png',
                            fit: BoxFit.contain,
                            alignment: Alignment(0.0, 0.0),
                          ),
                        ),
                      ),
                      centerTitle: false,
                      expandedTitleScale: 1.0,
                    ),
                    elevation: 2.0,
                  )
                : null,
            body: SafeArea(
              top: true,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _videosFuture = SupabaseService.instance.getVideos();
                  });
                  await _videosFuture;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(context, hero),
                        const SizedBox(height: 28),
                        ..._buildFeaturedSection(context, videos),
                        const SizedBox(height: 28),
                        Text(
                          'Canais',
                          style: FlutterFlowTheme.of(context).titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildChannelGrid(context, videos),
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

  /// Índice estável para o herói (não muda a cada rebuild).
  Future<void> _openVideo(BuildContext context, String youtubeId) async {
    if (await ParentalService.warnIfPlaybackBlocked(context)) return;
    if (!context.mounted) return;
    if (!SubscriptionService.instance.hasPremiumAccess && !FreemiumService.instance.isEnrolled) {
      await context.pushNamed(DulangPremiumWidget.routeName);
      return;
    }
    if (!context.mounted) return;
    context.pushNamed(
      DulangVideoWidget.routeName,
      queryParameters: {
        'url': serializeParam(youtubeId, ParamType.String),
      }.withoutNulls,
    );
  }

  Future<void> _openCanalList(BuildContext context, String? channelName) async {
    if (await ParentalService.warnIfPlaybackBlocked(context)) return;
    if (!context.mounted) return;
    if (!SubscriptionService.instance.hasPremiumAccess && !FreemiumService.instance.isEnrolled) {
      await context.pushNamed(DulangPremiumWidget.routeName);
      return;
    }
    if (!context.mounted) return;
    if (channelName == null || channelName.isEmpty) {
      context.pushNamed(CanalVideosWidget.routeName);
    } else {
      context.pushNamed(
        CanalVideosWidget.routeName,
        queryParameters: {
          'channelName': serializeParam(
            channelName,
            ParamType.String,
          ),
        }.withoutNulls,
      );
    }
  }

  int _stableHeroIndex(List<VideoRow> videos) {
    if (videos.isEmpty) return 0;
    var h = videos.length;
    for (var i = 0; i < videos.length && i < 24; i++) {
      h = h * 31 + videos[i].youtubeVideoId.hashCode;
    }
    return h.abs() % videos.length;
  }

  Widget _buildHero(BuildContext context, VideoRow hero) {
    final h = MediaQuery.sizeOf(context).height * 0.46;
    final tertiary = FlutterFlowTheme.of(context).tertiary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              hero.displayThumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade900,
                alignment: Alignment.center,
                child: Icon(Icons.play_circle_outline_rounded,
                    size: 64, color: tertiary),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hero.channelName.isNotEmpty)
                    Text(
                      hero.channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.readexPro(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    hero.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.readexPro(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: tertiary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      _openVideo(context, hero.youtubeVideoId);
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 26),
                    label: Text(
                      'Assistir agora',
                      style: GoogleFonts.readexPro(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeaturedSection(
      BuildContext context, List<VideoRow> videos) {
    final featured = videos.take(10).toList();
    return [
      Text(
        'Em destaque',
        style: FlutterFlowTheme.of(context).titleLarge,
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: featured.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final v = featured[i];
            return _FeaturedCard(
              video: v,
              onTap: () {
                _openVideo(context, v.youtubeVideoId);
              },
            );
          },
        ),
      ),
    ];
  }

  Widget _buildChannelGrid(BuildContext context, List<VideoRow> videos) {
    final repByChannel = _representativeVideoByChannelName(videos);
    final names = videos.map((v) => v.channelName).where((n) => n.isNotEmpty).toSet().toList()
      ..sort();
    final tiles = <String>['Todos', ...names];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, i) {
        final name = tiles[i];
        final isTodos = name == 'Todos';
        final thumbUrl = isTodos
            ? ''
            : (repByChannel[name]?.displayThumbnailUrl.trim() ?? '');
        return Material(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _openCanalList(
                context,
                isTodos ? null : name,
              );
            },
            child: thumbUrl.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.readexPro(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        thumbUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          child: Icon(
                            Icons.tv_rounded,
                            size: 40,
                            color: FlutterFlowTheme.of(context).primaryText
                                .withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.28),
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.readexPro(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.2,
                              shadows: const [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Por nome de canal (mesma chave da grade), o vídeo com [publishedAt] mais recente.
Map<String, VideoRow> _representativeVideoByChannelName(List<VideoRow> videos) {
  final byName = <String, List<VideoRow>>{};
  for (final v in videos) {
    final n = v.channelName.trim();
    if (n.isEmpty) continue;
    (byName[n] ??= []).add(v);
  }
  final out = <String, VideoRow>{};
  for (final e in byName.entries) {
    out[e.key] = _pickNewestVideoByPublishedAt(e.value);
  }
  return out;
}

VideoRow _pickNewestVideoByPublishedAt(List<VideoRow> rows) {
  final sorted = List<VideoRow>.from(rows)
    ..sort((a, b) {
      final ap = a.publishedAt;
      final bp = b.publishedAt;
      if (ap == null && bp == null) return 0;
      if (ap == null) return 1;
      if (bp == null) return -1;
      return bp.compareTo(ap);
    });
  return sorted.first;
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.video, required this.onTap});

  final VideoRow video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width * 0.42;
    return Material(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  video.displayThumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.play_circle_outline, size: 48),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.readexPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
