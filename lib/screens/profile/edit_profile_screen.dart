import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

import '../../controllers/profile_controller.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = '/edit-profille-screen';
  const EditProfileScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _HomePage();
  }
}

class _HomePage extends ConsumerState<EditProfileScreen> {
  UserModel? user;
  @override
  void initState() {
    getUserData(ref).then((value) {});
    super.initState();
  }

  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newDescriptionController =
      TextEditingController();
  final TextEditingController _newPhoneNumberController =
      TextEditingController();

  File? image;
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _newNameController.dispose();
    _newDescriptionController.dispose();
    _newPhoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          S.of(context).edit_profile,
          style: getTextTheme(context, ref),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: image != null
                    ? MainAxisAlignment.spaceEvenly
                    : MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      image == null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: CachedNetworkImageProvider(
                                user?.profilePic ??
                                    'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(
                                image!,
                              ),
                              radius: 100,
                            ),
                      Positioned(
                        bottom: -6,
                        right: 0,
                        child: IconButton(
                            onPressed: pickImage,
                            icon: Icon(
                              Icons.add_a_photo,
                              size: 25,
                              color: getTheme(context).hintColor,
                            )),
                      ),
                    ],
                  ),
                  Visibility(
                      visible: image != null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: getTheme(context).cardColor)),
                          child: IconButton(
                            onPressed: () {
                              ref
                                  .read(profileControllerProvider)
                                  .updateProfilePic(newProfilePic: image!.path)
                                  .then((value) => Navigator.pop(context));
                            },
                            icon: const Icon(Icons.done, color: Colors.white),
                          ),
                        ),
                      )),
                ],
              ),
              _buildProfileTile(
                context,
                S.of(context).username,
                user?.name ?? '',
                _newNameController,
                () {
                  ref
                      .read(profileControllerProvider)
                      .updateUsername(newUsername: _newNameController.text)
                      .then((value) => Navigator.pop(context));
                },
              ),
              _buildProfileTile(
                context,
                S.of(context).description,
                user?.description ?? '',
                _newDescriptionController,
                () {
                  ref
                      .read(profileControllerProvider)
                      .updateDescription(
                          newDescription: _newDescriptionController.text)
                      .then((value) => Navigator.pop(context));
                },
              ),
              _buildProfileTile(
                context,
                S.of(context).phone_nember,
                user?.phoneNumber ?? '',
                _newPhoneNumberController,
                textInputType: TextInputType.phone,
                () {
                  ref
                      .read(profileControllerProvider)
                      .updatePhoneNumber(
                          newPhonNumber: _newPhoneNumberController.text)
                      .then((value) => Navigator.pop(context));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildProfileTile(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller,
    VoidCallback onPressed, {
    TextInputType? textInputType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            label,
            style: getTextTheme(context, ref),
            textDirection: TextDirection.ltr,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: getTheme(context).appBarTheme.backgroundColor!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  controller: controller,
                  keyboardType: textInputType,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(decorationThickness: 0)),
                ),
              ),
            ),
            Visibility(
                visible: controller.text.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: getTheme(context)
                                .appBarTheme
                                .backgroundColor!)),
                    child: IconButton(
                      onPressed: onPressed,
                      icon: const Icon(Icons.done
                      
                      ),
                    ),
                  ),
                )),
          ],
        )
      ],
    );
  }

  Future<UserModel> getUserData(WidgetRef ref) async {
    return ref.read(profileControllerProvider).getUserData().then((value) {
      setState(() {
        user = value;
      });
      return value;
    });
  }

  pickImage() async {
    var pickedImage = await pickImageFromGallery(context);
    if (pickedImage != null) {
      print(pickedImage.path);
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }
}
