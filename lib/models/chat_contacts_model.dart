class ChatContactModel {
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  final bool isOnlyText;
  final String type;
  ChatContactModel(
      {required this.name,
      required this.profilePic,
      required this.contactId,
      required this.timeSent,
      required this.lastMessage,
      required this.type,
      required this.isOnlyText});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'isOnlyText': isOnlyText,
      'type': type,
    };
  }

  factory ChatContactModel.fromJson(Map<String, dynamic> json) {
    return ChatContactModel(
        name: json['name'],
        profilePic: json['profilePic'],
        contactId: json['contactId'],
        timeSent: DateTime.fromMillisecondsSinceEpoch(json['timeSent']),
        lastMessage: json['lastMessage'],
        type: json['type'],
        isOnlyText: json['isOnlyText']);
  }
}
