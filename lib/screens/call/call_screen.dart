// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:Lango/shared/utils/functions.dart';
import 'package:Lango/shared/widgets/custom_button.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/controllers/call_controller.dart';

import 'package:Lango/models/call_model.dart';
import 'package:Lango/shared/utils/base/agora_config.dart';
import 'package:Lango/shared/widgets/custom_indicator.dart';

class CallScreen extends ConsumerStatefulWidget {
  static const String routeName = '/call-screen';
  final String channelId;
  final CallModel callData;
  final bool isGroupChat;
  const CallScreen({
    super.key,
    required this.channelId,
    required this.callData,
    required this.isGroupChat,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
//agora setup
  AgoraClient? client;

  @override
  void initState() {
    super.initState();
    // client.engine.startScreenCapture(ScreenCaptureParameters2 );
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appId,
        channelName: widget.channelId,
        tokenUrl: AgoraConfig.baseUrl,
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return client == null
        ? const Scaffold(
            body: CustomIndicator(),
          )
        : PopScope(
            onPopInvoked: (confirm) => _onpopInvoked(context),
            child: Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    Stack(
                      children: [
                        Positioned(
                          top: 10,
                          left: isArabic ? null : 10,
                          right: isArabic ? 10 : null,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_outlined,
                              color: getTheme(context).hoverColor,
                            ),
                            onPressed: () => _onpopInvoked(context),
                          ),
                        ),
                        AgoraVideoViewer(client: client!),
                      ],
                    ),
                    AgoraVideoButtons(
                      client: client!,
                      addScreenSharing: false,
                      disconnectButtonChild: InkWell(
                          highlightColor: Colors.grey,
                          splashColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            client!.engine.leaveChannel();
                            ref.read(callControllerProvider).endCall(
                                callerId: widget.callData.callerId,
                                receiverId: widget.callData.receiverId,
                                call: widget.callData,
                                context: context,
                                isGroupChat: widget.isGroupChat);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(
                              Icons.call_end,
                              size: 23,
                              color: Colors.red,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ));
  }

  Future<dynamic> _onpopInvoked(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Confirm Exit'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                      text: 'confirm',
                      onPress: () {
                        client!.engine.leaveChannel();

                        ref.read(callControllerProvider).endCall(
                            callerId: widget.callData.callerId,
                            receiverId: widget.callData.receiverId,
                            context: context,
                            isGroupChat: widget.isGroupChat,
                            call: widget.callData);
                        Navigator.of(context).pop(true);
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                      text: 'continue',
                      onPress: () {
                        Navigator.of(context).pop(false);
                      }),
                )
              ],
            ));
  }
}
