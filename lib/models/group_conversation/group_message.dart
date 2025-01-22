class GroupMessage {

  final String message;
  final String nickname;
  final DateTime timestamp;

  GroupMessage({
    required this.message,
    required this.nickname,
    required this.timestamp
  });

  static List<Map<String, dynamic>> toMapsList(List<GroupMessage> messages) {
    return messages.map((groupMessage) => groupMessage.asMap).toList();
  }

  Map<String, dynamic> get asMap => {
    GroupMessageFields.message: message,
    GroupMessageFields.nickname: nickname,
    GroupMessageFields.timestamp: timestamp,
  };

  static List<GroupMessage> listFromMaps(Iterable<Map<String, dynamic>> maps) {
    return maps.map((messageMap) => fromMap(messageMap)).toList();
  }

  static GroupMessage fromMap(Map<String, dynamic> msgMap) {
    return GroupMessage(
      message: msgMap[GroupMessageFields.message],
      nickname: msgMap[GroupMessageFields.nickname],
      timestamp: msgMap[GroupMessageFields.timestamp].toDate(),
    );
  }


}

abstract class GroupMessageFields {
  static const message = 'message';
  static const nickname = 'nickname';
  static const timestamp = 'timestamp';
}