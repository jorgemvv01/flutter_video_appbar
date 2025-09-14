import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video_appbar_exception.dart';
import 'video_appbar_source.dart';
import 'video_appbar_source_type.dart';

///It provides a way to add an AppBar with embedded videos,
///and allows you to combine custom widgets with it.
class VideoAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// This widget allows playing a video from different sources, such as asset, network URL, or local file,
  /// and provides options to control the appearance and controls of the video.
  ///
  /// **Usage Example:**
  /// ```dart
  /// VideoAppBar(
  ///   source: VideoAppBarSource.asset(dataSource: 'assets/video.mp4'),
  ///   actions: [IconButton(icon: Icon(Icons.share), onPressed: () {})],
  ///   height: 350,
  ///   looping: true,
  /// )
  /// ```
  const VideoAppBar(
      {super.key,
      required this.source,
      this.actions,
      this.leading,
      this.contentPadding,
      this.height = 200,
      this.errorPlaceholder,
      this.loading,
      this.gradient,
      this.body,
      this.looping = true,
      this.volume = 0.0,
      this.onError,
      this.showWebUnmuteButton = true,
      this.unmuteButtonAlignment = Alignment.bottomRight,
      this.unmuteButtonPadding = const EdgeInsets.all(8),
      this.unmuteButtonBuilder});

  /// The video source, which can be an asset, network URL, or local file.
  final VideoAppBarSource source;

  /// Optional: List of widgets to display as actions in the app bar.
  final List<Widget>? actions;

  /// Optional: Widget to display as the leading widget in the app bar.
  final Widget? leading;

  /// Optional: Padding to apply around the video content.
  final EdgeInsetsGeometry? contentPadding;

  /// Height of the video app bar. Default is 200.
  final double height;

  /// Widget to display as a placeholder when there was an error with the video.
  final Widget? errorPlaceholder;

  /// Widget to display while the video is loading.
  final Widget? loading;

  /// Background gradient for the video app bar.
  final Gradient? gradient;

  /// Optional: Widget to show above the video.
  final Widget? body;

  /// Indicates whether the video should loop. Default is `true`.
  final bool looping;

  /// Volume level of the video, ranging from 0.0 (muted) to 1.0 (maximum volume). Default is 0.0 (muted).
  final double volume;

  /// If true (default) shows an unmute button overlay on web to enable audio via user gesture.
  final bool showWebUnmuteButton;

  /// Alignment for the unmute button when shown on web (e.g. Alignment.topLeft).
  final Alignment unmuteButtonAlignment;

  /// Padding around the unmute button (distance from safe area edges).
  final EdgeInsets unmuteButtonPadding;

  /// Optional builder to render a custom unmute button.
  /// Signature: (BuildContext context, bool isMuted, VoidCallback onPressed) => Widget
  final Widget Function(BuildContext, bool, VoidCallback)? unmuteButtonBuilder;

  /// Function to be executed if an error occurs
  final Function()? onError;

  @override
  State<VideoAppBar> createState() => _VideoAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

/// State for the `VideoAppBar`.
class _VideoAppbarState extends State<VideoAppBar> {
  late VideoPlayerController controller;
  bool hasError = false;
  bool _isMuted = kIsWeb;

  @override
  void initState() {
    super.initState();

    // Initialize the controller based on the video source type.
    switch (widget.source.sourceType) {
      case SourceType.assetSource:
        controller = VideoPlayerController.asset(widget.source.dataSource,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
        break;

      case SourceType.networkSource:
        controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.source.dataSource),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            httpHeaders: widget.source.httpHeaders);
        break;

      case SourceType.fileSource:
        controller = VideoPlayerController.file(
          widget.source.file!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        break;
    }

    controller.initialize().then((_) {
      if (widget.source.dataSource == 'testing_error') {
        controller.value = VideoPlayerValue(
            duration: Duration(), errorDescription: 'testing_error');
      }

      controller
          .setVolume(kIsWeb ? 0.0 : widget.volume)
          .then((value) => controller.play());
      controller.setLooping(widget.looping);
      setState(() {});
    });

    /// A listener is added to be aware of any type of error that may occur.
    controller.addListener(() {
      if (controller.value.hasError) {
        hasError = true;
        if (widget.onError != null) widget.onError!();
        setState(() {});
        throw VideoAppbarException('${controller.value.errorDescription}');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    /// The controller is deleted before the widget is deleted.
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    final bool canPop = modalRoute?.canPop ?? false;
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: controller.value.size.height,
                    width: controller.value.size.width,
                    child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller)),
                  ),
                )
              : hasError
                  ? widget.errorPlaceholder ??
                      Center(
                        child: Icon(
                            size: widget.height / 4,
                            color: theme.hintColor,
                            Icons.error_outline_outlined),
                      )
                  : widget.loading ??
                      Center(
                        child: CircularProgressIndicator(
                            color: theme.primaryColor),
                      ),
          Container(
            decoration: BoxDecoration(gradient: widget.gradient),
          ),
          if (widget.body != null) Positioned.fill(child: widget.body!),
          Padding(
            padding: widget.contentPadding ?? EdgeInsets.only(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.leading != null)
                      widget.leading!
                    else if (canPop)
                      IconButton(
                          color: theme.hintColor,
                          iconSize: 36,
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(getLeading()))
                    else
                      SizedBox.shrink(),
                    if (widget.actions != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [...widget.actions!],
                      )
                  ],
                ),
              ],
            ),
          ),

          // Web unmute button (customizable position)
          if (kIsWeb && widget.showWebUnmuteButton && widget.volume > 0)
            Align(
              alignment: widget.unmuteButtonAlignment,
              child: Padding(
                padding: widget.unmuteButtonPadding,
                child: SafeArea(
                  child: _buildUnmuteButton(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnmuteButton(BuildContext context) {
    final isEnabled = controller.value.isInitialized;

    void handlePressed() async {
      if (!isEnabled) return;
      if (_isMuted) {
        await controller.setVolume(widget.volume);
        await controller.play();
        _isMuted = widget.volume <= 0.0;
      } else {
        await controller.setVolume(0.0);
        _isMuted = true;
      }
      setState(() {});
    }

    if (widget.unmuteButtonBuilder != null) {
      return GestureDetector(
        onTap: isEnabled ? handlePressed : null,
        child: widget.unmuteButtonBuilder!(context, _isMuted, handlePressed),
      );
    }

    // Default built-in icon button
    return Material(
      color: Colors.transparent,
      child: IconButton(
        iconSize: 28,
        color: Theme.of(context).primaryIconTheme.color,
        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
        onPressed: isEnabled ? handlePressed : null,
      ),
    );
  }

  /// Returns the appropriate icon for the back button based on the platform and web environment.
  IconData getLeading() {
    if (kIsWeb) {
      return Icons.arrow_back;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return Icons.arrow_back;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Icons.arrow_back_ios_new_rounded;
    }
  }
}
