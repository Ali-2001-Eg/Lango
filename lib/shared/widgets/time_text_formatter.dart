import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:Chat_Live/shared/utils/functions.dart';

import '../../generated/l10n.dart';

class TimeTextFormatter extends ConsumerWidget {
  final DateTime time;
  const TimeTextFormatter({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
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
      timeText = S.of(context).yesterday;
    } else {
      // Message was sent on a previous day
      timeText = DateFormat('M/d/yyyy').format(time);
    }
    return Text(
      timeText,
      style: getTextTheme(context, ref).copyWith(fontSize: 13),
    );
  }
}
