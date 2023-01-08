import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';

class FindContact {

  final _userService = getIt.get<PpUserService>();
  final _contactsService = getIt.get<ContactsService>();
  final _invitationService = getIt.get<InvitationService>();
  final _popup = getIt.get<Popup>();
  final _spinner = getIt.get<PpSpinner>();

  final Me me = Me.reference;

  String nickname = '';
  String message = '';

  late PpNotification selfNotification;

  late PpUser foundUser;

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
    else if (nickname == me.nickname) {
      await _popup.show('You have found yourself.', error: true);
    }
    else if (_contactsService.contacts.getByNickname(nickname) != null) {
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
        _popup.closeAll();
        foundUser = result;
        UserView.navigate(user: foundUser);
      }
    }
  }

}