import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/auth_controller.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/custom_button.dart';

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
        title: const Text('Enter your phone number'),
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text('WhatsApp will need to verify your phone number.'),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: _pickCountry, child: const Text('Pick Country')),
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
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Phone number',
                            )),
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: CustomButton(
                  text: 'Next',
                  onPress: _submitPhoneNumber,
                ),
              )
            ],
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
      print('Ali');

      ref
          .read<AuthController>(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      print('error');
      customSnackBar('Fill out all the fields', context);
    }
  }
}
