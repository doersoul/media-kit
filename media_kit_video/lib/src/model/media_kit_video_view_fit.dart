import 'package:flutter/material.dart';

class MediaKitVideoViewFit {
  /// [Alignment] for this [MediaKitVideoView] Container.
  /// alignment is applied to Texture inner MediaKitVideoView
  final Alignment alignment;

  /// [aspectRatio] controls inner video texture widget's aspect ratio.
  ///
  /// A [MediaKitVideoView] has an important child widget which display the video frame.
  /// This important inner widget is a [Texture] in this version.
  /// Normally, we want the aspectRatio of [Texture] to be same
  /// as playback's real video frame's aspectRatio.
  /// It's also the default behaviour of [MediaKitVideoView]
  /// or if aspectRatio is assigned null or negative value.
  ///
  /// If you want to change this default behaviour,
  /// just pass the aspectRatio you want.
  ///
  /// Addition: double.infinate is a special value.
  /// The aspect ratio of inner Texture will be same as MediaKitVideoView's aspect ratio
  /// if you set double.infinate to attribute aspectRatio.
  final double aspectRatio;

  /// The size of [Texture] is multiplied by this factor.
  ///
  /// Some spacial values:
  ///  * (-1.0, -0.0) scaling up to max of [MediaKitVideoView]'s width and height
  ///  * (-2.0, -1.0) scaling up to [MediaKitVideoView]'s width
  ///  * (-3.0, -2.0) scaling up to [MediaKitVideoView]'s height
  final double sizeFactor;

  const MediaKitVideoViewFit({
    this.alignment = Alignment.center,
    this.aspectRatio = -1,
    this.sizeFactor = 1.0,
  });

  /// Fill the target MediaKitVideoView box by distorting the video's aspect ratio.
  static const MediaKitVideoViewFit fill = MediaKitVideoViewFit(
    sizeFactor: 1.0,
    aspectRatio: double.infinity,
    alignment: Alignment.center,
  );

  /// As large as possible while still containing the video entirely within the
  /// target MediaKitVideoView box.
  static const MediaKitVideoViewFit contain = MediaKitVideoViewFit(
    sizeFactor: 1.0,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  /// As small as possible while still covering the entire target MediaKitVideoView box.
  static const MediaKitVideoViewFit cover = MediaKitVideoViewFit(
    sizeFactor: -0.5,
    aspectRatio: -1,
    alignment: Alignment.center,
  );

  /// Make sure the full width of the source is shown, regardless of
  /// whether this means the source overflows the target box vertically.
  static const MediaKitVideoViewFit fitWidth = MediaKitVideoViewFit(
    sizeFactor: -1.5,
  );

  /// Make sure the full height of the source is shown, regardless of
  /// whether this means the source overflows the target box horizontally.
  static const MediaKitVideoViewFit fitHeight = MediaKitVideoViewFit(
    sizeFactor: -2.5,
  );

  /// As large as possible while still containing the video entirely within the
  /// target MediaKitVideoView box. But change video's aspect ratio to 4:3.
  static const MediaKitVideoViewFit ar4_3 = MediaKitVideoViewFit(
    aspectRatio: 4.0 / 3.0,
  );

  /// As large as possible while still containing the video entirely within the
  /// target MediaKitVideoView box. But change video's aspect ratio to 16:9.
  static const MediaKitVideoViewFit ar16_9 = MediaKitVideoViewFit(
    aspectRatio: 16.0 / 9.0,
  );
}
