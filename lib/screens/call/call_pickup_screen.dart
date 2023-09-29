// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_clone/controllers/call_controller.dart';
import 'package:whatsapp_clone/generated/l10n.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';
import '../../models/call_model.dart';
import 'call_screen.dart';

class CallPickupScreen extends ConsumerWidget {
  final Widget scaffold;
  // final String receiverName;

  const CallPickupScreen({
    super.key,
    required this.scaffold,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
        stream: ref.read(callControllerProvider).chatStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorScreen(error: snapshot.error.toString());
          } else if (snapshot.hasData && snapshot.data!.data() != null) {
            CallModel callData = CallModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);

            // print('call token is ${callData.token}');
            if (!callData.hasDialled) {
              return Scaffold(
                body: Container(
                  //alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        S.of(context).incoming_call,
                        style: getTextTheme(context, ref).copyWith(
                            fontSize: 25, color: getTheme(context).hoverColor),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(callData.callerPic),
                        radius: 150,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        callData.callerName,
                        style: getTextTheme(context, ref).copyWith(
                            fontSize: 30, color: getTheme(context).hoverColor),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                                highlightColor: Colors.grey,
                                splashColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 179, 44, 44)),
                                  child: const Icon(
                                    Icons.call_end,
                                    size: 35,color: Colors.white,
                                  ),
                                )),
                            InkWell(
                                borderRadius: BorderRadius.circular(50),
                                highlightColor: Colors.grey,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CallScreen(
                                        channelId: callData.callId,
                                        callData: callData,
                                        isGroupChat: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 8, 133, 14)),
                                  child: const Icon(
                                    Icons.call,
                                    size: 35,color: Colors.white,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          return scaffold;
        });
  }
}
