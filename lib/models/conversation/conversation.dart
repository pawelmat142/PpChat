import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/conversation_mock.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/message_cleaner.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:hive/hive.dart';

class Conversation {
  Conversation({required this.contactUid});

  final String contactUid;
  Box<PpMessage>? box;

  bool get isOpen => box != null && box!.isOpen;

  Iterable<PpMessage> get values => box == null ? [] : box!.values;

  List<PpMessage> get messages => values.toList();
  List<String> get messagesTxt => values.map((m) => m.message).toList();

  final  messageCleaner = MessageCleaner();

  open() async {
    box = await Hive.openBox(hiveKey(contactUid: contactUid));
    messageCleaner.init(contactUid: contactUid);
  }

  bool _isMocked = false;
  bool get isLocked => values.length == 1 && values.first.message == MessageMock.TYPE_LOCK;


  addMessage(PpMessage message) async {
    if (message.isMock) {
      _isMocked = true;
      await box!.clear();
    } else if (_isMocked) {
      if (isLocked) return;
      _isMocked = false;
      await box!.clear();
    }
    await box!.add(message);
  }


  static hiveKey({required contactUid}) {
    return 'conversation_${Uid.get}_$contactUid';
  }

  static create({required String contactUid}) {
    final conversation = Conversation(contactUid: contactUid);
    log('created for uid: $contactUid');
    return conversation;
  }

  static log(String txt) {
    Future.delayed(Duration.zero, () {
      final logService = getIt.get<LogService>();
      logService.log('[Conversation] $txt');
    });
  }

}

