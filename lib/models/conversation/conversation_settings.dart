import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive/hive.dart';

part 'conversation_settings.g.dart';

@HiveType(typeId: 1)
class ConversationSettings extends HiveObject {

  @HiveField(0)
  final String contactUid;

  @HiveField(1)
  int timeToLiveInMinutes;

  @HiveField(2)
  int timeToLiveAfterReadInMinutes;

  ConversationSettings({
    required this.contactUid,
    this.timeToLiveInMinutes = timeToLiveInMinutesDefault,
    this.timeToLiveAfterReadInMinutes = timeToLiveAfterReadInMinutesDefault,
  });

  Map<String, dynamic> get asMap => {
    ConversationSettingsFields.contactUid: contactUid,
    ConversationSettingsFields.timeToLiveInMinutes: timeToLiveInMinutes,
    ConversationSettingsFields.timeToLiveAfterReadInMinutes: timeToLiveAfterReadInMinutes,
  };

  static ConversationSettings fromMap(Map<String, dynamic> map) {
    return ConversationSettings(
      contactUid: map[ConversationSettingsFields.contactUid],
      timeToLiveInMinutes: map[ConversationSettingsFields.timeToLiveInMinutes],
      timeToLiveAfterReadInMinutes: map[ConversationSettingsFields.timeToLiveAfterReadInMinutes],
    );
  }


  // static const int timeToLiveInMinutesDefault = 2;
  static const int timeToLiveInMinutesDefault = 10080;
  /// 1 week = 7 x 24 h = 168 h = 10 080 min
  // static const int timeToLiveAfterReadInMinutesDefault = 1;
  static const int timeToLiveAfterReadInMinutesDefault = 15;
  /// 1 day = 24 h = 1440 min

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
    return settings;
  }

  String get hiveKey => 'config_${Uid.get!}_$contactUid';

}

abstract class ConversationSettingsFields {
  static const String contactUid = 'contactUid';
  static const String timeToLiveInMinutes = 'timeToLiveInMinutes';
  static const String timeToLiveAfterReadInMinutes = 'timeToLiveAfterReadInMinutes';
}