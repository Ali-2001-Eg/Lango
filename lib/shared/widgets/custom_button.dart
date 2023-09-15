import 'package:flutter/material.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  const CustomButton({Key? key, required this.text, required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
          backgroundColor:
              getTheme(context).floatingActionButtonTheme.backgroundColor,
          minimumSize: const Size(double.infinity, 50)),
      child: Center(
        child: Text(
          text,
          style: getTextTheme(context)!.copyWith(fontSize: 20),
        ),
      ),
    );
  }
}
