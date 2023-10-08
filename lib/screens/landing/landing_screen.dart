import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/screens/auth/login_screen.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_button.dart';
import 'package:whatsapp_clone/generated/l10n.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    var name = MediaQuery.of(context).orientation.name;
    print(name);
    return SafeArea(
      child: Scaffold(
        //appBar: AppBar(),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              //        mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text(
                  S.of(context).welcome_landing,
                  style: getTextTheme(context, ref),
                ),
                SizedBox(height: size(context).height / 6),
                Image.asset(
                  'assets/images/badge.png',
                  width: 340,
                  height: 340,
                  color: tabColor,
                ),
                SizedBox(height: size(context).height / 9),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    S.of(context).read_our_privacy,
                    textAlign: TextAlign.center,
                    style: getTextTheme(context, ref).copyWith(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                    width: size(context).width * 0.75,
                    child: CustomButton(
                      text: S.of(context).agree_continue,
                      onPress: () =>
                          Navigator.pushNamed(context, LoginScreen.routeName),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
