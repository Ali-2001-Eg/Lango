import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/status_controller.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';

import '../../shared/utils/colors.dart';

class ConfirmStatusScreen extends ConsumerWidget {
  static const routeName = '/confirm-status';
  final File file;
  final MessageEnum type;
  const ConfirmStatusScreen({super.key, required this.file,required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tabColor,
        onPressed: () => shareStatus(ref, context),
        child: const Icon(
          Icons.upload,
          color: Colors.white,
        ),
      ),
    );
  }
  void shareStatus(WidgetRef ref,BuildContext context){
    ref.read(statusControllerProvider).addFileStatus(type: type, context: context, statusMedia: file);
    Navigator.pop(context);
  }
}
