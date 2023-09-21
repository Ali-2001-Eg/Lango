import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/functions.dart';

class MessageTextFormatterWidget extends StatelessWidget {
  final String text;
  const MessageTextFormatterWidget({Key? key, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Linkify(
        onOpen: (link) async {
          print('url is ${link.url}');

          try {
            if (await canLaunchUrlString(link.url)) {
              await launchUrlString('${link.url}');
            }
          } catch (e) {
            //print(e.toString());
            customSnackBar(e.toString(), context);
          }
        },
        text: text,
        style: getTextTheme(context),
        linkStyle: getTextTheme(context)!.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
