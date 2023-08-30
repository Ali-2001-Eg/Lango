import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/status_controller.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/widgets/video_player_item.dart';

import '../../shared/utils/colors.dart';

class ConfirmFileStatus extends ConsumerWidget {
  static const routeName = '/confirm-status';
  final File file;
  final MessageEnum type;
  const ConfirmFileStatus({super.key, required this.file,required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print(type.type);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: type==MessageEnum.image? Image.file(file):VideoPlayerItem(url: file.path),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tabColor,
        onPressed: () => shareFileStatus(ref, context),
        child: const Icon(
          Icons.upload,
          color: Colors.white,
        ),
      ),
    );
  }
  void shareFileStatus(WidgetRef ref,BuildContext context){
    ref.read(statusControllerProvider).shareStatus(type: type, context: context, statusMedia: file);
    Navigator.pop(context);
  }
}
