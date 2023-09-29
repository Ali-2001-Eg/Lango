import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_button.dart';

import '../../generated/l10n.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login-screen';
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Country? country;
  final TextEditingController _phoneController = TextEditingController();
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('build');
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).enter_phone_num,
            style: getTextTheme(context, ref)),
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(S.of(context).login_heading,
                        style: getTextTheme(context, ref)),
                    const SizedBox(height: 10),
                    TextButton(
                        onPressed: _pickCountry,
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              getTheme(context).cardColor),
                        ),
                        child: Text(S.of(context).pick_country,
                            style: getTextTheme(context, ref))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (country != null) Text('+${country!.phoneCode}'),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: size(context).width * 0.7,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: S.of(context).phone_num,
                              )),
                        )
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 100),
                  child: CustomButton(
                    text: S.of(context).next,
                    onPress: _submitPhoneNumber,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //pick country
  void _pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (Country ctr) {
        setState(() {
          country = ctr;
        });
      },
    );
  }

  void _submitPhoneNumber() {
    String phoneNumber = _phoneController.text;
    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read<AuthController>(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      customSnackBar(S.of(context).login_snackbar_error, context);
    }
  }
}
