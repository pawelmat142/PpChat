import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_hive_image.dart';
import 'package:hive_flutter/adapters.dart';

class HiveService {

  static init () async {
    await Hive.initFlutter();
    Hive.registerAdapter(PpMessageAdapter());
    Hive.registerAdapter(ConversationSettingsAdapter());
    Hive.registerAdapter(AvatarHiveImageAdapter());
    Hive.registerAdapter(HiveRsaPairAdapter());
  }

}