import 'dart:io';

import 'video_appbar_source_type.dart';

class VideoAppBarSource {
  final String source;
  final SourceType sourceType;
  final File? file;
  final Map<String, String>? httpHeaders;

  VideoAppBarSource.asset({
    required this.source,
  }) 
  : sourceType = SourceType.assetSource,
    httpHeaders = {},
    file = null;

  VideoAppBarSource.network({
    required this.source,
    this.httpHeaders = const <String, String>{}
  }) 
  : sourceType = SourceType.networkSource,
    file = null;

  VideoAppBarSource.file({
    required this.file,
    this.httpHeaders = const <String, String>{}
  })
  : source = Uri.file(file!.absolute.path).toString(),
    sourceType = SourceType.fileSource;
}