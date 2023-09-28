// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/call_controller.dart';

import 'package:whatsapp_clone/models/call_model.dart';
import 'package:whatsapp_clone/shared/utils/base/agora_config.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';

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
    return Scaffold(
      body: client == null
          ? const CustomIndicator()
          : SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(client: client!),
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
    );
  }
}
