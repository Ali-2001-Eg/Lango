import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      body: 
    Center(
      child: Text(error,style: const TextStyle(color: Colors.red),),
    )
      ,
    );
  }
}
