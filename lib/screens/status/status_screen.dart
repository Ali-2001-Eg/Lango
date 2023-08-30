import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_view/story_view.dart';
import 'package:whatsapp_clone/repository/auth_repo.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/bottom_chat_field.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';
import '../../models/status_model.dart';
import '../../shared/enums/message_enum.dart';

class StatusScreen extends ConsumerStatefulWidget {
  static const String routeName = '/status-screen';
  final List<StatusModel> status;
  final String receiverUid;
  const StatusScreen(
      {Key? key, required this.receiverUid, required this.status})
      : super(key: key);

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  final StoryController _controller = StoryController();
  List<StoryItem> storyItems = [];
  final FocusNode focusNode = FocusNode();
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
    print(widget.status.length);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StoryView(
              storyItems: storyItems,
              controller: _controller,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              indicatorColor: messageColor,
              indicatorForegroundColor: tabColor,
              onComplete: () => Navigator.pop(context),
            ),
      floatingActionButton: (widget.receiverUid !=
              ref.read(authRepositoryProvider).auth.currentUser!.uid)
          ? Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () {
                  _controller.pause();
                  focusNode.requestFocus();
                  showModalBottomSheet(
                    context: context,
                    elevation: 0,
                    backgroundColor: backgroundColor,
                    constraints: BoxConstraints(
                      maxHeight: (size(context).height/2.5)+50
                    ),
                    builder: (context) {
                      return BottomChatFieldWidget(
                          receiverUid: widget.receiverUid);
                    },
                  ).then((value) {
                    _controller.play();
                    focusNode.unfocus();
                  });
                },
                backgroundColor: messageColor,
                elevation: 0,
                heroTag: 'btn5',
                child: Column(
                  children: const [
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Reply',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ))
          : null,
    );
  }

  void _displayStatusItems() {
    for (int i = 0; i < widget.status.length; i++) {
      if (widget.status[i].type == MessageEnum.text) {
        storyItems.add(StoryItem.text(
            title: widget.status[i].status, backgroundColor: backgroundColor));
      }
      if (widget.status[i].type == MessageEnum.image) {
        storyItems.add(StoryItem.pageImage(
          url: widget.status[i].status,
          controller: _controller,
        ));
      }
      if (widget.status[i].type == MessageEnum.video) {
        storyItems.add(StoryItem.pageVideo(widget.status[i].status,
            controller: _controller));
      }
    }
  }
}
