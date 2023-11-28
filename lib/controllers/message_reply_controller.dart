import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Lango/shared/enums/message_enum.dart';

class MessageReply {
  final String message;
  final bool isMe;
  final MessageEnum messageType;
  MessageReply(
      {required this.message, required this.messageType, required this.isMe});
}

final messageReplyProvider = StateProvider<MessageReply?>((ref) => null);
