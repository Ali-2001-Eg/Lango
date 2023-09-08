import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/screens/home_screen.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import 'package:whatsapp_clone/shared/widgets/select_contact_widget.dart';

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
  final GlobalKey<ScaffoldState> myWidgetKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: myWidgetKey,
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Stack(
                children: [
                  _image == null
                      ? const CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.white,
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
                    right: 6,
                    child: IconButton(
                        onPressed: _selectImage,
                        icon: const Icon(
                          Icons.add_a_photo,
                          size: 25,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                style: const TextStyle(decorationThickness: 0),
                decoration: const InputDecoration(hintText: 'Enter Group Name'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Select Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SelectContactsWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn6',
        onPressed: _createGroup,
        backgroundColor: tabColor,
        elevation: 0,
        child: const Icon(
          Icons.check,
          color: Colors.white,
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
      customSnackBar('Please Enter Group Image And Name', context);
    }
  }
}
