// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/enums/message_enum.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

import '../../generated/l10n.dart';
import '../../shared/managers/download_manager.dart';
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
      backgroundColor: getTheme(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        actions: [
          PopupMenuButton(itemBuilder: ((context) {
            return [
              PopupMenuItem(
                child: Text(
                  S.of(context).save,
                  style: getTextTheme(context, ref)
                      .copyWith(fontSize: 18, color: Colors.white),
                ),
                onTap: () {
                  ref
                      .read(downloadManagerProvider)
                      .downloadFile(
                        fileUrl: fileUrl,
                        fileType: fileType,
                        context: context,
                      )
                      .then((value) => customSnackBar(
                          S.of(context).download_snackbar, context,
                          color: Colors.green));
                },
              ),
            ];
          })),
        ],
      ),
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
                    color: getTheme(context).appBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  caption!,
                  style:
                      getTextTheme(context, ref).copyWith(color: Colors.white),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
