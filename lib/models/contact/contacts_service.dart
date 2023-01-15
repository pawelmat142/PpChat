import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/models/conversation/conversations.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/uid.dart';

class ContactsService {

  final _firestore = FirebaseFirestore.instance;
  final _popup = getIt.get<Popup>();
  final _conversationSettingsService = getIt.get<ConversationSettingsService>();
  final logService = getIt.get<LogService>();

  Me get me => Me.reference;
  Contacts get contacts => Contacts.reference;
  ContactUids get contactUids => ContactUids.reference;
  Conversations get conversations => Conversations.reference;


  onDeleteContact(String uid) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _popup.show('Are you sure?', error: true,
        text: 'All data will be lost also on the other side!',
        buttons: [PopupButton('Delete', error: true, onPressed: () async {
          NavigationService.homeAndContacts();
          Future.delayed(Duration.zero, () async {
            await _deleteContact(uid);
            PpSnackBar.deleted(delay: 200);
          });
        })]);
  }

  _deleteContact(String uid) async {
    try {
      await AvatarService.deleteIfExistsInDevice(uid: uid);
      final contactUser = contacts.getByUid(uid)!;
      await _conversationSettingsService.fullDeleteConversation(contactUid: contactUser.uid);
      await _sendContactDeletedNotification(contactUser);
      contactUids.deleteOne(contactUser.uid);
    } catch (error) {
      logService.error(error.toString());
    }
  }

  _sendContactDeletedNotification(PpUser contactUser) async {
    final notification = PpNotification.createContactDeleted(
        sender: me.nickname,
        receiver: contactUser.nickname,
        avatar: Me.reference.get.avatar
    );

    await contactNotificationDocRef(contactUid: contactUser.uid).set(notification.asMap);
  }

  DocumentReference contactNotificationDocRef({required String contactUid}) => _firestore
      .collection(Collections.PpUser).doc(contactUid)
      .collection(Collections.NOTIFICATIONS).doc(Uid.get);

  PpUser? getByNickname({required String nickname}) => contacts.getByNickname(nickname);
  PpUser? getByUid({required String uid}) => contacts.getByUid(uid);

  contactExists(String contactUid) => contactUids.contains(contactUid);

}