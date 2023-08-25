import '../shared/enums/message_enum.dart';

class StatusModel {
  final String uid;
  final String username;
  final String phoneNumber;
  final List<String> fileUrls;
  final DateTime createdAt;
  final String profilePic;
  final String statusId;
  final List<String> audience;
  final MessageEnum type;
  StatusModel(
      {required this.uid,
      required this.username,
      required this.phoneNumber,
      required this.fileUrls,
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
      fileUrls: List<String>.from(json["fileUrls"]),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
      profilePic: json["profilePic"],
      statusId: json["statusId"],
      audience: List<String>.from(json["audience"]),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "username": username,
      "phoneNumber": phoneNumber,
      "fileUrls": fileUrls,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "profilePic": profilePic,
      "statusId": statusId,
      "audience": audience,
      "type": type,
    };
  }
}
