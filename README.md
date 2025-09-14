# VideoAppBar for Flutter

[![pub package](https://img.shields.io/pub/v/video_appbar.svg)](https://pub.dev/packages/video_appbar)
![coverage](https://img.shields.io/badge/coverage-+90-green)

A Flutter package that allows playing videos within the AppBar, and customizing each of its components.

|             | Android | iOS   | macOS  | Web   |
|-------------|---------|-------|--------|-------|
| **Support** | SDK 16+ | 12.0+ | 10.14+ | Any\* |

## Demo

Mobile - Android        |  Mobile - Android (with leading)
:-------------------------:|:-------------------------:
![mobile android demo](https://github.com/jorgemvv01/flutter_video_appbar/raw/main/res/demo_01.gif)  |  ![mobile android demo](https://github.com/jorgemvv01/flutter_video_appbar/raw/main/res/demo_02.gif)


Tablet - Android         |
:-------------------------:|
![tablet android demo](https://github.com/jorgemvv01/flutter_video_appbar/raw/main/res/demo_03.gif)  |  

## Installation

First, add `video_appbar` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

```yaml
dependencies:
  video_appbar: ^0.0.1+2
```


## Dependency

This package works using the [video_player](https://pub.dev/packages/video_player) plugin. If you need any information about compatible formats or other details, you can visit the official documentation. Below are the necessary configurations for using internet-based videos:

### iOS

If you need to access videos using `http` (rather than `https`) URLs, you will need to add
the appropriate `NSAppTransportSecurity` permissions to your app's _Info.plist_ file, located
in `<project root>/ios/Runner/Info.plist`. See
[Apple's documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity)
to determine the right combination of entries for your use case and supported iOS versions.

### Android

If you are using network-based videos, ensure that the following permission is present in your
Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### macOS

If you are using network-based videos, you will need to [add the
`com.apple.security.network.client`
entitlement](https://docs.flutter.dev/platform-integration/macos/building#entitlements-and-the-app-sandbox)

## Example

```dart
import 'package:flutter/material.dart';
import 'package:video_appbar/video_appbar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: VideoAppBar(
            source: VideoAppBarSource.network(
              url: 'https://github.com/jorgemvv01/flutter_video_appbar/raw/main/example/res/video/video_01.mp4'
            ),
            height: 54,
            body: const Center(
              child: Text(
                'Video appbar body',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white
                ),
              )
            ),
          ),
        )
      ),
    );
  }
}
```

## Web - Sound behavior

On the **Web**, videos that autoplay will always start **muted by default** due to browser policies.  
To allow the user to enable sound, `VideoAppBar` includes by default a button that appears when running on Web.  

- By default, `showWebUnmuteButton` is set to `true`.  
- This shows a floating button that lets the user toggle sound on/off.  

If you want to customize this button, you can provide your own widget via `unmuteButtonBuilder`:

```dart
VideoAppBar(
  source: VideoAppBarSource.network(
    url: 'https://github.com/jorgemvv01/flutter_video_appbar/raw/main/example/res/video/video_01.mp4'
  ),
  volume: 1,
  showWebUnmuteButton: true, // default is true
  unmuteButtonBuilder: (context, isMuted, onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
      label: Text(isMuted ? 'Activate' : 'Mute'),
      style: ElevatedButton.styleFrom(
        shape: StadiumBorder(),
        elevation: 4,
      ),
    );
  },
  body: const Center(
    child: Text(
      'Custom unmute button on Web',
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
)
```


### Acknowledgements

The images and videos for the demo showcasing the package functionality were taken from the official [valorant](https://playvalorant.com/) page.