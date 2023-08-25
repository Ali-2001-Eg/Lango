import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';
import 'package:whatsapp_clone/shared/widgets/pdf_viewerScreen.dart';
import 'package:whatsapp_clone/shared/widgets/video_player_item.dart';

import '../utils/colors.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final MessageEnum messageType;
  final Color textColor;
  final bool confirmScreen;
  final File? file;
  final String caption;
  const MessageWidget(
      {Key? key,
      required this.message,
      required this.messageType,
      this.confirmScreen = false,
      this.file,
      this.caption = '',
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    switch (messageType) {
      case MessageEnum.text:
        return Text(
          message,
          style: TextStyle(fontSize: 16, color: textColor),
        );
      case MessageEnum.audio:
        return StatefulBuilder(builder: (context, setState) {
          return IconButton(
              constraints: const BoxConstraints(
                minWidth: 100,
              ),
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audioPlayer.play(UrlSource(message));
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle));
        });
      case MessageEnum.image:
        return Container(
            constraints: BoxConstraints(
              maxHeight: size(context).height / 2.5,
              minHeight: size(context).height / 6,
            ),
            decoration: BoxDecoration(
                border: Border.all(color: messageColor, width: 2)),
            child: confirmScreen
                ? Image.file(
                    file!,
                    fit: BoxFit.cover,
                  )
                : Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: message,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) =>
                            CustomIndicator(value: progress.progress),
                      ),
                      if (caption != '')
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: size(context).width / 2),
                              color: messageColor,
                              alignment: AlignmentDirectional.centerEnd,
                              width: double.infinity,
                              child: Text(
                                caption,
                                // textAlign: TextAlign.end,
                                style:
                                    TextStyle(color: textColor, fontSize: 16),
                              )),
                        ),
                    ],
                  ));
      case MessageEnum.video:
        return Container(
          decoration:
              BoxDecoration(border: Border.all(color: messageColor, width: 2)),
          child: confirmScreen
              ? VideoPlayerItem(url: file!.path)
              : Stack(
                  children: [
                    VideoPlayerItem(url: message),
                    if (caption != '')
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                            constraints: BoxConstraints(
                                maxWidth: size(context).width / 2),
                            color: messageColor,
                            alignment: AlignmentDirectional.centerEnd,
                            width: double.infinity,
                            child: Text(
                              caption,
                              // textAlign: TextAlign.end,
                              style: TextStyle(color: textColor, fontSize: 16),
                            )),
                      ),
                  ],
                ),
        );
      case MessageEnum.gif:
        return Container(
            width: size(context).width / 2,
            constraints: BoxConstraints(
              maxHeight: size(context).height / 3,
              minHeight: size(context).height / 6,
            ),
            decoration: const BoxDecoration(
              color: backgroundColor,
            ),
            child: CachedNetworkImage(
              imageUrl: message,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) =>
                  CustomIndicator(value: progress.progress),
              // errorWidget: (context, url, error) => const Icon(
              //   Icons.error,
              //   color: Colors.red,
              // ),
            ));
      case MessageEnum.pdf:
        return ListTile(
          tileColor: messageColor,
          leading: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
            child: IconButton(
                onPressed: () async {
                  var dir = await getTemporaryDirectory();
                  var path = '${dir.path}/documents.pdf';
                  downloadFile(message, path)
                      .then((value) => print(path))
                      .catchError(
                          (e) => print('Error Occurred ${e.toString()}'));
                },
                icon: const Icon(Icons.download)),
          ),
          title: Column(
            children: [
              Text(
                caption,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ],
          ),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PdfViewerScreen(title: caption, pdfPath: message),
              )),
        );
    }
  }

  Future<void> downloadFile(String url, String savePath) async {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final file = File(savePath);
    await response.pipe(file.openWrite());
  }
}
