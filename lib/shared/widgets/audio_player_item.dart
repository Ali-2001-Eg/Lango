import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

import '../../generated/l10n.dart';

class AudioPlayerItem extends ConsumerStatefulWidget {
  final String url;
  final bool isReply;
  const AudioPlayerItem({super.key, required this.url, this.isReply = false});

  @override
  ConsumerState<AudioPlayerItem> createState() => _AudioPlayerItemState();
}

class _AudioPlayerItemState extends ConsumerState<AudioPlayerItem> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    audioPlayer = AudioPlayer();
    _initAudio();
    super.initState();
  }

  void _initAudio() {
    if (context.mounted) {
      audioPlayer.onPlayerStateChanged.listen((query) {
        setState(() {
          isPlaying = query == PlayerState.playing;
        });
      });

      audioPlayer.onDurationChanged.listen((query) {
        setState(() {
          duration = query;
        });
      });
      audioPlayer.onPositionChanged.listen((query) {
        setState(() {
          position = query;
        });
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime(int timeSeconds) =>
        '${(timeSeconds ~/ 60).toString().padLeft(2, '0')}:${(timeSeconds % 60).toString().padLeft(2, '0')}';
    return Container(
        decoration: BoxDecoration(
            color: getTheme(context).cardColor,
            borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.all(8),
        child: widget.isReply
            ?  Text(
                S.of(context).voice_message,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              )
            : audioPlayerBody(context, formattedTime, ref));
  }

  Column audioPlayerBody(BuildContext context,
      String Function(int timeSeconds) formattedTime, ref) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: getTheme(context).hoverColor,
              child: IconButton(
                //iconSize: 20,
                //style: getTheme(context).iconButtonTheme.style,
                icon: isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    // print('audio message url is: ${widget.url}');
                    await audioPlayer.play(UrlSource(widget.url));
                  }
                },
              ),
            ),
            SliderTheme(
              data: const SliderThemeData(),
              child: Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                activeColor: getTheme(context).hoverColor,
                inactiveColor: getTheme(context).splashColor,
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                  await audioPlayer.resume();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              formattedTime(position.inSeconds),
              style: getTextTheme(context, ref)
                  .copyWith(height: 0, fontSize: 16, color: Colors.white),
            ),
            SizedBox(width: size(context).width / 3),
            //remaining time
            Text(
              '- ${formattedTime((duration - position).inSeconds)}',
              style: getTextTheme(context, ref)
                  .copyWith(height: 0, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
