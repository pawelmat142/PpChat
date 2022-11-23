import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_fields.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class ContactsService {

  static const String contactsFieldName = 'contacts';

  final _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();
  final _spinner = getIt.get<PpSpinner>();

  DocumentReference<Map<String, dynamic>> get _contactsListRef {
    return _firestore.collection(Collections.User)
        .doc(_userService.nickname)
        .collection(Collections.CONTACTS)
        .doc(_userService.nickname);
  }

  //CURRENT VALUE
  List<String> _current = [];
  List<String> get currentContacts => _current;


  login() async {
    final response = await _contactsListRef.get();
    if (response.exists) {
      final result = response.get(contactsFieldName);
      if (result is List<String>) {
        _current = result;
      }
    }
  }

  logout() {
    _current = [];
  }

  acceptInvitation(PpNotification notification, {bool pop = true}) async {
    try {
      _spinner.start();
      final batch = _firestore.batch();

      //delete invitation
      final myReceiverInvitationRef = _firestore.collection(Collections.User).doc(_userService.nickname)
          .collection(Collections.NOTIFICATIONS).doc(notification.sender);
      batch.delete(myReceiverInvitationRef);

    // update sender invitationSelfNotification to invitation acceptance
      final senderInvitationRef = _firestore.collection(Collections.User).doc(notification.sender)
          .collection(Collections.NOTIFICATIONS).doc(notification.receiver);
      batch.update(senderInvitationRef, {
        PpNotificationFields.type: PpNotificationTypes.invitationAcceptance,
        PpNotificationFields.isRead: false
      });

     // add to contacts
      final newList = _current.map((contact) => contact).toList();
      newList.add(notification.sender);
      batch.set(_contactsListRef, {contactsFieldName: newList});

      //TODO: security rules
      await batch.commit();
      _spinner.stop();
      // _current = newList;
      if (pop) {
        Navigator.pop(NavigationService.context);
      }
    //  TODO: add flushbar
    } catch (error) {
      _spinner.stop();
      print(error);
    }
  }

}