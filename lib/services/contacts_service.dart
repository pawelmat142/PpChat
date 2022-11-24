import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_fields.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_types.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class ContactsService {

  static const String contactsFieldName = 'contacts';

  final _firestore = FirebaseFirestore.instance;
  final _userService = getIt.get<PpUserService>();
  final _spinner = getIt.get<PpSpinner>();

  DocumentReference<Map<String, dynamic>> get _contactNicknamesDocRef {
    return _firestore.collection(Collections.User)
        .doc(_userService.nickname)
        .collection(Collections.CONTACTS)
        .doc(_userService.nickname);
  }

  //CURRENT VALUE
  List<String> _currentContactNicknames = [];
  List<PpUser> _currentContactUsers = [];
  List<PpUser> get currentContactUsers => _currentContactUsers;

  List<StreamSubscription> _userSubscriptions = [];

  Function? setStateToContactsScreen;



  login() async {
    _userSubscriptions = [];
    await _getCurrentContactNicknamesFromDB();
    for (var nickname in _currentContactNicknames) {
      _addContactUserSubscription(nickname);
    }
    print('_currentContactNicknames: ');
    print(_currentContactNicknames);
  }

  logout() {
    for (var subscription in _userSubscriptions) {
      subscription.cancel();
    }
    _currentContactNicknames = [];
    _currentContactUsers = [];
    _setStateToContactsScreen();
  }

  _setStateToContactsScreen() {
    if (setStateToContactsScreen != null) {
      setStateToContactsScreen!();
    }
  }

  _addContactUserSubscription(String nickname) {
    _userSubscriptions.add(_getContactUserDocRef(nickname).snapshots().listen((event) {
      if (event.exists) {
        final user = PpUser.fromDB(event);
        if (_currentContactUserExists(user.nickname)) {
          _updateSingleCurrentContactUser(user);
        } else {
          _currentContactUsers.add(user);
        }
        _setStateToContactsScreen();
      }
    }));
  }

  DocumentReference _getContactUserDocRef(String nickname) {
    return _firestore.collection(Collections.User).doc(nickname);
  }

  _getCurrentContactNicknamesFromDB() async {
    final response = await _contactNicknamesDocRef.get();
    _currentContactNicknames = [];
    if (response.exists) {
      final document = response.data();
      if (document != null && document.isNotEmpty) {
        final documentValue = document[contactsFieldName];
        documentValue.forEach((nickname) => _currentContactNicknames.add(nickname));
      }
    }
  }

  bool _currentContactUserExists(String nickname) {
    return _currentContactUsers.indexWhere((tile) => tile.nickname == nickname) != -1;
  }

  void _updateSingleCurrentContactUser(PpUser user) {
    final index = _currentContactUsers.indexWhere((tile) => tile.nickname == user.nickname);
    _currentContactUsers[index] = user;
  }

  acceptInvitationForReceiver(PpNotification notification, {bool pop = true}) async {
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
      final newList = _currentContactNicknames.map((contact) => contact).toList();
      newList.add(notification.sender);
      batch.set(_contactNicknamesDocRef, {contactsFieldName: newList});

      await batch.commit();
      _spinner.stop();
      _currentContactNicknames = newList;
      _addContactUserSubscription(notification.sender);
    } catch (error) {
      _spinner.stop();
      print(error);
    }
  }

  resolveInvitationAcceptancesForSender(List<PpNotification> notifications) async {
    try {
      final invitationAcceptances = PpNotification.filterInvitationAcceptances(notifications);
      if (invitationAcceptances.isNotEmpty) {
        final newNicknames = invitationAcceptances.map((notification) => notification.receiver).toList();
        await _addContacts(newNicknames);
        PpFlushbar.invitationAcceptanceForSender(notifications: invitationAcceptances, delay: 200);
      }
    } catch (error) {
      print(error);
    }
  }

  _addContacts(List<String> nicknames) async {
    var newList = _currentContactNicknames.map((n) => n).toList();
    for (var nickname in nicknames) {
      newList.add(nickname);
      _addContactUserSubscription(nickname);
    }
    await _contactNicknamesDocRef.set({contactsFieldName: newList});
    _currentContactNicknames = newList;
  }
}