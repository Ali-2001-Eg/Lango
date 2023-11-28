import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:Lango/shared/utils/functions.dart';

import '../../generated/l10n.dart';

class VideoPlayerItem extends StatefulWidget {
  final String url;
  final bool isReply;
  const VideoPlayerItem({Key? key, required this.url, this.isReply = false})
      : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  bool isPlay = true;

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((value) {
        videoPlayerController.setVolume(1);
        //videoPlayerController.play();
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isReply
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(S.of(context).video_message,
                  style: const TextStyle(
                    color: Colors.white,
                  )),
              const Icon(Icons.video_call),
            ],
          )
        : AspectRatio(
            aspectRatio: 6 / 8,
            child: Stack(
              children: [
                VideoPlayer(videoPlayerController),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: getTheme(context).hoverColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (isPlay) {
                          videoPlayerController.pause();
                        } else {
                          videoPlayerController.play();
                        }

                        setState(() {
                          isPlay = !isPlay;
                        });
                      },
                      icon: Icon(
                        isPlay ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
