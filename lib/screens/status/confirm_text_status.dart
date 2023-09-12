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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 2,
                    keyboardType: TextInputType.visiblePassword,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 20, decorationThickness: 0),
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
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: messageColor),
              child: IconButton(
                  onPressed: () => _controller.text.isNotEmpty
                      ? shareTextStatus(ref, context, _controller.text.trim())
                          .then((value) => Navigator.of(context).pop())
                      : customSnackBar('Status cannot be empty', context),
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
