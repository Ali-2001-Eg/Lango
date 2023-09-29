// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';

class ExpandedViewScreen extends ConsumerWidget {
  final String fileUrl;
  final MessageEnum fileType;
  const ExpandedViewScreen({
    super.key,
    required this.fileUrl,
    required this.fileType,
  });
  static const String routeName = '/expanded-view-screen';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(fileType.type)),
    );
  }
}
