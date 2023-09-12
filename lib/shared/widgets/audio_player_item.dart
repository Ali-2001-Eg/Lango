import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class AudioPlayerItem extends StatefulWidget {
  final String url;

  const AudioPlayerItem({super.key, required this.url});

  @override
  State<AudioPlayerItem> createState() => _AudioPlayerItemState();
}

class _AudioPlayerItemState extends State<AudioPlayerItem> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
    audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
    super.initState();
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
        child: audioPlayerBody(context, formattedTime));
  }

  Column audioPlayerBody(
      BuildContext context, String Function(int timeSeconds) formattedTime) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: getTheme(context).inputDecorationTheme.iconColor,
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
              data: SliderThemeData(),
              child: Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                activeColor: getTheme(context).appBarTheme.backgroundColor,
                //inactiveColor: getTheme(context).splashColor,
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                  await audioPlayer.resume();
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              formattedTime(position.inSeconds),
              style: getTextTheme(context)!.copyWith(height: 0, fontSize: 16),
            ),
            SizedBox(width: size(context).width / 3),
            //remaining time
            Text(
              '- ${formattedTime((duration - position).inSeconds)}',
              style: getTextTheme(context)!.copyWith(height: 0, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
