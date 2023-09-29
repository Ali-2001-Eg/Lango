import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class VideoPlayerItem extends StatefulWidget {
  final String url;
  final bool isReply;
  const VideoPlayerItem({Key? key, required this.url, this.isReply = false})
      : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerController videoPlayerController;
  bool isPlay = true;

  @override
  void initState() {
    videoPlayerController = CachedVideoPlayerController.network(widget.url)
      ..initialize().then((value) {
        videoPlayerController.setVolume(1);
      });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.isReply ? 3 / 3 : 9 / 9,
      child: Stack(
        children: [
          CachedVideoPlayer(videoPlayerController),
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
