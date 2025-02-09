import 'package:flutter/material.dart';
import 'package:media_kit_video/src/controller/media_kit_video_controller.dart';
import 'package:media_kit_video/src/model/media_kit_value_observer.dart';
import 'package:media_kit_video/src/model/media_kit_video_view_fit.dart';
import 'package:media_kit_video/src/util/media_kit_orientation_utils.dart';
import 'package:media_kit_video/src/view/media_kit_video_view_inner.dart';

typedef MediaVideoCoverBuilder = Widget Function(
  BuildContext context,
  MediaKitVideoViewFit fit,
);

typedef MediaVideoSkinBuilder = Widget Function(
  MediaKitVideoViewState viewState,
  Size viewSize,
  Rect texturePosition,
);

const mediaKitVideoFullScreenRouteName = '_media_kit_video_full_screen';

class MediaKitVideoView extends StatefulWidget {
  final MediaKitVideoController controller;
  final double? width;
  final double? height;
  final Color color;
  final MediaKitVideoViewFit fit;
  final VoidCallback? onEnterFullScreen;
  final VoidCallback? onExitFullScreen;
  final MediaVideoCoverBuilder? coverBuilder;
  final MediaVideoSkinBuilder? skinBuilder;

  const MediaKitVideoView({
    super.key,
    required this.controller,
    this.width,
    this.height,
    required this.color,
    required this.fit,
    this.onEnterFullScreen,
    this.onExitFullScreen,
    this.coverBuilder,
    this.skinBuilder,
  });

  @override
  State<StatefulWidget> createState() => MediaKitVideoViewState();
}

class MediaKitVideoViewState extends State<MediaKitVideoView> {
  final MediaKitValueObserver<bool> _observer = MediaKitValueObserver(true);

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
    Future<Null> exit = navigator.push(PageRouteBuilder<Null>(
      settings: const RouteSettings(name: mediaKitVideoFullScreenRouteName),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (innerCtx, child) {
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
        );
      },
    ));

    // will lead to rebuild
    if (widget.onEnterFullScreen != null) {
      widget.onEnterFullScreen!.call();
    } else {
      MediaKitOrientationUtils.hideSystemBar();
    }

    final Size? videoSize = widget.controller.rect.value?.size;
    final double videoWidth = videoSize?.width ?? -1;
    final double videoHeight = videoSize?.height ?? -1;
    final Orientation orientation = MediaQuery.of(context).orientation;

    // will lead to rebuild
    if (videoWidth >= videoHeight) {
      if (orientation == Orientation.portrait) {
        await MediaKitOrientationUtils.setOrientationLandscape();

        _changed = true;
      }
    } else {
      if (orientation == Orientation.landscape) {
        await MediaKitOrientationUtils.setOrientationPortrait();

        _changed = true;
      }
    }

    await exit;

    fullScreen = false;

    if (_changed) {
      if (videoWidth >= videoHeight) {
        await MediaKitOrientationUtils.setOrientationPortrait();
      } else {
        await MediaKitOrientationUtils.setOrientationLandscape();
      }
    }

    // will lead to rebuild
    if (widget.onExitFullScreen != null) {
      widget.onExitFullScreen!.call();
    } else {
      MediaKitOrientationUtils.showSystemBar();
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
