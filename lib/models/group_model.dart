import 'package:whatsapp_clone/shared/enums/message_enum.dart';

class GroupModel {
  final String name;
  final String groupId;
  final String lastMessage;
  final MessageEnum lastMessageType;
  final DateTime timeSent;
  final String groupPic;
  final String senderId;
  final List<String> membersUid;

  GroupModel(
      {required this.name,
      required this.groupId,
      required this.lastMessage,
      required this.groupPic,
      required this.senderId,
      required this.membersUid,
      required this.lastMessageType,
      required this.timeSent});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
        name: json["name"],
        groupId: json["groupId"],
        lastMessage: json["lastMessage"],
        groupPic: json["groupPic"],
        senderId: json["senderId"],
        membersUid: List<String>.from(json["membersUid"]),
        lastMessageType: (json['lastMessageType'] as String).toEnum(),
        timeSent: DateTime.fromMillisecondsSinceEpoch(json['timeSent']));
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "groupId": groupId,
      "lastMessage": lastMessage,
      "groupPic": groupPic,
      "senderId": senderId,
      "membersUid": membersUid,
      'lastMessageType': lastMessageType.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
    };
  }
}
