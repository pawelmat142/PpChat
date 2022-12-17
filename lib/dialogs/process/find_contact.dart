import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';

class FindContact {

  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _invitationService = getIt.get<InvitationService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String nickname = '';
  String message = '';
  PpNotification? selfNotification;

  FindContact() {
    _searchPopup();
  }

  _searchPopup() {
    _popup.show('Find new contact',
        content: TextField(
          onChanged: (val) => nickname = val,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nickname'),
        ),
        buttons: [PopupButton('Find', onPressed: _onFind, preventPop: true)]
    );
  }

  _onFind() async {
    if (nickname.length < 6) {
      await _popup.show('Nickname must have at least 6 characters.', error: true);
    }
    else if (nickname == _userService.nickname) {
      await _popup.show('You have found yourself.', error: true);
    }
    else if (_contactsService.contacts.nicknames.contains(nickname)) {
      await _popup.show('Already in contacts!', text: nickname, error: true);
    }
    else if (_invitationService.isInvitationSent(nickname)) {
      await _popup.show('Invitation already sent to:', text: nickname, error: true);
    }
    else if (_invitationService.isInvitationReceived(nickname)) {
      await _popup.show('Invitation already received from:', text: nickname, error: true);
    }
    else {
      _spinner.start();
      final result = await _userService.findByNickname(nickname);
      _spinner.stop();
      if (result == null) {
        _popup.show('Nothing found', error: true);
      } else {
        await _popup.show('Result!',
            enableNavigateBack: true,
            content: Column(children: [

              RichText(textAlign: TextAlign.left, text: TextSpan(children: [
                const TextSpan(text: 'You have found user:  ', style: TextStyle(fontSize: 16, color: Colors.black87)),
                TextSpan(text: result.nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PRIMARY_COLOR_DARKER)),
              ], )),

              const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text('You can add invitation message sending invitation!'),
              ),

              TextField(
                onChanged: (val) => message = val,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'invitation message'),
              ),

            ]),

            buttons: [PopupButton('Invite', onPressed: () {
              if (message == '') {
                _popup.show('Are you sure you want to send invitation without message?',
                  error: true,
                  enableDefaultButton: false,
                  buttons: [
                    PopupButton('No', error: true, onPressed: _onFind),
                    PopupButton('Yes', onPressed: _onInvite),
                  ]);
              } else {
                _onInvite();
              }
            })]
        );
      }
    }
  }

  _onInvite() async {
    try {
      _spinner.start();
      await _sendInvitationNotifications();
      PpFlushbar.invitationSent(delay: 100, notification: selfNotification);
    } catch (error) {
      _spinner.stop();
      _popup.show('Something went wrong', error: true, delay: 200);
    }
    _spinner.stop();
    _popup.closeOne();
  }

  _sendInvitationNotifications() async {
    final batch = _firestore.batch();

    final receiverRef = _firestore
        .collection(Collections.PpUser)
        .doc(nickname)
        .collection(Collections.NOTIFICATIONS)
        .doc(_userService.nickname);

    batch.set(receiverRef, PpNotification.createInvitation(
        sender: _userService.nickname,
        receiver: nickname,
        text: message).asMap);

    final selfRef = _firestore
        .collection(Collections.PpUser)
        .doc(_userService.nickname)
        .collection(Collections.NOTIFICATIONS)
        .doc(nickname);

    selfNotification = PpNotification.createInvitationSelfNotification(
        sender: _userService.nickname,
        receiver: nickname,
        text: message,
    );
    batch.set(selfRef, selfNotification!.asMap);

    await batch.commit();
  }
}