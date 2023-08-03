import 'package:flutter/material.dart';
import 'package:whatsapp_clone/screens/auth/login_screen.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Welcome To WhatsApp',
              style: TextStyle(fontSize: 33, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: size(context).height / 6),
            Image.asset(
              'assets/images/badge.png',
              width: 340,
              height: 340,
              color: tabColor,
            ),
            SizedBox(height: size(context).height / 9),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Read our Privacy Policy. Tap "Agree and continue to accept the Terms of Services"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                width: size(context).width * 0.75,
                child: CustomButton(
                  text: 'AGREE AND CONTINUE',
                  onPress: () =>
                      Navigator.pushNamed(context, LoginScreen.routeName),
                ))
          ],
        ),
      ),
    );
  }
}
