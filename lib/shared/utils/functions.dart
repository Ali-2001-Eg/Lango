import 'dart:io';

import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

//screen size
Size size(BuildContext context) => MediaQuery.of(context).size;

//custom snack bar

void customSnackBar(String text, BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      elevation: 0,
      behavior: SnackBarBehavior.fixed,
      padding: const EdgeInsets.all(8),
      content: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          )),
    ));

//select image from gallery
Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    customSnackBar(e.toString(), context);
  }
  return image;
}

//camera
Future<File?> pickImageFromCamera(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    customSnackBar(e.toString(), context);
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    customSnackBar(e.toString(), context);
  }
  return video;
}

//camera video
Future<File?> pickVideoFromCamera(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.camera);

    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    customSnackBar(e.toString(), context);
  }
  return video;
}

Future<GiphyGif?> pickGif(BuildContext context) async {
  //Tm7ihHgYu7WJTXOo6bY0JgEXTN1Q1MYt
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
        context: context, apiKey: 'Tm7ihHgYu7WJTXOo6bY0JgEXTN1Q1MYt');
  } catch (e) {
    customSnackBar(e.toString(), context);
  }
  return gif;
}

Future<String?> pickFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!;
      return filePath;
    } else {
      return null; // User canceled the file picking process.
    }
  } catch (e) {
    print('Error while picking a file: $e');
    return null; // Handle any potential errors.
  }
}

void navTo(context, screen) => Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => screen,
    ));
void navToNamed(context, routeName) =>
    Navigator.of(context).pushNamed(routeName);
