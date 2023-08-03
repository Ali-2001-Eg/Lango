class UserModel {
  final String name;
  final String description;
  final String uid;
  final String profilePic;
  final String phoneNumber;
  final bool isOnline;
  final List<String> groupId;

  UserModel({
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.description,
    required this.phoneNumber,
    required this.isOnline,
    required this.groupId,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "uid": uid,
      "description": description,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "isOnline": isOnline,
      "groupId": groupId,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"],
      description: json['description'],
      uid: json["uid"],
      profilePic: json["profilePic"],
      phoneNumber: json["phoneNumber"],
      isOnline: json["isOnline"],
      groupId: List<String>.from(json["groupId"]),
    );
  }
//
}
