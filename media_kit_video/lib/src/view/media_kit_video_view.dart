import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/src/model/value_observer.dart';
import 'package:media_kit_video/src/utils/orientation_utils.dart';
import 'package:media_kit_video/src/view/media_kit_video_view_inner.dart';

typedef MediaVideoCoverBuilder = Widget Function(
    BuildContext context, MediaKitVideoViewFit fit);

typedef MediaVideoSkinBuilder = Widget Function(
  MediaKitVideoViewState viewState,
  Size viewSize,
  Rect texturePosition,
);

class MediaKitVideoView extends StatefulWidget {
  static const String fullScreenRoute = '__media_kit_video_full_screen__';

  final MediaKitVideoController controller;
  final double? width;
  final double? height;
  final Color color;
  final MediaKitVideoViewFit fit;
  final bool showCoverFirst;
  final VoidCallback? onEnterFullScreen;
  final VoidCallback? onExitFullScreen;
  final WidgetBuilder? backgroundBuilder;
  final MediaVideoCoverBuilder? coverBuilder;
  final MediaVideoSkinBuilder? skinBuilder;

  const MediaKitVideoView({
    super.key,
    required this.controller,
    this.width,
    this.height,
    required this.color,
    required this.fit,
    this.showCoverFirst = true,
    this.onEnterFullScreen,
    this.onExitFullScreen,
    this.backgroundBuilder,
    this.coverBuilder,
    this.skinBuilder,
  });

  @override
  State<StatefulWidget> createState() => MediaKitVideoViewState();
}

class MediaKitVideoViewState extends State<MediaKitVideoView> {
  final ValueObserver<bool> _observer = ValueObserver(true);

  bool fullScreen = false;

  bool _changed = false;

  @override
  void didUpdateWidget(MediaKitVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _observer.value = true;
    }
  }

  @override
  void dispose() {
    _observer.dispose();

    super.dispose();
  }

  Future<void> enterFullScreen() async {
    if (fullScreen) {
      return;
    }

    fullScreen = true;

    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    final Future<Null> exitFuture = navigator.push(
      PageRouteBuilder<Null>(
        settings: const RouteSettings(name: MediaKitVideoView.fullScreenRoute),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: MediaKitVideoViewInner(
              state: this,
              fit: MediaKitVideoViewFit.contain,
              color: Colors.black,
              observer: _observer,
            ),
          );
        },
      ),
    );

    // will lead to rebuild
    if (widget.onEnterFullScreen != null) {
      widget.onEnterFullScreen!.call();
    } else {
      OrientationUtils.hideSystemBar();
    }

    final Size? videoSize = widget.controller.rect.value?.size;
    final double videoWidth = videoSize?.width ?? -1;
    final double videoHeight = videoSize?.height ?? -1;
    final Orientation orientation = MediaQuery.of(context).orientation;

    // will lead to rebuild
    if (videoWidth >= videoHeight) {
      if (orientation == Orientation.portrait) {
        OrientationUtils.setOrientationLandscape();

        _changed = true;
      }
    } else {
      if (orientation == Orientation.landscape) {
        OrientationUtils.setOrientationPortrait();

        _changed = true;
      }
    }

    await exitFuture;

    fullScreen = false;

    if (_changed) {
      if (videoWidth >= videoHeight) {
        OrientationUtils.setOrientationPortrait();
      } else {
        OrientationUtils.setOrientationLandscape();
      }
    }

    // will lead to rebuild
    if (widget.onExitFullScreen != null) {
      widget.onExitFullScreen!.call();
    } else {
      OrientationUtils.showSystemBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox.shrink();

    if (!fullScreen) {
      child = MediaKitVideoViewInner(
        state: this,
        fit: widget.fit,
        color: widget.color,
      );
    }

    return SizedBox(width: widget.width, height: widget.height, child: child);
  }
}
