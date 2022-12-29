import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive/hive.dart';

part 'conversation_settings.g.dart';

@HiveType(typeId: 1)
class ConversationSettings extends HiveObject {

  static const int timeToLiveInMinutesDefault = 10080;
  /// 1 week = 7 x 24 h = 168 h = 10080 min
  static const int timeToLiveAfterReadInMinutesDefault = 1440;
  /// 1 day = 24 h = 1440 min

  static const int timeToLiveMin = 10;
  static const int timeToLiveMax = 302400;
  /// 1 month = 30 x 10080 min = 302400

  static const int timeToLiveAfterReadMin = 10;
  static const int timeToLiveAfterReadMax = 10080;


  static ConversationSettings createDefault({required String contactUid}) {
    return ConversationSettings(contactUid: contactUid);
  }



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

  String get hiveKey => 'config_${Uid.get!}_$contactUid';

  static String createKey({required String contactUid}) {
    return 'config_${Uid.get!}_$contactUid';
  }

}

abstract class ConversationSettingsFields {
  static const String contactUid = 'contactUid';
  static const String timeToLiveInMinutes = 'timeToLiveInMinutes';
  static const String timeToLiveAfterReadInMinutes = 'timeToLiveAfterReadInMinutes';

  // static validate(Map<String, dynamic>? dataAsMap) {
  //   if (
  //     dataAsMap!.keys.contains(ConversationSettingsFields.contactUid)
  //     && dataAsMap[ConversationSettingsFields.contactUid] is String
  //     && dataAsMap.keys.contains(ConversationSettingsFields.timeToLiveInMinutes)
  //     && dataAsMap[ConversationSettingsFields.timeToLiveInMinutes] is int
  //     && dataAsMap.keys.contains(ConversationSettingsFields.timeToLiveAfterReadInMinutes)
  //     && dataAsMap[ConversationSettingsFields.timeToLiveAfterReadInMinutes] is int
  //   ) {
  //     return;
  //   } else {
  //     throw Exception(["ConversationSettingsFields MAP ERROR - validate"]);
  //   }
  // }
}