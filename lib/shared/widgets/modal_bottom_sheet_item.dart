import 'package:flutter/material.dart';

class ModalBottomSheetItem extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPress;
  final IconData icon;
  const ModalBottomSheetItem({Key? key, required this.text, required this.backgroundColor, required this.onPress, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: backgroundColor,
          radius: 30,
          child: IconButton(icon: Icon(icon, size: 30,color: Colors.white,),onPressed:(){
            onPress();
            Navigator.pop(context);
          }),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(color: Colors.grey[500],fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
