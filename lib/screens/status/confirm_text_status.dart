import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/status_controller.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';

import '../../shared/utils/colors.dart';
import '../../shared/utils/functions.dart';

class ConfirmTextScreen extends ConsumerWidget {
  ConfirmTextScreen({Key? key}) : super(key: key);
  final TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    focusNode.requestFocus();
    return Scaffold(
      backgroundColor: getTheme(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 1,
                    focusNode: focusNode,
                    //keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 35, decorationThickness: 0),
                    decoration: InputDecoration.collapsed(
                      hintText: S.of(context).status_hint,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getTheme(context).cardColor,
              ),
              child: IconButton(
                  onPressed: () => _controller.text.isNotEmpty
                      ? shareTextStatus(ref, context, _controller.text.trim())
                          .then((value) => Navigator.of(context).pop())
                      : customSnackBar(
                          S.of(context).empty_text_status_snackbar, context),
                  icon: const Icon(Icons.send))),
        ],
      ),
    );
  }

  Future<void> shareTextStatus(
      WidgetRef ref, BuildContext context, String statusText) async {
    ref.read(statusControllerProvider).shareStatus(
        type: MessageEnum.text, context: context, statusText: statusText);
  }
}
