class ChatDetailFromMap {
  String senderName;
  String senderID;
  String senderAvatar;
  String message;
  String time;

  ChatDetailFromMap({
    required this.senderName,
    required this.senderID,
    required this.senderAvatar,
    required this.message,
    required this.time,
  });

  factory ChatDetailFromMap.fromMap(Map<String, dynamic> map) {
    return ChatDetailFromMap(
      senderName: map['senderName'] ?? '',
      senderID: map['senderID'] ?? '',
      senderAvatar: map['senderAvatar'] ?? '',
      message: map['message'] ?? '',
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderName': senderName,
      'senderID': senderID,
      'senderAvatar': senderAvatar,
      'message': message,
      'time': time,
    };
  }
}