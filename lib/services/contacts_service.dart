import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/models/provider/contact_uids.dart';
import 'package:flutter_chat_app/models/provider/contacts.dart';
import 'package:flutter_chat_app/models/provider/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/screens/contacts_screen.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/state/states.dart';

class ContactsService {

  final _firestore = FirebaseFirestore.instance;
  final _popup = getIt.get<Popup>();
  final _state = getIt.get<States>();
  final logService = getIt.get<LogService>();


  Me get me => Me.reference;
  Contacts get contacts => Contacts.reference;
  ContactUids get contactUids => ContactUids.reference;


  // StreamSubscription? _contactUidsListener;
  //
  // bool initialized = false;

  login() async {
    // initialized = false;
    //
    // get initial contactUids
    // await contactUids.startFirestoreObserver();
    // contacts.setContactUids(contactUids.get);
    //
    // get initial contact PpUser objects
    // await contacts.startFirestoreObserver();
    //
    // _startContactUidsListener();
    //
    // initialized = true;
  }

  logout() async {
    // if (initialized) {
    //   await _stopContactUidsListener();
    //   await contacts.clear();
    //   await contactUids.clear();
    //   initialized = false;
    // }
  }

  // _startContactUidsListener() {
  //   final completer = Completer();
  //   _contactUidsListener ??= _state.contactUids.stream.listen((contactUidsEvent) async {
  //       logService.log('[ContactUids] state listener, length: ${contactUidsEvent.length}');
  //       if (contactUidsEvent.isNotEmpty) {
  //         contacts.setContactUids(contactUidsEvent);
  //         await contacts.resetFirestoreObserver();
  //       } else {
  //         contacts.setContactUids([]);
  //         await contacts.stopFirestoreObserver();
  //         contacts.setEvent([]);
  //       }
  //       if (!completer.isCompleted) completer.complete();
  //     });
  //   return completer.future;
  // }

  // _stopContactUidsListener() async {
  //   if (_contactUidsListener != null) {
  //     await _contactUidsListener!.cancel();
  //     _contactUidsListener = null;
  //   }
  // }


  onDeleteContact(String uid) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _popup.show('Are you sure?', error: true,
        text: 'All data will be lost also on the other side!',
        buttons: [PopupButton('Delete', error: true, onPressed: () async {
          NavigationService.popToHome();
          Navigator.pushNamed(NavigationService.context, ContactsScreen.id);
          await _deleteContact(uid);
          PpFlushbar.contactDeletedNotificationForSender(nickname: contacts.getByUid(uid)!.nickname, delay: 200);
        })]);
  }

  _deleteContact(String uid) async {
    try {
      final conversation = _state.conversations.getByUid(uid);
      final contactUser = contacts.getByUid(uid)!;
      if (conversation != null) await _state.conversations.killBoxAndDelete(conversation);
      await _sendContactDeletedNotification(contactUser);
      contactUids.deleteOne(contactUser.uid);
    } catch (error) {
      logService.error(error.toString());
    }
  }

  _sendContactDeletedNotification(PpUser contactUser) async {
    final notification = PpNotification.createContactDeleted(
        sender: me.nickname,
        receiver: contactUser.nickname);

    await contactNotificationDocRef(contactUid: contactUser.uid).set(notification.asMap);
  }

  DocumentReference contactNotificationDocRef({required String contactUid}) => _firestore
      .collection(Collections.PpUser).doc(contactUid)
      .collection(Collections.NOTIFICATIONS).doc(States.getUid);

  PpUser? getByNickname({required String nickname}) => contacts.getByNickname(nickname);
  PpUser? getByUid({required String uid}) => contacts.getByUid(uid);

  contactExists(String contactUid) => contactUids.contains(contactUid);

}