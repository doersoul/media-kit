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

    // Play a [Media] or [Playlist].
    _player.stream.error.listen((error) {
      print('[error] >>>>>>>>>>> $error');
    });

    _player.stream.log.listen((log) {
      print('[${log.level}] >>>>>>>>>>> ${log.text}');
    });

    _player.open(Media(
      'https://us-xpc11.xpccdn.com/5e152f32b86b5.mp4',
    ));

    _player.setPlaylistMode(PlaylistMode.single);
  }

  @override
  void dispose() {
    _player.dispose();

    super.dispose();
  }

  void _onPressed() {
    // Play a [Media] or [Playlist].
    _player.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MediaKitVideo'),
        ),
        body: MediaKitVideoView(
          controller: _controller,
          color: Colors.transparent,
          fit: MediaKitVideoViewFit.contain,
        ),
        bottomNavigationBar: BottomAppBar(
          child: FilledButton(onPressed: _onPressed, child: Text('重试')),
        ),
      ),
    );
  }
}
