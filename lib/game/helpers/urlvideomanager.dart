import 'dart:typed_data';

import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumping_syllables/game/statenotifiers/flagindexprovider.dart';
import '../gameloader.dart';

class URLVideoPlayManager extends HookWidget {
  final double parameterWidth;
  final double parameterHeight;
  final String videoURL;
  final String thumbnailURL;
  final Uint8List thumbnailBytes;
  final GameUtil gameUtil;

  URLVideoPlayManager({
    Key? key,
    required this.parameterWidth,
    required this.parameterHeight,
    required this.videoURL,
    required this.thumbnailURL,
    required this.thumbnailBytes,
    required this.gameUtil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: URLVideoPlayerScreen(
        parameterWidth: parameterWidth,
        parameterHeight: parameterHeight,
        videoURL: videoURL,
        thumbnailURL: thumbnailURL,
        thumbnailBytes: thumbnailBytes,
        gameUtil: gameUtil,
      ),
    );
  }
}

class URLVideoPlayerScreen extends StatefulWidget {
  final double parameterWidth;
  final double parameterHeight;
  final String videoURL;
  final String thumbnailURL;
  final Uint8List thumbnailBytes;
  final GameUtil gameUtil;

  URLVideoPlayerScreen({
    Key? key,
    required this.parameterWidth,
    required this.parameterHeight,
    required this.videoURL,
    required this.thumbnailURL,
    required this.thumbnailBytes,
    required this.gameUtil,
  }) : super(key: key);

  @override
  _URLVideoPlayerScreenState createState() => _URLVideoPlayerScreenState();
}

class _URLVideoPlayerScreenState extends State<URLVideoPlayerScreen> {
  late VideoController _controller = VideoController.network(
    widget.videoURL,
    options: VideoOptions(mixWithOthers: true),
  );

  @override
  void initState() {
    super.initState();

    _controller
      ..initialize()
      ..play()
      ..onFinish.listen(
        (event) {
          final _outroVideoFlag = PROVIDER_CONTAINER.read(outroVideoFlag);

          if (!_outroVideoFlag.flag) {
            _outroVideoFlag.setFlag(true);
          }

          if (_outroVideoFlag.videoRepeatFlag) {
            _controller.play();
          }
        },
      )
      ..initialization.then(
        (value) {
          PROVIDER_CONTAINER.listen<URLVideoState>(
            outroVideoFlag,
            didChange: (sub) async {
              final _outroVideoFlag = sub.read();
              if (_outroVideoFlag.videoRepeatFlag) {
                _controller.play();
              }

              if (_outroVideoFlag.flag == false) {
                try {
                  await widget.gameUtil.delayer.wait(milliseconds: 500);
                  _controller.play();
                } catch (_) {}
              }
            },
          );
        },
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (cctx, watch, child) {
        return FutureBuilder(
          future: _controller.initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                width: widget.parameterWidth - 10,
                height: widget.parameterHeight,
                child: FittedVideoPlayer(controller: _controller),
              );
            } else {
              return Container(
                width: widget.parameterWidth,
                height: widget.parameterHeight,
                child: Image.memory(widget.thumbnailBytes),
              );
            }
          },
        );
      },
    );
  }
}
