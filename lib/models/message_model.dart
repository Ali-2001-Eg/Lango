import 'package:whatsapp_clone/shared/enums/message_enum.dart';

class MessageModel {
  final String id;
  final String senderUid;
  final String receiverUid;
  final String messageText;
  final MessageEnum messageType;
  final DateTime timeSent;
  final bool isSeen;

  MessageModel({
    required this.id,
    required this.senderUid,
    required this.receiverUid,
    required this.messageText,
    required this.messageType,
    required this.timeSent,
    required this.isSeen,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      senderUid: json["senderUid"],
      receiverUid: json["receiverUid"],
      messageText: json["messageText"],
      messageType: (json["messageType"] as String).toEnum(),
      timeSent: DateTime.fromMicrosecondsSinceEpoch(json['timeSent']),
      isSeen: json["isSeen"] ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "senderUid": senderUid,
      "receiverUid": receiverUid,
      "messageText": messageText,
      "messageType": messageType.type,
      "timeSent": timeSent.millisecondsSinceEpoch,
      "isSeen": isSeen,
    };
  }
}
