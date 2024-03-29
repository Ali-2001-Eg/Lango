import 'package:Lango/shared/widgets/custom_stream_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:Lango/shared/utils/functions.dart';

import '../../controllers/call_controller.dart';
import '../../generated/l10n.dart';
import '../../shared/utils/colors.dart';
import '../../shared/widgets/time_text_formatter.dart';

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomStreamOrFutureWidget(
        stream: callHistoryProvider,
        builder: (data) {
          
          if ( data.isEmpty) {
            return Center(
              child: SizedBox(
                height: size(context).height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 300,
                        width: 300,
                        child:
                            Lottie.asset('assets/json/empty_call_history.json'),
                      ),
                      Text(
                        S.of(context).empty_call_history,
                        style: getTextTheme(context, ref),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (_, i) {
                var item = data[i];

                bool didICall = item['callerUid'] ==
                    ref.watch(callControllerProvider).auth.currentUser!.uid;
                return Padding(
                  padding: const EdgeInsets.all(8.0)
                      .add(const EdgeInsets.only(top: 25)),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          didICall
                              ? isArabic
                                  ? (' لقد قمت بعمل مكالمه مع ${item['receiverName']}')
                                  : ('You called  ${item['receiverName']}')
                              : isArabic
                                  ? 'You recieved a call from ${item['callerName']}'
                                  : 'تم استقبال مكالمه من ${item['callerName']}',
                        ),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: CachedNetworkImageProvider(didICall
                              ? item['recieverPic']
                              : item['callerPic']),
                        ),
                        subtitle: TimeTextFormatter(
                            time: DateTime.fromMicrosecondsSinceEpoch(
                                item['timeSent'])),
                        trailing: IconButton(
                          onPressed: () {
                            ref.read(callControllerProvider).call(
                                item['receiverName'],
                                item['recieverPic'],
                                false,
                                item['receiverUid'],
                                context,
                                didICall
                                    ? item['recieverToken']
                                    : item['callerToken']);
                          },
                          icon: Icon(
                            item['hasDialled']
                                ? Icons.call
                                : Icons.phone_missed_outlined,
                            color: item['hasDialled']
                                ? getTheme(context).cardColor
                                : Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                      const Divider(color: dividerColor, indent: 85),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
final callHistoryProvider = StreamProvider((ref) {
  return ref.read(callControllerProvider).callHistory;
});