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
  final int timeToLive;

  @HiveField(5)
  bool isRead;

  PpMessage({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
    required this.timeToLive,
    required this.isRead,
  });


  Map<String, dynamic> get asMap => {
    PpMessageFields.sender: sender,
    PpMessageFields.receiver: receiver,
    PpMessageFields.message: message,
    PpMessageFields.timestamp: timestamp,
    PpMessageFields.timeToLive: timeToLive,
    PpMessageFields.isRead: isRead,
  };


  static PpMessage fromMap(Map<String, dynamic> messageMap) {
    PpMessageFields.validate(messageMap);
    return PpMessage(
      sender: messageMap[PpMessageFields.sender],
      receiver: messageMap[PpMessageFields.receiver],
      message: messageMap[PpMessageFields.message],
      timestamp: messageMap[PpMessageFields.timestamp].toDate(),
      timeToLive: messageMap[PpMessageFields.timeToLive],
      isRead: messageMap[PpMessageFields.isRead],
    );
  }

  static PpMessage fromDB(DocumentSnapshot<Object?> doc) {
    try {
      return PpMessage.fromMap(doc.data() as Map<String, dynamic>);
    } catch (error) {
      print(error);
      throw Exception(['FIREBASE OBJECT CAST FROM MAP ERROR - MESSAGE']);
    }
  }

  static PpMessage create({
    required String message,
    required String sender,
    required String receiver,
  }) {
    return PpMessage(
      receiver: receiver,
      sender: sender,
      message: message,
      timestamp: DateTime.now(),
      timeToLive: 0,
      isRead: false
    );
  }
}


abstract class PpMessageFields {
  static const sender = 'sender';
  static const receiver = 'receiver';
  static const message = 'message';
  static const timestamp = 'timestamp';
  static const timeToLive = 'timeToLive';
  static const isRead = 'isRead';

  static validate(Map<String, dynamic>? messageMap) {
    if (messageMap!.keys.contains(PpMessageFields.sender)
        && messageMap[PpMessageFields.sender] is String
        && messageMap.keys.contains(PpMessageFields.receiver)
        && messageMap[PpMessageFields.receiver] is String
        && messageMap.keys.contains(PpMessageFields.message)
        && messageMap[PpMessageFields.message] is String
        && messageMap.keys.contains(PpMessageFields.timestamp)
        && messageMap[PpMessageFields.timestamp] is Timestamp
        && messageMap.keys.contains(PpMessageFields.timeToLive)
        && messageMap[PpMessageFields.timeToLive] is int
        && messageMap.keys.contains(PpMessageFields.isRead)
        && messageMap[PpMessageFields.isRead] is bool
    ) {return;} else {
      throw Exception(["Message MAP ERROR - validate"]);
    }
  }
}