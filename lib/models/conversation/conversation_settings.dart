import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive/hive.dart';

part 'conversation_settings.g.dart';

@HiveType(typeId: 1)
class ConversationSettings extends HiveObject {

  // static const int timeToLiveInMinutesDefault = 2;
  static const int timeToLiveInMinutesDefault = 10080;
  /// 1 week = 7 x 24 h = 168 h = 10 080 min
  // static const int timeToLiveAfterReadInMinutesDefault = 1;
  static const int timeToLiveAfterReadInMinutesDefault = 10;
  /// 1 day = 24 h = 1440 min

  ///USED TO NUMBER PICKER ONLY
  static const int timeToLiveMin = 10;
  static const int timeToLiveMax = 43200;
  /// 1 month = 30 x 24 x 60 min = 43 200

  static const int timeToLiveAfterReadMin = 10;
  static const int timeToLiveAfterReadMax = 10080;

  static String createKey({required String contactUid}) {
    return 'config_${Uid.get!}_$contactUid';
  }

  static ConversationSettings createDefault({required String contactUid}) {
    return ConversationSettings(contactUid: contactUid);
  }

  static ConversationSettings create({
    required String contactUid,
    required int timeToLive,
    required int timeToLiveAfterRead,
  }) {
    final settings = ConversationSettings(contactUid: contactUid);
    settings.timeToLiveInMinutes = timeToLive;
    settings.timeToLiveAfterReadInMinutes = timeToLiveAfterRead;
    settings.validate();
    return settings;
  }

  String get hiveKey => 'config_${Uid.get!}_$contactUid';


  ConversationSettings({
    required this.contactUid,
    this.timeToLiveInMinutes = timeToLiveInMinutesDefault,
    this.timeToLiveAfterReadInMinutes = timeToLiveAfterReadInMinutesDefault,
  });

  @HiveField(0)
  final String contactUid;

  @HiveField(1)
  int timeToLiveInMinutes;

  @HiveField(2)
  int timeToLiveAfterReadInMinutes;


  validate() {
    if (timeToLiveInMinutes < timeToLiveMin
        || timeToLiveInMinutes > timeToLiveMax
        || timeToLiveAfterReadInMinutes < timeToLiveAfterReadMin
        || timeToLiveAfterReadInMinutes > timeToLiveAfterReadMax
    ) throw Exception('LIMIT EXCEEDED!!');
  }


}

abstract class ConversationSettingsFields {
  static const String contactUid = 'contactUid';
  static const String timeToLiveInMinutes = 'timeToLiveInMinutes';
  static const String timeToLiveAfterReadInMinutes = 'timeToLiveAfterReadInMinutes';
}