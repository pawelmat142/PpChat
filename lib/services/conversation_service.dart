import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class ConversationService {

  final _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();



  CollectionReference get messagesCollectionRef => _firestore
      .collection(Collections.User).doc(_userService.nickname)
      .collection(Collections.Messages);

  CollectionReference getReceiverCollectionRef(String receiver) {
    return _firestore.collection(Collections.User).doc(receiver)
        .collection(Collections.Messages);
  }

  onSendMessage(PpMessage message) async {
    await getReceiverCollectionRef(message.receiver).add(message.asMap);
  }

}