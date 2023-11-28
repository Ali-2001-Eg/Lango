import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/screens/chat/expanded_view_scree.dart';
import 'package:Lango/shared/enums/message_enum.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/shared/widgets/pdf_viewer_screen.dart';
import 'package:Lango/shared/widgets/text_message_formatter_widget.dart';
import 'package:Lango/shared/widgets/video_player_item.dart';

import '../../generated/l10n.dart';
import '../managers/download_manager.dart';
import '../utils/colors.dart';
import 'audio_player_item.dart';

class MessageWidget extends ConsumerWidget {
  final String message;
  final MessageEnum messageType;
  final Color textColor;
  final bool confirmScreen;
  final File? file;
  final String caption;
  final String receiverUid;
  final bool isReply;
  const MessageWidget(
      {Key? key,
      required this.message,
      required this.messageType,
      required this.receiverUid,
      this.isReply = false,
      this.confirmScreen = false,
      this.file,
      this.caption = '',
      this.textColor = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    // print(message);
    switch (messageType) {
      case MessageEnum.text:
        return MessageTextFormatterWidget(
          text: message,
        );
      case MessageEnum.audio:
        return AudioPlayerItem(
          url: message,
          isReply: isReply,
        );
      case MessageEnum.image:
        return Container(
            constraints: BoxConstraints(
              maxHeight: isReply
                  ? size(context).height / 15
                  : size(context).height / 2.5,
              minWidth:
                  isReply ? size(context).width / 10 : size(context).width / 3,
              minHeight: isReply
                  ? size(context).height / 15
                  : size(context).height / 6,
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
                        onTap: () => isReply
                            ? null
                            : Navigator.pushNamed(
                                context,
                                ExpandedViewScreen.routeName,
                                arguments: {
                                  'file': message,
                                  'type': messageType,
                                  'caption': caption,
                                },
                              ),
                        child: Container(
                          decoration: BoxDecoration(
                              border: !isReply
                                  ? Border.all(
                                      color: getTheme(context).cardColor,
                                      width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(message),
                                fit: isReply ? null : BoxFit.fill,
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
                        border: isReply
                            ? null
                            : Border.all(color: getTheme(context).cardColor),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                                  context, ExpandedViewScreen.routeName,
                                  arguments: {
                                    'file': message,
                                    'type': messageType,
                                    'caption': caption,
                                  }),
                          child: VideoPlayerItem(
                            url: message,
                            isReply: isReply,
                          ))),
                  if (caption != '')
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        constraints:
                            BoxConstraints(maxWidth: size(context).width / 2),
                        color: Theme.of(context).cardColor,
                        alignment: AlignmentDirectional.center,
                        width: double.infinity,
                        child: Text(
                          caption,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              );
      case MessageEnum.gif:
        return isReply
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(S.of(context).gif_message,
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                  const Icon(Icons.gif_box),
                ],
              )
            : Container(
                width: size(context).width / 2,
                constraints: BoxConstraints(
                  maxHeight: size(context).height / 3,
                  minHeight: size(context).height / 6,
                ),
                decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: getTheme(context).cardColor, width: 2),
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(message),
                        fit: BoxFit.fill)),
              );
      case MessageEnum.pdf:
        if (isReply) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                S.of(context).pdf_message,
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(Icons.picture_as_pdf_outlined)
            ],
          );
        } else {
          int delimiterIndex = caption.lastIndexOf('.pdf');
          String fileName = caption.substring(0, delimiterIndex);
          String fileCaption = caption.substring(delimiterIndex + 8);
          return ListTile(
            tileColor: Theme.of(context).cardColor,
            title: Text(
              fileName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.white),
            ),
            subtitle: Text(
              fileCaption,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.file_download_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                ref.read(downloadManagerProvider).downloadFile(
                    fileUrl: message, fileType: messageType, context: context);
              },
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PdfViewerScreen(title: fileName, pdfPath: message),
                )),
          );
        }
    }
  }
}
