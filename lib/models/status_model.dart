import '../shared/enums/message_enum.dart';

class StatusModel {
  final String uid;
  final String username;
  final String phoneNumber;
  final String status;
  final DateTime createdAt;
  final String profilePic;
  final String statusId;
  final List<String> audience;
  final MessageEnum type;
  StatusModel(
      {required this.uid,
      required this.username,
      required this.phoneNumber,
      required this.status,
      required this.createdAt,
      required this.profilePic,
      required this.statusId,
      required this.audience,
      required this.type});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      uid: json["uid"],
      username: json["username"],
      phoneNumber: json["phoneNumber"],
      status: json["fileUrl"],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
      profilePic: json["profilePic"],
      statusId: json["statusId"],
      audience: List<String>.from(json["audience"]),
      type: (json["type"] as String).toEnum(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "username": username,
      "phoneNumber": phoneNumber,
      "fileUrl": status,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "profilePic": profilePic,
      "statusId": statusId,
      "audience": audience,
      "type": type.type,
    };
  }
}
