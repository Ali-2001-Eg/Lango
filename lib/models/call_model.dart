class CallModel {
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String callerPic;
  final String receiverPic;
  final String callId;
  final bool hasDialled;

  CallModel({
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.callerPic,
    required this.receiverPic,
    required this.callId,
    required this.hasDialled,
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
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> map) {
    return CallModel(
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      callerPic: map['callerPic'] as String,
      receiverPic: map['receiverPic'] as String,
      callId: map['callId'] as String,
      hasDialled: map['hasDialled'] as bool,
    );
  }
}
