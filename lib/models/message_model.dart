import 'package:whatsapp_clone/shared/enums/message_enum.dart';

class MessageModel {
  final String id;
  final String senderUid;
  final String receiverUid;
  final String messageText;
  final MessageEnum messageType;
  final DateTime timeSent;
  final bool isSeen;
  final String messageReply;
  final String repliedTo;
  final MessageEnum messageReplyType;
  final String? caption;
  MessageModel({
    required this.id,
    required this.senderUid,
    required this.receiverUid,
    required this.messageText,
    required this.messageType,
    required this.timeSent,
    required this.isSeen,
    required this.messageReply,
    required this.repliedTo,
    required this.messageReplyType,
    required this.caption,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      senderUid: json["senderUid"],
      receiverUid: json["receiverUid"],
      messageText: json["messageText"],
      messageType: (json["messageType"] as String).toEnum(),
      messageReplyType: (json["messageReplyType"] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(json['timeSent']),
      isSeen: json["isSeen"] ?? false,
      messageReply: json["messageReply"],
      repliedTo: json['repliedTo'],
      caption: json['caption']??'',
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
      "messageReply": messageReply,
      'repliedTo': repliedTo,
      'messageReplyType': messageReplyType.type,
      'caption':caption,
    };
  }
}
