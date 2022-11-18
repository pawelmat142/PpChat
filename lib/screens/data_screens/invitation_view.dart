import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationView extends NotificationView {
  InvitationView(super.notification, {super.key});

  @override
  get title => 'INVITATION';

  @override
  get content => 'Invites you to contacts!';

  @override
  get buttons {
    return [

      PpButton(
        text: 'ACCEPT',
        onPressed: (){
        //  TODO: accept invitation, add to contacts, delete notification
        }
      ),

      PpButton(
        text: 'REJECT',
        color: PRIMARY_COLOR_DARKER,
        onPressed: (){
        //    TODO: reject invitation, delete notification
        }
      ),

    ];
  }

}