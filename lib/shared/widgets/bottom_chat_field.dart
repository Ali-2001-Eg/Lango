import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/controllers/chat_controller.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/screens/chat/confirm_file_screen.dart';
import 'package:whatsapp_clone/shared/widgets/message_reply_widget.dart';
import 'package:whatsapp_clone/shared/widgets/modal_bottom_sheet_item.dart';

import '../../controllers/message_reply_controller.dart';

class BottomChatFieldWidget extends ConsumerStatefulWidget {
  final String receiverUid;
  final bool isGroupChat;
  const BottomChatFieldWidget(
      {Key? key, required this.receiverUid, required this.isGroupChat})
      : super(key: key);

  @override
  ConsumerState<BottomChatFieldWidget> createState() =>
      _BottomChatFieldWidgetState();
}

class _BottomChatFieldWidgetState extends ConsumerState<BottomChatFieldWidget> {
  bool isTyping = false;
  bool emojiTyping = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;
  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    _soundRecorder!.closeRecorder();

    isRecorderInit = false;

    super.dispose();
  }

  @override
  void initState() {
    _soundRecorder = FlutterSoundRecorder();
    _openAudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final bool isShowMessageReply = messageReply != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          isShowMessageReply ? const MessageReplyWidget() : const SizedBox(),
          Row(
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
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: mobileChatBoxColor,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: 60,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: _selectKeyboardDisplayed,
                              child: const Icon(
                                Icons.emoji_emotions,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: _selectGif,
                              child: const Icon(
                                Icons.gif_box,
                                color: Colors.grey,
                              ),
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
                                    onTap: () =>
                                        _selectImage(ImageSource.camera),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.grey)),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                    onTap: () {
                                      _showModalBottomSheet();
                                      // _selectVideo(ImageSource.gallery);
                                    },
                                    child: const Icon(
                                        Icons.attach_file_outlined,
                                        color: Colors.grey)),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                    onTap: () =>
                                        _selectImage(ImageSource.gallery),
                                    child: const Icon(
                                      Icons.photo_camera_back,
                                      color: Colors.grey,
                                    )),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    hintText: 'Type a message...',
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
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 23,
                  child: GestureDetector(
                    onTap: _sendTextMessage,
                    child: Icon(
                      isTyping
                          ? Icons.send
                          : isRecording
                              ? Icons.close
                              : Icons.mic,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (emojiTyping)
            SizedBox(
              height: 310,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    _messageController.text =
                        _messageController.text + emoji.emoji;
                    isTyping = true;
                  });
                },
              ),
            )
        ],
      ),
    );
  }

  Future<void> _sendTextMessage() async {
    // print(isRecorderInit);
    if (isTyping && _messageController.text.isNotEmpty) {
      ref.read(chatControllerProvider).sendTextMessage(context,
          _messageController.text, widget.receiverUid, widget.isGroupChat);
      setState(() {
        isTyping = false;
        _messageController.text = '';
      });
    } else {
      if (!isRecorderInit) {
        return;
      }
      var dir = await getTemporaryDirectory();
      var path = '${dir.path}/chat_sound.aac';
      if (isRecording) {
        //to save our voice notes

        await _soundRecorder!.stopRecorder();
      } else {
        await _soundRecorder!.startRecorder(toFile: path);
        _sendFileMessage(File(path), MessageEnum.audio);
      }
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  Future<void> _selectImage(ImageSource source) async {
    File? image = (source == ImageSource.gallery)
        ? await pickImageFromGallery(context)
        : await pickImageFromCamera(context);
    if (image != null) {
      _navToConfirmFile(image, MessageEnum.image, '', widget.isGroupChat);
      // _sendFileMessage(image, MessageEnum.image);
    }
  }

  Future<void> _selectVideo(ImageSource source) async {
    File? video = (source == ImageSource.gallery)
        ? await pickVideoFromGallery(context)
        : await pickVideoFromCamera(context);
    if (video != null) {
      _navToConfirmFile(video, MessageEnum.video, '', widget.isGroupChat);

      // _sendFileMessage(video, MessageEnum.video);
    }
  }

  void _sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(context, file,
        widget.receiverUid, messageEnum, null, widget.isGroupChat);
  }

  Future<void> _selectGif() async {
    GiphyGif? gif = await pickGif(context);
    if (gif != null) {
      ref.read(chatControllerProvider).sendGifMessage(
          context, gif.url, widget.receiverUid, widget.isGroupChat);
    }
  }

  Future<void> _selectDoc() async {
    String? filePath = await pickFile();
    if (filePath != null) {
      int filenameIndex = filePath.lastIndexOf('/') + 1;
      String filename = filePath.substring(filenameIndex);

      print('file path is $filePath');
      print('file name is $filename');
      _navToConfirmFile(
          File(filePath), MessageEnum.pdf, filename, widget.isGroupChat);
    }
  }

  void _showEmojiKeyboard() {
    setState(() {
      emojiTyping = true;
    });
  }

  void _hideEmojiKeyboard() {
    setState(() {
      emojiTyping = false;
    });
  }

  void _selectKeyboardDisplayed() {
    if (emojiTyping) {
      _focusNode.requestFocus();
      _hideEmojiKeyboard();
    } else {
      _focusNode.unfocus();
      _showEmojiKeyboard();
    }
  }

  _openAudio() async {
    final PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      customSnackBar('Mic Permission not allowed', context);
      throw RecordingPermissionException('Mic Permission not allowed');
    }
    //permission has been granted so,
    await _soundRecorder!.openRecorder();
    setState(() {
      isRecorderInit = true;
    });
  }

  void _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      constraints: BoxConstraints(
        // maxWidth: size(context).width - 45,
        maxHeight: size(context).height / 2.5,
      ),
      useSafeArea: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ModalBottomSheetItem(
                    text: 'Document',
                    backgroundColor: Colors.purpleAccent,
                    onPress: () => _selectDoc(),
                    icon: Icons.book),
                ModalBottomSheetItem(
                    text: 'Camera',
                    backgroundColor: Colors.red,
                    onPress: () => _selectVideo(ImageSource.gallery),
                    icon: Icons.camera_alt_rounded),
                ModalBottomSheetItem(
                    text: 'Gallery',
                    backgroundColor: Colors.orangeAccent,
                    onPress: () => _selectImage(ImageSource.gallery),
                    icon: Icons.photo_camera_back),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ModalBottomSheetItem(
                    text: 'Audio',
                    backgroundColor: Colors.orangeAccent,
                    onPress: () {},
                    icon: Icons.headphones),
                ModalBottomSheetItem(
                    text: 'Location',
                    backgroundColor: Colors.green,
                    onPress: () {},
                    icon: Icons.location_on),
                ModalBottomSheetItem(
                    text: 'Contacts',
                    backgroundColor: Colors.blueAccent,
                    onPress: () {},
                    icon: Icons.person),
              ],
            ),
            ModalBottomSheetItem(
                text: 'Poll',
                backgroundColor: Colors.lightGreen,
                onPress: () {},
                icon: Icons.poll_rounded)
          ],
        ),
      ),
    );
  }

  _navToConfirmFile(
      File file, MessageEnum type, String filename, bool isGroupChat) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmFileScreen(
            message: file,
            messageType: type,
            filename: filename,
            receiverUid: widget.receiverUid,
            isGroupChat: isGroupChat,
          ),
        ));
  }
}
