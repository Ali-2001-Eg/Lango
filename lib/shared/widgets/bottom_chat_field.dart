// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:Lango/controllers/chat_controller.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/screens/chat/confirm_file_screen.dart';
import 'package:Lango/screens/chat/maps_screen.dart';
import 'package:Lango/shared/enums/message_enum.dart';
import 'package:Lango/shared/utils/colors.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/shared/widgets/message_reply_widget.dart';
import 'package:Lango/shared/widgets/modal_bottom_sheet_item.dart';

import '../../controllers/message_reply_controller.dart';

// ignore: must_be_immutable
class BottomChatFieldWidget extends ConsumerStatefulWidget {
  final String receiverUid;
  final bool isGroupChat;

  FocusNode? focusNode = FocusNode();
  BottomChatFieldWidget({
    Key? key,
    required this.receiverUid,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatFieldWidget> createState() =>
      _BottomChatFieldWidgetState();
}

class _BottomChatFieldWidgetState extends ConsumerState<BottomChatFieldWidget> {
  bool isTyping = false;
  bool emojiTyping = false;
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;
  @override
  void dispose() {
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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            isShowMessageReply
                ? MessageReplyWidget(
                    receiverUid: widget.receiverUid,
                  )
                : const SizedBox(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    constraints:
                        BoxConstraints(maxHeight: size(context).height / 10),
                    child: TextField(
                      textAlign: TextAlign.center,
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
                      focusNode: widget.focusNode,
                      maxLines: null,
                      style: getTextTheme(context, ref)
                          .copyWith(fontSize: 16, decorationThickness: 0),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            getTheme(context).inputDecorationTheme.fillColor,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: size(context).width / 6,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    _selectKeyboardDisplayed();
                                  },
                                  child: Icon(
                                    Icons.emoji_emotions,
                                    color: getTheme(context)
                                        .inputDecorationTheme
                                        .iconColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: _selectGif,
                                  child: Icon(
                                    Icons.gif_box,
                                    color: getTheme(context)
                                        .inputDecorationTheme
                                        .iconColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        suffixIcon: !isTyping
                            ? SizedBox(
                                width: size(context).width / 6,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                        onTap: () =>
                                            _selectImage(ImageSource.camera),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: getTheme(context)
                                              .inputDecorationTheme
                                              .iconColor,
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          _showModalBottomSheet();
                                          // _selectVideo(ImageSource.gallery);
                                        },
                                        child: Icon(
                                          Icons.attach_file_outlined,
                                          color: getTheme(context)
                                              .inputDecorationTheme
                                              .iconColor,
                                        )),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                        hintText: S.of(context).chat_box_hint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: CircleAvatar(
                    backgroundColor:
                        getTheme(context).inputDecorationTheme.iconColor,
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
      ),
    );
  }

  Future<void> _sendTextMessage() async {
    // debugPrint(isRecorderInit);
    if (isTyping && _messageController.text.isNotEmpty) {
      // print(_messageController.text);
      // print(widget.isGroupChat);
      // print(widget.receiverUid);

      ref.read(chatControllerProvider).sendTextMessage(
          context,
          _messageController.text.trim(),
          widget.receiverUid,
          widget.isGroupChat);
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
        _sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(toFile: path);
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
      _navToConfirmFile(
          context, image, MessageEnum.image, '', widget.isGroupChat);
      // _sendFileMessage(image, MessageEnum.image);
    }
  }

  Future<void> _selectVideo(ImageSource source) async {
    File? video = (source == ImageSource.gallery)
        ? await pickVideoFromGallery(context)
        : await pickVideoFromCamera(context);
    if (video != null) {
      _navToConfirmFile(
          context, video, MessageEnum.video, '', widget.isGroupChat);

      // _sendFileMessage(video, MessageEnum.video);
    }
  }

  void _sendFileMessage(File file, MessageEnum messageEnum) {
    print('Ali');
    ref.read(chatControllerProvider).sendFileMessage(context, file,
        widget.receiverUid, messageEnum, null, widget.isGroupChat);
  }

  Future<void> _selectGif() async {
    GiphyGif? gif = await pickGif(context);
    if (gif != null && context.mounted) {
      ref.read(chatControllerProvider).sendGifMessage(
          context, gif.url, widget.receiverUid, widget.isGroupChat);
    }
  }

  Future<void> _selectDoc() async {
    String? filePath = await pickFile();
    if (filePath != null) {
      int filenameIndex = filePath.lastIndexOf('/') + 1;
      String filename = filePath.substring(filenameIndex);

      _navToConfirmFile(context, File(filePath), MessageEnum.pdf, filename,
          widget.isGroupChat);
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
      widget.focusNode!.requestFocus();
      _hideEmojiKeyboard();
    } else {
      widget.focusNode!.unfocus();
      _showEmojiKeyboard();
    }
  }

  _openAudio() async {
    final PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted && context.mounted) {
      customSnackBar(S.of(context).mic_permission_snackbar, context);
      throw RecordingPermissionException(S.of(context).mic_permission_snackbar);
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
      //backgroundColor: getTheme(context).appBarTheme.backgroundColor,
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
                    text: S.of(context).doc,
                    backgroundColor: Colors.purpleAccent,
                    onPress: () => _selectDoc(),
                    icon: Icons.book),
                ModalBottomSheetItem(
                    text: 'video',
                    backgroundColor: Colors.red,
                    onPress: () => _selectVideo(ImageSource.gallery),
                    icon: Icons.video_camera_back_outlined),
                ModalBottomSheetItem(
                    text: S.of(context).gal,
                    backgroundColor: Colors.orangeAccent,
                    onPress: () => _selectImage(ImageSource.gallery),
                    icon: Icons.photo_camera_back),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ModalBottomSheetItem(
                    text: S.of(context).loc,
                    backgroundColor: Colors.green,
                    onPress: () {
                      Future(() => navTo(
                          context,
                          MapsScreen(
                              receiverUid: widget.receiverUid,
                              isGroupChat: widget.isGroupChat)));
                    },
                    icon: Icons.location_on),
                ModalBottomSheetItem(
                    text: S.of(context).new_video,
                    backgroundColor: Colors.blueAccent,
                    onPress: () {
                      _selectVideo(ImageSource.camera);
                    },
                    icon: Icons.video_call),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _navToConfirmFile(BuildContext context, File file, MessageEnum type,
      String filename, bool isGroupChat) {
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
