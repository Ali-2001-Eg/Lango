// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/shared/widgets/select_contact_widget.dart';

import '../../controllers/group_controller.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

File? _image;
final TextEditingController _controller = TextEditingController();

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  @override
  void dispose() {
    _image = null;
    //ref.read(selectGroupContacts.state).update((state) => []);
    _controller.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).create_group,
          //style: getTextTheme(context, ref),
        ),
        actions: [
          IconButton(
            onPressed: _createGroup,
            icon: const Icon(Icons.done),
            // style: ButtonStyle(
            //     backgroundColor:
            //         getTheme(context).iconButtonTheme.style!.iconColor),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          setState(() {
            _controller.clear();
            _image = null;
            ref.read(selectGroupContacts.state).update((state) => []);
          });
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: S.of(context).enter_group_name,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: getTheme(context)
                                  .inputDecorationTheme
                                  .fillColor!)),
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Stack(
                  children: [
                    _image == null
                        ? Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: getTheme(context)
                                    .appBarTheme
                                    .backgroundColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: const CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage: FileImage(
                              _image!,
                            ),
                            radius: 100,
                          ),
                    Positioned(
                      bottom: -6,
                      right: 0,
                      child: IconButton(
                          onPressed: _selectImage,
                          icon: Icon(
                            Icons.add_a_photo,
                            size: 25,
                            color: getTheme(context).hintColor,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                S.of(context).select_contact,
                style: getTextTheme(context, ref).copyWith(
                    color: getTheme(context).appBarTheme.backgroundColor),
              ),
              const SizedBox(
                height: 30,
              ),
              const SelectContactsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _selectImage() async {
    _image = await pickImageFromGallery(context);
    setState(() {});
  }

  void _createGroup() async {
    if (_controller.text.trim().isNotEmpty && _image != null) {
      ref.read(groupControllerProvider).createGroup(
            _controller.text.trim(),
            _image!,
            ref.read(selectGroupContacts),
          );
      //to empty the list after creating the group
      ref.read(selectGroupContacts.state).update((state) => []);
      await Future.delayed(
        const Duration(seconds: 1),
        () => Navigator.of(context).pop(),
      );
    } else {
      //customSnackBar('Please Enter Group Image And Name', context);
    }
  }
}
