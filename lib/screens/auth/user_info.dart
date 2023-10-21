import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Chat_Live/controllers/auth_controller.dart';
import 'package:Chat_Live/generated/l10n.dart';
import 'package:Chat_Live/shared/utils/functions.dart';
import 'package:Chat_Live/shared/widgets/custom_button.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const routeName = '/user-info';
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? image;
  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    image == null
                        ? const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                              'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage: FileImage(
                              image!,
                            ),
                            radius: 64,
                          ),
                    Positioned(
                      bottom: -10,
                      right: 0,
                      child: IconButton(
                          onPressed: () => _selectImage(),
                          icon: const Icon(Icons.add_a_photo)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: size(context).width * 0.85,
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: S.of(context).enter_name,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: size(context).width * 0.85,
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: S.of(context).enter_description,
                        ),
                      ),
                    ),
                    SizedBox(height: size(context).height / 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: CustomButton(
                        text: S.of(context).save,
                        onPress: () => _storeUserData(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectImage() async {
    // print('Ali');
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  Future<void> _storeUserData() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    if (name.isNotEmpty && description.isNotEmpty) {
      await ref
          .read(authControllerProvider)
          .saveUserDataToFireStore(context, name, image, description);
    } else {
      // print('error');
      customSnackBar(S.of(context).missed__info_field, context);
    }
  }
}
