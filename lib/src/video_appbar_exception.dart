class VideoAppbarException implements Exception {
  final String message;

  VideoAppbarException(this.message);

  @override
  String toString() {
    return '[VideoAppBar ERROR]: $message';
  }
}