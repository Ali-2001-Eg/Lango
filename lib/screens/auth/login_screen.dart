// ignore_for_file: unused_import

import 'package:Lango/repositories/status_repo.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/auth_controller.dart';
import 'package:Lango/shared/utils/colors.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/shared/widgets/custom_button.dart';

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
    // debugPrint('build');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).enter_phone_num,
        ),
        //backgroundColor: backgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).login_heading,
                        style: getTextTheme(context, ref)),
                    SizedBox(height: size(context).height / 8),
                    ElevatedButton(
                        onPressed: _pickCountry,
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              getTheme(context).hoverColor),
                        ),
                        child: Text(S.of(context).pick_country,
                            style: getTextTheme(context, ref)
                                .copyWith(color: Colors.white))),
                    SizedBox(height: size(context).height / 4),
                    const SizedBox(height: 10),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          if (country != null)
                            Text(
                              '+${country!.phoneCode}',
                              style: getTextTheme(context, ref),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                                textAlign: TextAlign.center,
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: getTextTheme(context, ref),
                                decoration: InputDecoration(
                                  hintText: S.of(context).phone_num,
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                if (!ref.watch(loadingProvider))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 100),
                    child: CustomButton(
                      text: S.of(context).next,
                      onPress: _submitPhoneNumber,
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator())
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
      countryListTheme: CountryListThemeData(
        backgroundColor: getTheme(context).hoverColor,
        textStyle: const TextStyle(color: Colors.white),
        searchTextStyle: const TextStyle(
          color: Colors.white,
          decorationThickness: 0,
        ),
        bottomSheetHeight: size(context).height / 1.5,
        inputDecoration: InputDecoration(
          hintText: S.of(context).search_hint,
          filled: true,
          fillColor: Colors.white10,
          hintStyle: const TextStyle(color: Colors.white),
        ),
      ),
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
    if (phoneNumber.isNotEmpty) {
      // print('+${country!.phoneCode}$phoneNumber');
      ref
          .read<AuthController>(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      customSnackBar(S.of(context).login_snackbar_error, context);
    }
  }
}
