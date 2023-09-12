import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/message_reply_controller.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/widgets/message_widget.dart';

import '../../controllers/chat_controller.dart';
import '../../shared/utils/functions.dart';

class ConfirmFileScreen extends ConsumerStatefulWidget {
  final File message;
  final MessageEnum messageType;
  final String receiverUid;
  final String? filename;
  final bool isGroupChat;
  const ConfirmFileScreen(
      {Key? key,
      required this.message,
      required this.messageType,
      this.filename = '',
      required this.isGroupChat,
      required this.receiverUid})
      : super(key: key);

  @override
  ConsumerState<ConfirmFileScreen> createState() => _ConfirmFileScreenState();
}

class _ConfirmFileScreenState extends ConsumerState<ConfirmFileScreen> {
  final TextEditingController _captionController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.messageType == MessageEnum.pdf
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: tabColor,
                          size: 150,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(widget.filename!,
                            style: const TextStyle(
                                color: tabColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: MessageWidget(
                          message: widget.message.path,
                          messageType: widget.messageType,
                          confirmScreen: true,
                          file: widget.message),
                    ),
                  ),
          ),
          //editFileRow(),
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).floatingActionButtonTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: Theme.of(context).cardColor)),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Row(
              children: [
                Container(
                    width: size(context).width * 0.85,
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      style: const TextStyle(
                          color: Colors.black, decorationThickness: 0),
                      controller: _captionController,
                      decoration: InputDecoration(
                          hintText: S.of(context).add_caption,
                          prefixIcon: const Icon(
                            Icons.add_link,
                            color: Colors.black,
                          ),
                          hintStyle: const TextStyle(
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis),
                          fillColor: Colors.grey,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          )),
                    )),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .floatingActionButtonTheme
                        .backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      onPressed: () {
                        _sendFileMessage(widget.message, widget.messageType,
                            _captionController.text.trim());
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).cardColor,
                      )),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  Positioned editFileRow() {
    return Positioned(
      right: 10,
      top: 10,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
            ),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
            ),
            child: IconButton(
                onPressed: () {}, icon: const Icon(Icons.text_fields_sharp)),
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
            ),
            child:
                IconButton(onPressed: () {}, icon: const Icon(Icons.gif_sharp)),
          ),
        ],
      ),
    );
  }

  void _sendFileMessage(
      File file, MessageEnum messageEnum, String captionText) {
    try {
      ref.read(chatControllerProvider).sendFileMessage(
            context,
            file,
            widget.receiverUid,
            messageEnum,
            messageEnum == MessageEnum.pdf
                ? '${widget.filename} $captionText'
                : captionText,
            widget.isGroupChat,
          );
      Navigator.pop(context);
    } catch (e) {
      customSnackBar(e.toString(), context);
    }
  }
}
