/*
Copyright 2021 Sarbagya Dhaubanjar. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as uri_launcher;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '/flutter_flow/flutter_flow_util.dart' show routeObserver;

/// Replaces [YoutubePlayerController]'s delegate: upstream only handles a few
/// `feature=` values for related/endscreen taps; YouTube adds new `emb_rel_*`
/// names, which then get [NavigationDecision.prevent] with no [loadVideoById].
NavigationDecision _dulangYoutubeNavigationDecision(
  YoutubePlayerController controller,
  Uri? uri,
) {
  if (uri == null) return NavigationDecision.prevent;

  final params = uri.queryParameters;
  final host = uri.host;
  final path = uri.path;

  String? featureName;
  if (host.contains('facebook') ||
      host.contains('twitter') ||
      host == 'youtu') {
    featureName = 'social';
  } else if (params.containsKey('feature')) {
    featureName = params['feature'];
  } else if (path == '/watch' || path == '/watch/') {
    featureName = 'emb_info';
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return NavigationDecision.navigate;
  }

  final v = params['v'];
  if (v != null &&
      v.isNotEmpty &&
      featureName != null &&
      featureName.startsWith('emb_rel')) {
    unawaited(controller.loadVideoById(videoId: v));
    return NavigationDecision.prevent;
  }

  switch (featureName) {
    case 'emb_rel_pause':
    case 'emb_rel_end':
    case 'emb_info':
      final videoId = params['v'];
      if (videoId != null) {
        unawaited(controller.loadVideoById(videoId: videoId));
      }
      break;
    case 'emb_title':
    case 'emb_logo':
    case 'social':
    case 'wl_button':
      unawaited(uri_launcher.launchUrl(uri));
      break;
  }

  return NavigationDecision.prevent;
}

void _installDulangYoutubeNavigationDelegate(YoutubePlayerController controller) {
  // Package sets NavigationDelegate in the ctor only; no override hook. We must
  // replace it so newer YouTube `feature=emb_rel_*` URLs still load in-player.
  // ignore: invalid_use_of_internal_member
  controller.webViewController.setNavigationDelegate(
    NavigationDelegate(
      onWebResourceError: (error) {
        developer.log(
          error.description,
          name: error.errorType.toString(),
        );
      },
      onNavigationRequest: (request) {
        final uri = Uri.tryParse(request.url);
        return _dulangYoutubeNavigationDecision(controller, uri);
      },
    ),
  );
}

const kYoutubeAspectRatio = 16 / 9;
final _youtubeFullScreenControllerMap = <String, YoutubePlayerController>{};

class FlutterFlowYoutubePlayer extends StatefulWidget {
  const FlutterFlowYoutubePlayer({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.autoPlay = false,
    this.mute = false,
    this.looping = false,
    this.showControls = true,
    this.showFullScreen = false,
    this.pauseOnNavigate = true,
    this.strictRelatedVideos = false,
    this.onVideoIdChanged,
  });

  final String url;
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool mute;
  final bool looping;
  final bool showControls;
  final bool showFullScreen;
  final bool pauseOnNavigate;
  final bool strictRelatedVideos;
  final ValueChanged<String>? onVideoIdChanged;

  @override
  State<FlutterFlowYoutubePlayer> createState() =>
      _FlutterFlowYoutubePlayerState();
}

class _FlutterFlowYoutubePlayerState extends State<FlutterFlowYoutubePlayer>
    with RouteAware {
  YoutubePlayerController? _controller;
  String? _videoId;
  _YoutubeFullScreenWrapperState? _youtubeWrapper;
  bool _subscribedRoute = false;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  String? _expectedVideoId;
  String? _lastNotifiedVideoId;

  bool get handleFullScreen =>
      !kIsWeb && widget.showFullScreen && _youtubeWrapper != null;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void didUpdateWidget(covariant FlutterFlowYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _tearDownPlayer();
      initializePlayer();
    }
  }

  @override
  void dispose() {
    if (!handleFullScreen || _youtubeWrapper?._controller == null) {
      _tearDownPlayer();
    } else {
      _youtubeWrapper?.resetOverlay();
      if (_subscribedRoute) {
        routeObserver.unsubscribe(this);
        _subscribedRoute = false;
      }
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribeRouteIfNeeded();
  }

  void _subscribeRouteIfNeeded() {
    if (!widget.pauseOnNavigate) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route is! PageRoute) {
      return;
    }
    if (_subscribedRoute) {
      routeObserver.unsubscribe(this);
      _subscribedRoute = false;
    }
    routeObserver.subscribe(this, route);
    _subscribedRoute = true;
  }

  void _tearDownPlayer() {
    _playerSubscription?.cancel();
    _playerSubscription = null;
    _expectedVideoId = null;
    _lastNotifiedVideoId = null;
    _youtubeWrapper?.resetOverlay();
    if (_subscribedRoute) {
      routeObserver.unsubscribe(this);
      _subscribedRoute = false;
    }
    _controller?.close();
    if (_videoId != null) {
      _youtubeFullScreenControllerMap[_videoId]?.close();
      _youtubeFullScreenControllerMap.remove(_videoId);
    }
    _controller = null;
    _videoId = null;
    _youtubeWrapper = null;
  }

  @override
  void didPushNext() {
    if (widget.pauseOnNavigate) {
      _controller?.pauseVideo();
    }
  }

  double get width => widget.width == null || widget.width! >= double.infinity
      ? MediaQuery.sizeOf(context).width
      : widget.width!;

  double get height =>
      widget.height == null || widget.height! >= double.infinity
          ? width / kYoutubeAspectRatio
          : widget.height!;

  void initializePlayer() {
    if (!mounted) {
      return;
    }
    final videoId = _convertUrlToId(widget.url);
    if (videoId == null) {
      return;
    }
    _expectedVideoId = videoId;
    _lastNotifiedVideoId = null;
    _videoId = videoId;
    _youtubeWrapper = YoutubeFullScreenWrapper.of(context);

    if (handleFullScreen &&
        _youtubeFullScreenControllerMap.containsKey(_videoId)) {
      _controller = _youtubeFullScreenControllerMap[_videoId]!;
      _youtubeFullScreenControllerMap.clear();
    } else {
      _controller = YoutubePlayerController(
        key: _youtubeControllerKey(videoId),
        params: YoutubePlayerParams(
          origin: 'https://www.youtube-nocookie.com',
          mute: widget.mute,
          loop: widget.looping,
          showControls: widget.showControls,
          showFullscreenButton: widget.showFullScreen,
          strictRelatedVideos: widget.strictRelatedVideos,
        ),
      );
      if (widget.autoPlay) {
        unawaited(_controller!.loadVideoById(videoId: videoId));
      } else {
        unawaited(_controller!.cueVideoById(videoId: videoId));
      }
    }

    _installDulangYoutubeNavigationDelegate(_controller!);

    _playerSubscription?.cancel();
    _playerSubscription = _controller!.listen(_handlePlayerValue);

    if (handleFullScreen) {
      _controller!.setFullScreenListener((fullScreen) {
        if (fullScreen) {
          _youtubeFullScreenControllerMap[_videoId!] = _controller!;
          _youtubeWrapper?.updateYoutubePlayer(_controller, _videoId);
        } else {
          _youtubeWrapper?.updateYoutubePlayer();
        }
      });
    }
  }

  void _handlePlayerValue(YoutubePlayerValue value) {
    if (!mounted) {
      return;
    }
    if (widget.onVideoIdChanged == null) {
      return;
    }
    if (value.playerState != PlayerState.playing) {
      return;
    }

    final currentId = value.metaData.videoId;
    if (currentId.isEmpty) {
      return;
    }
    if (_expectedVideoId != null && currentId == _expectedVideoId) {
      return;
    }
    if (currentId == _lastNotifiedVideoId) {
      return;
    }

    _lastNotifiedVideoId = currentId;
    widget.onVideoIdChanged!(currentId);
  }

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.cover,
        child: Container(
          height: height,
          width: width,
          child: _controller != null
              ? handleFullScreen
                  ? YoutubePlayerScaffold(
                      controller: _controller!,
                      builder: (_, player) => player,
                      autoFullScreen: false,
                      gestureRecognizers: const <Factory<
                          TapGestureRecognizer>>{},
                      enableFullScreenOnVerticalDrag: false,
                    )
                  : YoutubePlayer(
                      controller: _controller!,
                      gestureRecognizers: const <Factory<
                          TapGestureRecognizer>>{},
                      enableFullScreenOnVerticalDrag: false,
                    )
              : Container(color: Colors.transparent),
        ),
      );
}

/// Wraps the page in order to properly show the YouTube video when fullscreen.
class YoutubeFullScreenWrapper extends StatefulWidget {
  YoutubeFullScreenWrapper({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static _YoutubeFullScreenWrapperState? of(BuildContext context) =>
      context.findAncestorStateOfType<_YoutubeFullScreenWrapperState>();

  @override
  State<YoutubeFullScreenWrapper> createState() =>
      _YoutubeFullScreenWrapperState();
}

class _YoutubeFullScreenWrapperState extends State<YoutubeFullScreenWrapper> {
  YoutubePlayerController? _controller;
  String? _videoId;

  void resetOverlay() {
    if (!mounted) {
      return;
    }
    setState(() {
      _controller = null;
      _videoId = null;
    });
  }

  void updateYoutubePlayer([
    YoutubePlayerController? controller,
    String? videoId,
  ]) =>
      setState(() {
        _controller = controller;
        _videoId = videoId;
      });

  @override
  void dispose() {
    _controller?.close();
    _youtubeFullScreenControllerMap.remove(_videoId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _controller != null
      ? YoutubePlayerScaffold(
          controller: _controller!,
          builder: (_, player) => player,
          enableFullScreenOnVerticalDrag: false,
        )
      : widget.child;
}

String? _convertUrlToId(String url, {bool trimWhitespaces = true}) {
  assert(url.isNotEmpty, 'Url cannot be empty');
  if (!url.contains("http") && (url.length == 11)) return url;
  if (trimWhitespaces) url = url.trim();
  for (final regex in [
    RegExp(
      r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$",
    ),
    RegExp(
      r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$",
    ),
    RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ]) {
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 1) return match.group(1);
  }
  return null;
}

String _youtubeControllerKey(String videoId) =>
    'Youtube_${videoId.codeUnits.map((code) => code.toRadixString(16).padLeft(2, '0')).join()}';
