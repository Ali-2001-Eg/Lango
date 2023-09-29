import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_view/story_view.dart';
import 'package:whatsapp_clone/controllers/chat_controller.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/bottom_chat_field.dart';
import '../../controllers/message_reply_controller.dart';
import '../../models/status_model.dart';
import '../../repositories/auth_repo.dart';
import '../../shared/enums/message_enum.dart';

class StatusScreen extends ConsumerStatefulWidget {
  static const String routeName = '/status-screen';
  final List<StatusModel> status;
  final String receiverUid;
  const StatusScreen({
    Key? key,
    required this.receiverUid,
    required this.status,
  }) : super(key: key);

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  final StoryController _controller = StoryController();
  List<StoryItem> storyItems = [];

  final FocusNode focusNode = FocusNode();
  int _currentIndex = 0;
  @override
  void didChangeDependencies() {
    _displayStatusItems();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            StoryView(
              storyItems: storyItems,
              controller: _controller,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              onStoryShow: (storyItem) async {
                //to wait until first build
                if (!context.mounted) {
                  setState(() async {
                    _currentIndex = storyItems.indexOf(storyItem);
                  });
                }
              },
              indicatorForegroundColor: getTheme(context).cardColor,
              indicatorColor: getTheme(context).hoverColor,
              onComplete: () => Navigator.pop(context),
            ),
            (widget.receiverUid !=
                    ref.read(authRepositoryProvider).auth.currentUser!.uid)
                ? Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      children: [
                        _customReply(
                            context: context,
                            child: const Icon(
                              Icons.favorite,
                              size: 35,
                            ),
                            messageReply: '❤'),
                        _customReply(
                            context: context,
                            child: const Icon(
                              CupertinoIcons.flame_fill,
                              size: 35,
                            ),
                            messageReply: '🔥'),
                        _customReply(
                            context: context,
                            child: const Icon(
                              Icons.sentiment_dissatisfied_rounded,
                              size: 35,
                            ),
                            messageReply: '😤'),
                        _customReply(
                            context: context,
                            child: const Text(
                              '🙏',
                              style: TextStyle(fontSize: 20),
                            ),
                            messageReply: '🙏'),
                      ],
                    ))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  InkWell _customReply({
    required BuildContext context,
    required Widget child,
    required String messageReply,
  }) {
    return InkWell(
      onTap: () {
        sendReplyMessage(messageText: messageReply);
      },
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: getTheme(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: child),
        ],
      ),
    );
  }

  Future<void> _onStatusReply() async {
    ref.read(messageReplyProvider.state).update((state) => MessageReply(
          message: widget.status[_currentIndex].status,
          messageType: widget.status[_currentIndex].type,
          isMe: true,
        ));
  }

  void sendReplyMessage({required String messageText}) {
    _onStatusReply().then((value) => ref
            .read(chatControllerProvider)
            .sendTextMessage(context, messageText, widget.receiverUid, false)
            .then((value) {
          _cancelReply();
          customSnackBar(S.of(context).reply_snackbar, context,color: Colors.green);
          Navigator.pop(context);
        }));
  }

  void _cancelReply() {
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void _displayStatusItems() {
    ///check status type
    for (int i = 0; i < widget.status.length; i++) {
      if (widget.status[i].type == MessageEnum.text) {
        storyItems.add(StoryItem.text(
            title: widget.status[i].status, backgroundColor: backgroundColor));
      } else if (widget.status[i].type == MessageEnum.image) {
        storyItems.add(StoryItem.pageImage(
          url: widget.status[i].status,
          controller: _controller,
        ));
      } else {
        storyItems.add(StoryItem.pageVideo(widget.status[i].status,
            controller: _controller));
      }
    }
  }
}
