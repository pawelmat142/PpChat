import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:hive/hive.dart';

class Conversation {
  Conversation({required this.contactNickname, required this.box});

  final String contactNickname;
  final Box<PpMessage> box;

  bool get isOpen => box.isOpen;

  closeBox() => box.close();

  clearBox() => box.clear();

  Future<void> killBox() async {
    if (box.isOpen) await box.deleteFromDisk();
  }


  //TODO: use compact more often


  open() async {
    await Hive.openBox(hiveKey(contactNickname: contactNickname));
  }

  addMessage(PpMessage message) async {
    await box.add(message);
  }


  static hiveKey({required contactNickname}) {
    return 'conversation_${AuthenticationService.nickname}_$contactNickname';
  }

  static create({required String contactNickname}) async {
    final box = await Hive.openBox<PpMessage>(hiveKey(contactNickname: contactNickname));
    return Conversation(contactNickname: contactNickname, box: box);
  }


}

