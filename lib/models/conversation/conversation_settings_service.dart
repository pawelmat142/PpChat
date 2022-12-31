import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:hive/hive.dart';

class ConversationSettingsService {

  saveSettings(ConversationSettings settings) async {
    final box = await Hive.openBox<ConversationSettings>(settings.hiveKey);
    await box.put(settings.hiveKey, settings);
  }

  Future<ConversationSettings> getSettings({required String contactUid}) async {
    final boxKey = ConversationSettings.createKey(contactUid: contactUid);
    final boxOpen = Hive.isBoxOpen(boxKey);

    final box = boxOpen
      ? Hive.box<ConversationSettings>(boxKey)
      : await Hive.openBox<ConversationSettings>(boxKey);

    ConversationSettings? settings = box.get(boxKey, defaultValue: ConversationSettings.createDefault(contactUid: contactUid));
    final result = settings ?? ConversationSettings.createDefault(contactUid: contactUid);

    return result;
  }

  deleteIfExists({required String contactUid}) async {
    print('delete if exists: $contactUid}');
    final key = ConversationSettings.createKey(contactUid: contactUid);
    if (await Hive.boxExists(key)) {
      print('exists');
      await Hive.box(key).deleteFromDisk();
    }
  }

}