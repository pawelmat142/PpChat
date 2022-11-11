import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';

class FindContact {

  final _userService = getIt.get<PpUserService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String nickname = '';

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
    //TODO: add checking if not already in contacts
    else {
      _spinner.start();
      final result = await _userService.findByNickname(nickname);
      _spinner.stop();
      if (result == null) {
        _popup.show('Nothing found', error: true);
      } else {
        await _popup.show('Result:',
            text: result.nickname,
            enableNavigateBack: true,
            buttons: [PopupButton('Invite', onPressed: _onInvite)]
        );
      }
    }
  }

  _onInvite() async {
    try {
      _spinner.start();
      await _sendInvitationNotification();
      _spinner.stop();
      _popup.closeOne();
      _popup.show('Invitation sent!');
    //  TODO: add to contacts with status like not accepted
    } catch (error) {
      _spinner.stop();
      _popup.show('Something went wrong', error: true);
    }
    _popup.closeOne();
  }

  _sendInvitationNotification() async {
    final ref = _firestore
        .collection(Collections.User)
        .doc(nickname)
        .collection(Collections.NOTIFICATIONS)
        .doc(_userService.nickname);
    final invitationDoc = PpNotification.createInvitation(
        text: 'invitation',
        fromNickname: _userService.nickname).asMap;

    await ref.set(invitationDoc);
  }

}