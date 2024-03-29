import 'dart:io';

import 'package:Lango/shared/widgets/custom_stream_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:Lango/controllers/status_controller.dart';
import 'package:Lango/generated/l10n.dart';
import 'package:Lango/screens/status/confirm_text_status.dart';
import 'package:Lango/screens/status/status_screen.dart';
// import 'package:Lango/shared/utils/base/error_screen.dart';
import 'package:Lango/shared/utils/colors.dart';
// import 'package:Lango/shared/widgets/custom_indicator.dart';

import '../../models/status_model.dart';
import '../../repositories/status_repo.dart';
import '../../shared/enums/message_enum.dart';
import '../../shared/utils/functions.dart';
import 'confirm_file_status_screen.dart';

class StatusContactsScreen extends ConsumerWidget {
  StatusContactsScreen({super.key});
  final List<StatusModel> orderedList = [];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);

    return Scaffold(
      body: CustomStreamOrFutureWidget<List<List<StatusModel>>>(
        stream: statusProvider,
        builder: (data) {
          if (data.isEmpty) {
            return loading
                ? Column(
                    children: [
                      LinearProgressIndicator(
                          color: getTheme(context).cardColor),
                      Text(
                        S.of(context).uploading_status,
                        style: getTextTheme(context, ref),
                      )
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 200,
                            child:
                                Lottie.asset('assets/json/empty_search.json')),
                        Text(
                          S.of(context).empty_status_list,
                          style:
                              getTextTheme(context, ref).copyWith(fontSize: 16),
                        ),
                        Text(
                          S.of(context).empty_status_list_sub_title,
                          style:
                              getTextTheme(context, ref).copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  );
          } else {
            _removeRedundantName(data);
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (loading) ...[
                    Column(
                      children: [
                        LinearProgressIndicator(
                            color: getTheme(context).cardColor),
                        Text(
                          S.of(context).uploading_status,
                          style: getTextTheme(context, ref),
                        )
                      ],
                    )
                  ],
                  ListView.builder(
                      itemCount: orderedList.length,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        var status = orderedList[i];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                //debugPrint(status.audience);
                                Navigator.pushNamed(
                                  context,
                                  StatusScreen.routeName,
                                  arguments: {
                                    'status': data[i],
                                    'uid': status.uid,
                                    'index': i,
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 3)
                                    .add(const EdgeInsets.all(15)),
                                child: ListTile(
                                  title: Text(
                                    status.username,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      status.profilePic,
                                    ),
                                    radius: 30,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(color: dividerColor, indent: 85),
                          ],
                        );
                      }),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            onPressed: () => navTo(context, ConfirmTextScreen()),
            elevation: 0,
            backgroundColor: Colors.grey,
            child: const Icon(
              Icons.text_fields_sharp,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          FloatingActionButton(
            heroTag: 'btn2',
            onPressed: () async {
              File? pickedVideo = await pickVideoFromGallery(context);
              if (pickedVideo != null && context.mounted) {
                navTo(
                    context,
                    ConfirmFileStatus(
                        file: pickedVideo, type: MessageEnum.video));
              }
            },
            elevation: 0,
            backgroundColor: Colors.teal,
            child: const Icon(
              Icons.video_camera_back_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: 'btn3',
            onPressed: () async {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null && context.mounted) {
                navTo(
                    context,
                    ConfirmFileStatus(
                        file: pickedImage, type: MessageEnum.image));
              }
            },
            // elevation: 0,
            // backgroundColor: Colors.teal,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /* List<List<StatusModel>> _setMyStatusFirst(
      AsyncSnapshot<List<List<StatusModel>>> snaphot, WidgetRef ref) {
    List<StatusModel> myStatus = [];
    List<List<StatusModel>> remainingStatuses = [];
    for (var innerList in snaphot.data!) {
      if (innerList.any((status) =>
          status.uid ==
          ref.read(authRepositoryProvider).auth.currentUser!.uid)) {
        myStatus = innerList;
      } else {
        remainingStatuses.add(innerList);
      }
    }
    List<List<StatusModel>> orderedLists = [myStatus, ...remainingStatuses];
    return orderedLists;
  } */

  void _removeRedundantName(List<List<StatusModel>> statuses) {
    for (var innerList in statuses) {
      for (var object in innerList) {
        var key = object.uid;
        if (!orderedList.any((element) => element.uid == key)) {
          orderedList.add(object);
          //debugPrint(orderedList);
          break;
        }
      }
    }
  }
}

final statusProvider = StreamProvider((ref) {
  return ref.read(statusControllerProvider).status;
});
