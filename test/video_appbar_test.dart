import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_appbar/src/video_appbar_exception.dart';
import 'package:video_appbar/video_appbar.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  group('VideoAppBar Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      final FakeVideoPlayerPlatform fakeVideoPlayerPlatform =
          FakeVideoPlayerPlatform();
      VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
    });

    testWidgets('VideoAppBar displays video from asset with error',
        (WidgetTester tester) async {
      FlutterErrorDetails? capturedError;

      FlutterError.onError = (FlutterErrorDetails details) {
        capturedError = details;
      };
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: VideoAppBar(
              source: VideoAppBarSource.asset(dataSource: 'testing_error'),
              height: 200,
              actions: [IconButton(icon: Icon(Icons.share), onPressed: () {})],
              errorPlaceholder: Center(child: Text('Placeholder')),
              loading: Center(child: CircularProgressIndicator()),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () {}),
              body: Text('VideoAppBar body'),
            ),
          ),
        ),
      );

      // Capture the error thrown during widget build
      expect(capturedError, isNotNull);
      expect(capturedError!.exception, isA<VideoAppbarException>());
      final exceptionMessage = capturedError!.exception.toString();
      expect(exceptionMessage, contains('testing_error'));
      expect(find.widgetWithIcon(IconButton, Icons.arrow_back_ios_new_outlined),
          findsOneWidget);
      expect(find.text('VideoAppBar body'), findsOneWidget);
      expect(find.text('Placeholder'), findsNothing);
      expect(find.byIcon(Icons.share), findsOneWidget);
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });

    testWidgets('VideoAppBar displays loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: VideoAppBar(
              source: VideoAppBarSource.asset(dataSource: 'assets/sample.mp4'),
              height: 200,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'VideoAppBar displays video from network and go to second screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            'home': (context) => HomeScreen(),
            'second': (context) => SecondScreen(),
          },
          initialRoute: 'home',
        ),
      );

      expect(find.text('Placeholder'), findsNothing);
      expect(find.byIcon(Icons.share), findsOneWidget);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.share));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('VideoAppBar displays video from file',
        (WidgetTester tester) async {
      final file = File('home/video.mp4');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: VideoAppBar(
              source: VideoAppBarSource.file(file: file),
              height: 200,
              actions: [IconButton(icon: Icon(Icons.share), onPressed: () {})],
              errorPlaceholder: Center(child: Text('Placeholder')),
              loading: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );

      expect(find.text('Placeholder'), findsNothing);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VideoAppBar(
        source: VideoAppBarSource.network(url: 'https://example.mp4'),
        height: 200,
        actions: [
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () => Navigator.pushNamed(context, 'second'))
        ],
        errorPlaceholder: Center(child: Text('Placeholder')),
        loading: Center(child: CircularProgressIndicator()),
        body: Text('Body'),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VideoAppBar(
        source: VideoAppBarSource.network(
            url:
                'https://cmsassets.rgpub.io/sanity/files/dsfx7636/news/409ab2fc369ba5e1fe50bac10c6676d7d1365a9f.mp4'),
        height: 200,
        loading: Center(child: Text('Loading')),
      ),
    );
  }
}

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  Completer<bool> initialized = Completer<bool>();
  List<String> calls = <String>[];
  List<DataSource> dataSources = <DataSource>[];
  final Map<int, StreamController<VideoEvent>> streams =
      <int, StreamController<VideoEvent>>{};
  bool forceInitError = false;
  int nextTextureId = 0;
  final Map<int, Duration> _positions = <int, Duration>{};

  @override
  Future<int?> create(DataSource dataSource) async {
    calls.add('create');
    final StreamController<VideoEvent> stream = StreamController<VideoEvent>();
    streams[nextTextureId] = stream;
    if (forceInitError) {
      stream.addError(PlatformException(
          code: 'VideoError', message: 'Video player had error XYZ'));
    } else {
      stream.add(VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(100, 100),
          duration: const Duration(seconds: 3)));
    }
    dataSources.add(dataSource);
    return nextTextureId++;
  }

  @override
  Future<void> dispose(int textureId) async {
    calls.add('dispose');
  }

  @override
  Future<void> init() async {
    calls.add('init');
    initialized.complete(true);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return streams[textureId]!.stream;
  }

  @override
  Future<void> pause(int textureId) async {
    calls.add('pause');
  }

  @override
  Future<void> play(int textureId) async {
    calls.add('play');
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    calls.add('position');
    return _positions[textureId] ?? Duration.zero;
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    calls.add('seekTo');
    _positions[textureId] = position;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    calls.add('setLooping');
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    calls.add('setVolume');
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    calls.add('setPlaybackSpeed');
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {
    calls.add('setMixWithOthers');
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }
}
