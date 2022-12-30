import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'pp_message.g.dart';

@HiveType(typeId: 0)
class PpMessage extends HiveObject {

  @HiveField(0)
  final String sender;

  @HiveField(1)
  final String receiver;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  DateTime readTimestamp;

  @HiveField(5)
  final int timeToLive;

  @HiveField(6)
  final int timeToLiveAfterRead;

  PpMessage({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
    required this.readTimestamp,
    required this.timeToLive,
    required this.timeToLiveAfterRead,
  });


  Map<String, dynamic> get asMap => {
    PpMessageFields.sender: sender,
    PpMessageFields.receiver: receiver,
    PpMessageFields.message: message,
    PpMessageFields.timestamp: timestamp,
    PpMessageFields.readTimestamp: readTimestamp,
    PpMessageFields.timeToLive: timeToLive,
    PpMessageFields.timeToLiveAfterRead: timeToLiveAfterRead,
  };

  static const int dateTimeMax = 2222;

  bool get isRead => DateTime.now().compareTo(readTimestamp) > 0;

  bool get isMock => timeToLive == -1;


  bool get isExpired => _timeToLiveExpired || _timeToLiveAfterReadExpired;

  bool get _timeToLiveExpired => timeToLive > 0
      && timestamp
          .add(Duration(minutes: timeToLive))
          .compareTo(DateTime.now()) >= 0;

  bool get _timeToLiveAfterReadExpired => isRead
      && timeToLiveAfterRead > 0
      && readTimestamp
          .add(Duration(minutes: timeToLiveAfterRead))
          .compareTo(DateTime.now()) >= 0;


  static PpMessage fromMap(Map<String, dynamic> messageMap) {
    PpMessageFields.validate(messageMap);
    return PpMessage(
      sender: messageMap[PpMessageFields.sender],
      receiver: messageMap[PpMessageFields.receiver],
      message: messageMap[PpMessageFields.message],
      timestamp: messageMap[PpMessageFields.timestamp].toDate(),
      readTimestamp: messageMap[PpMessageFields.readTimestamp].toDate(),
      timeToLive: messageMap[PpMessageFields.timeToLive],
      timeToLiveAfterRead: messageMap[PpMessageFields.timeToLiveAfterRead],
    );
  }

  static PpMessage fromDB(DocumentSnapshot<Object?> doc) {
    try {
      return PpMessage.fromMap(doc.data() as Map<String, dynamic>);
    } catch (error) {
      throw Exception(['FIREBASE OBJECT CAST FROM MAP ERROR - MESSAGE']);
    }
  }

  static PpMessage create({
    required String message,
    required String sender,
    required String receiver,
    required int timeToLive,
    required int timeToLiveAfterRead
  }) {
    return PpMessage(
      receiver: receiver,
      sender: sender,
      message: message,
      timestamp: DateTime.now(),
      readTimestamp: DateTime(dateTimeMax),
      timeToLive: timeToLive,
      timeToLiveAfterRead: timeToLiveAfterRead,
    );
  }
}


abstract class PpMessageFields {
  static const sender = 'sender';
  static const receiver = 'receiver';
  static const message = 'message';
  static const timestamp = 'timestamp';
  static const readTimestamp = 'readTimestamp';
  static const timeToLive = 'timeToLive';
  static const timeToLiveAfterRead = 'timeToLiveAfterRead';

  static validate(Map<String, dynamic>? messageMap) {
    if (messageMap!.keys.contains(PpMessageFields.sender)
        && messageMap[PpMessageFields.sender] is String
        && messageMap.keys.contains(PpMessageFields.receiver)
        && messageMap[PpMessageFields.receiver] is String
        && messageMap.keys.contains(PpMessageFields.message)
        && messageMap[PpMessageFields.message] is String
        && messageMap.keys.contains(PpMessageFields.timestamp)
        && messageMap[PpMessageFields.timestamp] is Timestamp
        && messageMap.keys.contains(PpMessageFields.readTimestamp)
        && messageMap[PpMessageFields.readTimestamp] is Timestamp
        && messageMap.keys.contains(PpMessageFields.timeToLive)
        && messageMap[PpMessageFields.timeToLive] is int
        && messageMap.keys.contains(PpMessageFields.timeToLiveAfterRead)
        && messageMap[PpMessageFields.timeToLiveAfterRead] is int
    ) {return;} else {
      throw Exception(["Message MAP ERROR - validate"]);
    }
  }
}