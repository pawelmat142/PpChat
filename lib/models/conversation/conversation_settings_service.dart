import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:hive/hive.dart';

class ConversationSettingsService {

  final logService = getIt.get<LogService>();

  Conversations get conversations => Conversations.reference;

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


  fullDeleteConversation({required String contactUid}) async {
    final conversation = conversations.getByUid(contactUid);
    if (conversation != null) conversation.messageCleaner.dispose();
    await _deleteConversationBoxIfExists(contactUid: contactUid);
    await _deleteSettingsBoxIfExists(contactUid: contactUid);
    await _deleteUnreadMessages(contactUid: contactUid);
    if (conversation != null) conversations.deleteByUid(contactUid);
  }

  _deleteUnreadMessages({required String contactUid}) async {
    final messages = await ConversationService.messagesCollectionRef
        .where(PpMessageFields.sender, isEqualTo: contactUid).get();

    if (messages.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var message in messages.docs) {
        batch.delete(message.reference);
      }
      await batch.commit();
      logService.log('${messages.docs.length} unread messages deleted fot $contactUid.');
    }
  }


  _deleteConversationBoxIfExists({required String contactUid}) async {
    final key = Conversation.hiveKey(contactUid: contactUid);
    if (await Hive.boxExists(key)) {
      if (!Hive.isBoxOpen(key)) {
        await Hive.openBox<PpMessage>(key);
      }
      final box = Hive.box<PpMessage>(key);
      await box.clear();
      await box.deleteFromDisk();
      logService.log('[PpMessage] box deleted for $contactUid');
    }
  }


  _deleteSettingsBoxIfExists({required String contactUid}) async {
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