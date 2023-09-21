class CallModel {
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String callerPic;
  final String receiverPic;
  final String callId;
  final bool hasDialled;
  final String token;

  CallModel({
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.callerPic,
    required this.receiverPic,
    required this.callId,
    required this.hasDialled,
    required this.token,
  });

  Map<String, dynamic> tojson() {
    return <String, dynamic>{
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'callerPic': callerPic,
      'receiverPic': receiverPic,
      'callId': callId,
      'hasDialled': hasDialled,
      'token': token
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      callerPic: json['callerPic'] as String,
      receiverPic: json['receiverPic'] as String,
      callId: json['callId'] as String,
      hasDialled: json['hasDialled'] as bool,
      token: json['token'] as String,
    );
  }
}
