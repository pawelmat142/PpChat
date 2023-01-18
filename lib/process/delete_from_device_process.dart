import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/process/logout_process.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/uid.dart';

class DeleteFromDeviceProcess extends LogProcess {

  final conversationService = getIt.get<ConversationService>();
  final conversationSettingsService = getIt.get<ConversationSettingsService>();

  late String myUid;
  late List<PpUser> contacts;

  process() async {
    setProcess('DeleteFromDeviceProcess');
    setContext(Me.reference.nickname);
    log('[DeleteFromDeviceProcess] START');

    myUid = Uid.get!;
    contacts = Contacts.reference.get;

    for (PpUser contact in contacts) {
      await conversationSettingsService.fullDeleteConversation(contactUid: contact.uid, skipDeleteUnreadMessages: true);
      log('[${contact.nickname}] conversation and settings deleted!');
    }

    await HiveRsaPair.clearMyPair();
    log('My RSA pair cleared');

    final logoutProcess = LogoutProcess();
    await logoutProcess.process();
    log('logged out!');

    log('[DeleteFromDeviceProcess] STOP');
  }


}