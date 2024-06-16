import 'dart:io';

import 'video_appbar_source_type.dart';

/// Class representing the video source.
///
/// Uses different constructors to handle different types of sources:
/// asset, network, and local file.
class VideoAppBarSource {
  final String _dataSource;
  final SourceType _sourceType;
  final File? _file;
  final Map<String, String> _httpHeaders;

  /// Constructor for asset source.
  /// You need to specify the [dataSource] where the video is located.
  ///
  /// **Usage Example:**
  /// ```dart
  /// VideoAppBarSource.asset(
  ///   dataSource: 'res/video/video_01.mp4',
  /// )
  /// ```
  VideoAppBarSource.asset({
    required String dataSource,
  })  : _sourceType = SourceType.assetSource,
        _dataSource = dataSource,
        _httpHeaders = {},
        _file = null;

  /// Constructor for network source.
  /// You can specify the [URL] of the video and if necessary you can also place [httpHeaders].
  ///
  /// **Usage Example:**
  /// ```dart
  /// VideoAppBarSource.network(
  ///   url: 'https://github.com/jorgemvv01/flutter_video_appbar/example/res/videos/video_01.mp4'),
  /// )
  /// ```
  VideoAppBarSource.network(
      {required String url, httpHeaders = const <String, String>{}})
      : _sourceType = SourceType.networkSource,
        _httpHeaders = httpHeaders,
        _dataSource = url,
        _file = null;

  /// Constructor for file source.
  /// You need to specify the [File] with the path to the video file
  /// and if necessary you can also place [httpHeaders].
  ///
  /// `IMPORTANT:` do not use this option for WEB platform.
  ///
  /// **Usage Example:**
  /// ```dart
  /// VideoAppBarSource.file(
  ///   file: File('your_path/video_01.mp4'),
  /// )
  /// ```
  VideoAppBarSource.file(
      {required File file, httpHeaders = const <String, String>{}})
      : _sourceType = SourceType.fileSource,
        _dataSource = Uri.file(file.absolute.path).toString(),
        _file = file,
        _httpHeaders = httpHeaders;

  String get dataSource => _dataSource;
  SourceType get sourceType => _sourceType;
  File? get file => _file;
  Map<String, String> get httpHeaders => _httpHeaders;
}
