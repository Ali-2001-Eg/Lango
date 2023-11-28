import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/functions.dart';

class MessageTextFormatterWidget extends ConsumerWidget {
  final String text;
  final bool isReply;
  const MessageTextFormatterWidget(
      {Key? key, required this.text, this.isReply = false})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Linkify(
        maxLines: null,
        onOpen: (link) async {
          // print('url is ${link.url}');

          try {
            if (await canLaunchUrlString(link.url)) {
              await launchUrlString(link.url);
            } else {
              Clipboard.setData(ClipboardData(text: link.url));
              if (context.mounted) {
                customSnackBar('Link Coppied', context, color: Colors.green);
              }
            }
          } catch (e) {
            //print(e.toString());
            customSnackBar(e.toString(), context);
          }
        },
        text: text,
        style: getTextTheme(context, ref).copyWith(
            color: Colors.white,
            fontSize: isReply ? 10 : 20,
            overflow: TextOverflow.ellipsis),
        linkStyle: getTextTheme(context, ref).copyWith(
          fontSize: isReply ? 10 : 10,
          fontWeight: FontWeight.w700,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
