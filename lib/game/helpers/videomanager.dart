import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gameloader.dart';

class VideoPlayManager extends HookWidget {
  final String parameterVideo;
  final double parameterWidth;
  final double parameterHeight;
  final GameUtil gameUtil;

  VideoPlayManager({
    Key? key,
    required this.parameterVideo,
    required this.parameterWidth,
    required this.parameterHeight,
    required this.gameUtil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: VideoPlayerScreen(
      gameUtil: gameUtil,
      parameterVideo: parameterVideo,
      parameterWidth: parameterWidth,
      parameterHeight: parameterHeight,
    ));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String parameterVideo;
  final double parameterWidth;
  final double parameterHeight;

  final GameUtil gameUtil;

  VideoPlayerScreen({
    Key? key,
    required this.gameUtil,
    required this.parameterVideo,
    required this.parameterWidth,
    required this.parameterHeight,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoController _controller = VideoController.file(
    widget.gameUtil.assetManager
        .file('video/' + widget.parameterVideo + '.mp4'),
  );

  @override
  void initState() {
    super.initState();

    _controller
      ..initialize()
      ..play()
      ..waitFinish.then(
        (_) {
          if (widget.parameterVideo == 'splash') {
            if (!context.read(splashVideoFlag).state) {
              context.read(splashVideoFlag).state = true;
            }
          }
        },
      ).catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return OverflowBox(
            maxWidth: widget.parameterWidth,
            maxHeight: widget.parameterHeight,
            child: SizedBox(
              width: widget.parameterWidth,
              height: widget.parameterHeight,
              child: FittedVideoPlayer(
                controller: _controller,
              ),
            ),
          );
        } else {
          if (widget.parameterVideo == 'splash') {
            return OverflowBox(
              maxWidth: widget.parameterWidth,
              maxHeight: widget.parameterHeight,
              child: SizedBox(
                width: widget.parameterWidth,
                height: widget.parameterHeight,
                child: Container(
                  child: Image.file(
                    widget.gameUtil.assetManager.file("images/Splash.png"),
                  ),
                ),
              ),
            );
          }
          return Container();
        }
      },
    );
  }
}
