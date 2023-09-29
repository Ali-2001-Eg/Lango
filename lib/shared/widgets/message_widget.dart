import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/screens/chat/expanded_view_scree.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';
import 'package:whatsapp_clone/shared/widgets/pdf_viewerScreen.dart';
import 'package:whatsapp_clone/shared/widgets/text_message_formatter_widget.dart';
import 'package:whatsapp_clone/shared/widgets/video_player_item.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/message_reply_controller.dart';
import '../../repositories/auth_repo.dart';
import '../utils/colors.dart';
import 'audio_player_item.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final MessageEnum messageType;
  final Color textColor;
  final bool confirmScreen;
  final File? file;
  final String caption;
  final String receiverUid;

  const MessageWidget(
      {Key? key,
      required this.message,
      required this.messageType,
      required this.receiverUid,
      this.confirmScreen = false,
      this.file,
      this.caption = '',
      this.textColor = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(message);
    switch (messageType) {
      case MessageEnum.text:
        return MessageTextFormatterWidget(
          text: message,
        );
      case MessageEnum.audio:
        return AudioPlayerItem(
          url: message,
        );
      case MessageEnum.image:
        return Container(
            constraints: BoxConstraints(
              maxHeight: size(context).height / 2.5,
              minHeight: size(context).height / 6,
            ),
            child: confirmScreen
                ? Image.file(
                    file!,
                    fit: BoxFit.cover,
                  )
                : Stack(
                    clipBehavior: Clip.antiAlias,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, ExpandedViewScreen.routeName,
                            arguments: {'file': message, 'type': messageType}),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: getTheme(context).cardColor),
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(message),
                                fit: BoxFit.fill,
                              )),
                        ),
                      ),
                      if (caption != '')
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: size(context).width / 2),
                              color: Theme.of(context).cardColor,
                              alignment: AlignmentDirectional.center,
                              width: double.infinity,
                              child: Text(
                                caption,
                                // textAlign: TextAlign.end,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Colors.white),
                              )),
                        ),
                    ],
                  ));
      case MessageEnum.video:
        return confirmScreen
            ? VideoPlayerItem(url: file!.path)
            : Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: getTheme(context).cardColor),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                                  context, ExpandedViewScreen.routeName,
                                  arguments: {
                                    'file': message,
                                    'type': messageType
                                  }),
                          child: VideoPlayerItem(url: message))),
                  if (caption != '')
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Text(
                        caption,
                        // textAlign: TextAlign.end,
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                ],
              );
      case MessageEnum.gif:
        return Container(
          width: size(context).width / 2,
          constraints: BoxConstraints(
            maxHeight: size(context).height / 3,
            minHeight: size(context).height / 6,
          ),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: getTheme(context).cardColor, width: 2),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(message),
                  fit: BoxFit.fill)),
        );
      case MessageEnum.pdf:
        return ListTile(
          tileColor: Theme.of(context).cardColor,
          title: Column(
            children: [
              Text(
                caption,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white),
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
