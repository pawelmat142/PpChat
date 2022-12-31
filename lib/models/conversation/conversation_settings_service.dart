import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:hive/hive.dart';

class ConversationSettingsService {

  final logService = getIt.get<LogService>();

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
    final key = ConversationSettings.createKey(contactUid: contactUid);
    if (await Hive.boxExists(key)) {
      if (!Hive.isBoxOpen(key)) {
        await Hive.openBox<ConversationSettings>(key);
      }
      final box = Hive.box<ConversationSettings>(key);
      await box.clear();
      await box.deleteFromDisk();
      logService.log('[ConversationSettings] deleted for $contactUid');
    }
  }

}