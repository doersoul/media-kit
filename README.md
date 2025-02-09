fork https://github.com/media-kit/media-kit

## Installation

```yaml
dependencies:
  media_kit:
    path: ../media_kit
  media_kit_video:
    path: ../media_kit_video
  media_kit_libs_video:
    path: ../libs/universal/media_kit_libs_video
```

## A quick usage example.

```dart
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Player _player = Player();

  late final MediaKitVideoController _controller =
      MediaKitVideoController(_player);

  @override
  void initState() {
    super.initState();

    _player.open(Media(
      'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4',
    ));

    _player.setPlaylistMode(PlaylistMode.single);
  }

  @override
  void dispose() {
    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('MediaKitVideo')),
        body: MediaKitVideoView(
          controller: _controller,
          color: Colors.transparent,
          fit: MediaKitVideoViewFit.contain,
          skinBuilder: (
            MediaKitVideoViewState viewState,
            Size viewSize,
            Rect texturePosition,
          ) {
            return Builder(builder: (ctx) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    if (viewState.fullScreen) {
                      Navigator.of(ctx).pop();
                    } else {
                      viewState.enterFullScreen();
                    }
                  },
                  child: Icon(
                    Icons.fullscreen_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
```