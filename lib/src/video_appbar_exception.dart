/// Custom exception for the `VideoAppBar`.
///
/// Thrown when there is an error with the video controller.
class VideoAppbarException implements Exception {
  final String message;

  VideoAppbarException(this.message);

  @override
  String toString() {
    return '[VideoAppBar ERROR]: $message';
  }
}