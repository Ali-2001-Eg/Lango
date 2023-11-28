import 'package:flutter/material.dart';
import 'package:Lango/shared/utils/functions.dart';

class CustomIndicator extends StatelessWidget {
  final double height;
  final double? value;
  const CustomIndicator({Key? key, this.height = 50, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height,
        width: height,
        padding: const EdgeInsets.all(10),
        child: CircularProgressIndicator(
          color: getTheme(context).cardColor,
          strokeWidth: 5,
          value: value,
        ),
      ),
    );
  }
}
