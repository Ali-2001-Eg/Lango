import 'package:flutter/material.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';

class CustomIndicator extends StatelessWidget {
  final double height;
  const CustomIndicator({Key? key, this.height = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Container(
        height: height,
        width: height,
        padding: const EdgeInsets.all(10),
        child: const CircularProgressIndicator(color: tabColor,strokeWidth: 5),
      ),
    );
  }
}
