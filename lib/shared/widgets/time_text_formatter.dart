import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class TimeTextFormatter extends StatelessWidget {
  final DateTime time;
  const TimeTextFormatter({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String timeText;
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      // Message was sent today
      timeText = DateFormat('h:mm a').format(time);
    } else if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day - 1) {
      // Message was sent yesterday
      timeText = 'Yesterday';
    } else {
      // Message was sent on a previous day
      timeText = DateFormat('M/d/yyyy').format(time);
    }
    return Text(
      timeText,
      style: getTextTheme(context)!.copyWith(fontSize: 13),
    );
  }
}
