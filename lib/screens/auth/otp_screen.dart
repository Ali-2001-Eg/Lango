import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class OtpScreen extends ConsumerWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;
  OtpScreen({Key? key, required this.verificationId}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print(verificationId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(S.of(context).verify_num),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(S.of(context).sms_sent),
            SizedBox(
              width: size(context).width * 0.5,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyOtp(context, value.trim(), ref);
                  }
                },
                decoration: const InputDecoration(
                  hintText: '- - - - - - ',
                  hintStyle: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _verifyOtp(
      BuildContext context, String otpSubmittedFromUser, WidgetRef ref) {
    ref.read<AuthController>(authControllerProvider).verifyOtp(
        context: context,
        verificationId: verificationId,
        otpSubmittedFromUser: otpSubmittedFromUser);
  }
}
