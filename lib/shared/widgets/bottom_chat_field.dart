import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/chat_controller.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';

class BottomChatFieldWidget extends ConsumerStatefulWidget {
  final String receiverUid;
  const BottomChatFieldWidget({Key? key, required this.receiverUid})
      : super(key: key);

  @override
  ConsumerState<BottomChatFieldWidget> createState() =>
      _BottomChatFieldWidgetState();
}

class _BottomChatFieldWidgetState extends ConsumerState<BottomChatFieldWidget> {
  bool isTyping = false;
  final TextEditingController _messageController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    isTyping = true;
                  });
                }
                if (_messageController.text == '') {
                  setState(() {
                    isTyping = false;
                  });
                }
              },
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: mobileChatBoxColor,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 60,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.emoji_emotions,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.gif_box,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                suffixIcon: !isTyping
                    ? SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {},
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.grey)),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                                onTap: () {},
                                child: const Icon(Icons.attach_file_outlined,
                                    color: Colors.grey)),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                                onTap: () {},
                                child: const Icon(
                                  Icons.photo_camera_back,
                                  color: Colors.grey,
                                )),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35),
                  borderSide:
                      const BorderSide(width: 0, style: BorderStyle.none),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 23,
              child: GestureDetector(
                onTap: () {
                  if (isTyping && _messageController.text.isNotEmpty) {
                    _sendTextMessage();
                  }
                },
                child: Icon(
                  isTyping ? Icons.send : Icons.mic,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTextMessage() async {
    if (isTyping) {
      ref.read(chatControllerProvider).sendTextMessage(
          context, _messageController.text, widget.receiverUid);
    }
    setState(() {
      isTyping = false;
      _messageController.text = '';
    });
  }
}
