// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

import '../../shared/widgets/video_player_item.dart';

class ExpandedViewScreen extends ConsumerWidget {
  final String fileUrl;
  final MessageEnum fileType;
  final String? caption;
  const ExpandedViewScreen({
    super.key,
    required this.fileUrl,
    required this.fileType,
    this.caption = '',
  });
  static const String routeName = '/expanded-view-screen';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        child: Stack(children: [
          Positioned.fill(
            child: fileType == MessageEnum.image
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: fileUrl,
                    ),
                  )
                : VideoPlayerItem(url: fileUrl),
          ),
          if (caption != '')
            Positioned(
              bottom: 10,
              child: Container(
                width: size(context).width,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: getTheme(context).cardColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  caption!,
                  style: getTextTheme(context, ref),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
