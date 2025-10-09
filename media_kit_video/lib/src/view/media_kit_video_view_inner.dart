import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/src/model/value_observer.dart';

class MediaKitVideoViewInner extends StatefulWidget {
  final MediaKitVideoViewState state;
  final MediaKitVideoViewFit fit;
  final Color color;
  final ValueObserver<bool>? observer;

  const MediaKitVideoViewInner({
    super.key,
    required this.state,
    required this.fit,
    required this.color,
    this.observer,
  });

  @override
  State<StatefulWidget> createState() => _MediaKitVideoViewInnerState();

  bool get showCoverFirst => state.widget.showCoverFirst;

  MediaKitVideoController get controller => state.widget.controller;

  Player get player => controller.player;

  WidgetBuilder? get backgroundBuilder => state.widget.backgroundBuilder;

  MediaKitVideoCoverBuilder? get coverBuilder => state.widget.coverBuilder;

  MediaKitVideoSkinBuilder? get skinBuilder => state.widget.skinBuilder;
}

class _MediaKitVideoViewInnerState extends State<MediaKitVideoViewInner> {
  late List<StreamSubscription> _subscriptions;

  late bool _playable;

  late int _textureId;
  late double _videoWidth;
  late double _videoHeight;
  late bool _videoRenderStart;

  @override
  void initState() {
    super.initState();

    _initPlayerListener();
    _initObserverListener();
  }

  @override
  void didUpdateWidget(MediaKitVideoViewInner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.player != oldWidget.player) {
      _disposePlayerListener(oldWidget);
      _initPlayerListener();
    }

    if (widget.observer != oldWidget.observer) {
      _disposeObserverListener(oldWidget);
      _initObserverListener();
    }
  }

  @override
  void dispose() {
    _disposePlayerListener(widget);
    _disposeObserverListener(widget);

    super.dispose();
  }

  void _initPlayerListener() {
    _playable = false;
    _textureId = -1;
    _videoWidth = -1;
    _videoHeight = -1;
    _videoRenderStart = false;

    widget.controller.id.addListener(_playerListener);
    widget.controller.rect.addListener(_playerListener);

    _subscriptions = [
      widget.controller.player.stream.playing.listen(_playerListener),
      widget.controller.player.stream.width.listen(_playerListener),
      widget.controller.player.stream.height.listen(_playerListener),
    ];

    _playerListener();
  }

  void _disposePlayerListener(MediaKitVideoViewInner inner) {
    inner.controller.id.removeListener(_playerListener);
    inner.controller.rect.removeListener(_playerListener);

    for (final subscription in _subscriptions) {
      subscription.cancel().ignore();
    }
  }

  Future<void> _playerListener([_]) async {
    _playable = _playable || widget.player.state.playing;

    final int textureId = widget.controller.id.value ?? -1;
    final Size? size = widget.controller.rect.value?.size;
    final double videoWidth = size?.width ?? -1;
    final double videoHeight = size?.height ?? -1;
    final bool ready = _videoRenderStart ||
        (textureId > -1 && videoWidth > 0 && videoHeight > 0);

    bool videoRenderStart = ready;
    if (widget.showCoverFirst) {
      videoRenderStart = (videoRenderStart && _playable) ||
          widget.player.state.position.inMilliseconds > 0;
    }

    if (_textureId != textureId ||
        _videoWidth != videoWidth ||
        _videoHeight != videoHeight ||
        _videoRenderStart != videoRenderStart) {
      _textureId = textureId;
      _videoWidth = videoWidth;
      _videoHeight = videoHeight;
      _videoRenderStart = videoRenderStart;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _initObserverListener() {
    widget.observer?.addListener(_observerListener);
  }

  void _disposeObserverListener(MediaKitVideoViewInner inner) {
    inner.observer?.removeListener(_observerListener);
  }

  void _observerListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _disposePlayerListener(widget);
      _initPlayerListener();

      if (mounted) {
        setState(() {});
      }
    });
  }

  Size _applyAspectRatio(BoxConstraints constraints, double aspectRatio) {
    assert(constraints.hasBoundedHeight && constraints.hasBoundedWidth);

    constraints = constraints.loosen();

    double width = constraints.maxWidth;
    double height = width;

    if (width.isFinite) {
      height = width / aspectRatio;
    } else {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width > constraints.maxWidth) {
      width = constraints.maxWidth;
      height = width / aspectRatio;
    }

    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    if (width < constraints.minWidth) {
      width = constraints.minWidth;
      height = width / aspectRatio;
    }

    if (height < constraints.minHeight) {
      height = constraints.minHeight;
      width = height * aspectRatio;
    }

    return constraints.constrain(Size(width, height));
  }

  double _getAspectRatio(BoxConstraints constraints, double aspectRatio) {
    if (aspectRatio < 0) {
      aspectRatio = _videoWidth / _videoHeight;
    } else if (aspectRatio.isInfinite) {
      aspectRatio = constraints.maxWidth / constraints.maxHeight;
    }

    return aspectRatio;
  }

  Size _getTextureSize(BoxConstraints constraints, MediaKitVideoViewFit fit) {
    Size childSize = _applyAspectRatio(
      constraints,
      _getAspectRatio(constraints, -1),
    );

    double sizeFactor = fit.sizeFactor;
    if (-1.0 < sizeFactor && sizeFactor < -0.0) {
      sizeFactor = max(
        constraints.maxWidth / childSize.width,
        constraints.maxHeight / childSize.height,
      );
    } else if (-2.0 < sizeFactor && sizeFactor < -1.0) {
      sizeFactor = constraints.maxWidth / childSize.width;
    } else if (-3.0 < sizeFactor && sizeFactor < -2.0) {
      sizeFactor = constraints.maxHeight / childSize.height;
    } else if (sizeFactor < 0) {
      sizeFactor = 1.0;
    }

    childSize = childSize * sizeFactor;

    return childSize;
  }

  Offset _getTextureOffset(
    BoxConstraints constraints,
    Size size,
    MediaKitVideoViewFit fit,
  ) {
    final Alignment resolvedAlignment = fit.alignment;
    final Offset diff = (constraints.biggest - size) as Offset;

    return resolvedAlignment.alongOffset(diff);
  }

  Widget _buildTexture(int textureId) {
    Widget texture = const SizedBox.shrink();
    if (textureId > -1) {
      texture = RepaintBoundary(
        child: Texture(
          textureId: textureId,
          filterQuality: FilterQuality.medium,
        ),
      );
    }

    // if (_rotate != 0 && _textureId > 0) {
    //   texture = RotatedBox(quarterTurns: _rotate ~/ 90, child: texture);
    // }

    return texture;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        int textureId = _textureId;
        if (textureId < 0) {
          textureId = widget.controller.id.value ?? -1;
        }

        bool videoRenderStart = _videoRenderStart;
        if (!videoRenderStart) {
          videoRenderStart = widget.player.state.position.inMilliseconds > 0;
        }

        if (!videoRenderStart) {
          final Size? size = widget.controller.rect.value?.size;
          final double width = size?.width ?? -1;
          final double height = size?.height ?? -1;

          videoRenderStart =
              textureId > -1 && width > 0 && height > 0 && _playable;
        }

        final List<Widget> stack = [
          Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: widget.color,
          )
        ];

        final Widget? background = widget.backgroundBuilder?.call(ctx);
        if (background != null) {
          stack.add(background);
        }

        if (!videoRenderStart) {
          final Widget? cover = widget.coverBuilder?.call(ctx, widget.fit);
          if (cover != null) {
            stack.add(
              Positioned.fromRect(
                rect: Rect.fromLTWH(
                  0,
                  0,
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
                child: cover,
              ),
            );
          }
        } else {
          final Size size = _getTextureSize(constraints, widget.fit);

          final Offset offset = _getTextureOffset(
            constraints,
            size,
            widget.fit,
          );

          final Rect position = Rect.fromLTWH(
            offset.dx,
            offset.dy,
            size.width,
            size.height,
          );

          stack.add(Positioned.fromRect(
            rect: position,
            child: _buildTexture(textureId),
          ));

          final Widget? skin = widget.skinBuilder?.call(
            widget.state,
            constraints.biggest,
            position,
          );
          if (skin != null) {
            stack.add(skin);
          }
        }

        return Stack(fit: StackFit.expand, children: stack);
      },
    );
  }
}
