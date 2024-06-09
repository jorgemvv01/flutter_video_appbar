import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video_appbar_exception.dart';
import 'video_appbar_source.dart';
import 'video_appbar_source_type.dart';

class VideoAppBar extends StatefulWidget implements PreferredSizeWidget {
  const VideoAppBar({
    super.key,
    required this.source,
    this.actions,
    this.leading,
    this.contentPadding,
    this.height = 200,
    this.placeholder,
    this.loading,
    this.gradient,
    this.body,
    this.looping = true
  });

  final VideoAppBarSource source;
  final List<Widget>? actions;
  final Widget? leading;
  final EdgeInsetsGeometry? contentPadding;
  final double height;
  final Widget? placeholder;
  final Widget? loading;
  final Gradient? gradient;
  final Widget? body;
  final bool looping;

  @override
  State<VideoAppBar> createState() => _VideoAppbarState();
  
  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _VideoAppbarState extends State<VideoAppBar> {

  late VideoPlayerController controller;
  late bool hasError = false;

  @override
  void initState() {
    super.initState();
    
    switch (widget.source.sourceType) {
      case SourceType.assetSource:
        controller = VideoPlayerController.asset(
          widget.source.source,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: widget.looping
          )
        );
        break;
      
      case SourceType.networkSource:
        controller = VideoPlayerController.networkUrl(
          Uri.parse(
            widget.source.source
          ),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: widget.looping
          ),
          httpHeaders: widget.source.httpHeaders!
        );
        break;

      case SourceType.fileSource:
        controller = VideoPlayerController.file(
          widget.source.file!,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: widget.looping
          ), 
        );
        break;
    }

    controller.initialize().then((_) {
      controller.setVolume(0).then((value) => controller.play());
      controller.setLooping(widget.looping);
      setState(() {});
    });

    controller.addListener(() {
      if(controller.value.hasError){
        hasError = true;
        setState(() {});
        throw VideoAppbarException('${controller.value.errorDescription}');
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    final bool canPop = modalRoute?.canPop ?? false;
    final ThemeData theme  = Theme.of(context);
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          controller.value.isInitialized
              ? VideoPlayer(controller)
              : hasError
                ? widget.placeholder ?? Center(
                  child: Icon(
                    size: widget.height/4,
                    color: theme.hintColor,
                    Icons.error_outline_outlined
                  ),
                )
                : widget.leading ?? Center(
                    child: CircularProgressIndicator(color: theme.primaryColor),
                  ), 
          Container(
            decoration: BoxDecoration(
              gradient: widget.gradient
            ),
          ),
          Padding(
            padding: widget.contentPadding ?? const EdgeInsets.only(top: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(widget.leading != null) widget.leading!
                    else if (canPop)
                    IconButton(
                      color: theme.hintColor,
                      iconSize: 36,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(getLeading())
                    ),
                    
                    if(widget.actions != null)
                    Row(
                      children: [...widget.actions!],
                    )
                  ],
                ),
                if(widget.body != null) widget.body!
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData getLeading(){
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