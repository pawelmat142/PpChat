import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/process/delete_account_process.dart';
import 'package:flutter_chat_app/screens/data_views/edit_avatar_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';


class UserView extends StatelessWidget {
  const UserView({Key? key}) : super(key: key);

  static const String id = 'user_view';

  static popAndNavigate({required PpUser user, int? delay}) async {
    if (delay != null) {
      await Future.delayed(Duration(milliseconds: delay));
    }
    Navigator.popAndPushNamed(
        NavigationService.context,
        UserView.id,
        arguments: user
    );
  }

  static void navigate({required PpUser user}) {
    Navigator.pushNamed(
        NavigationService.context,
        UserView.id,
        arguments: user
    );
  }

  @override
  Widget build(BuildContext context) {

    final user = ModalRoute.of(context)!.settings.arguments as PpUser;
    final bool isMe = Uid.get == user.uid;

    final bool isContact = Contacts.reference.getByNickname(user.nickname) != null;

    return Scaffold(

        appBar: AppBar(title: Text(isMe ?  'My account' : isContact ? 'Contact view' : '??')),

        body: Padding(
          padding: BASIC_HORIZONTAL_PADDING,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// AVATAR
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: AvatarWidget(
                  uid: user.uid,
                  size: AVATAR_SIZE_BIG,
                  model: user.avatar
                ),
              ),

              /// Name
              Text(user.nickname,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  color: PRIMARY_COLOR_DARKER,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),


              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(user.logged ? 'Active' : 'Inactive',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              const SizedBox(height: 12),


              //  Padding(
              //   padding: const EdgeInsets.only(top: 30, bottom: 20),
              //   child: RichText(text: const TextSpan(children: [
              //     TextSpan(text: 'xd ',
              //         style: TextStyle(fontSize: 16, color: PRIMARY_COLOR_LIGHTER)),
              //     TextSpan(text: 'lol',
              //         style: TextStyle(fontSize: 16, color: Colors.black87)),
              //   ])),
              // ),

              ///BUTTONS
              ///
              /// contact
              isContact ?
                Column(children: [
                  PpButton(text: 'Conversation', onPressed: () {
                    final conversationService = getIt.get<ConversationService>();
                    if (conversationService.contactExists(user.uid)) {
                      conversationService.navigateToConversationView(user);
                    } else {
                      PpSnackBar.contactNotExists();
                    }
                  }),

                  PpButton(text: 'Delete contact',
                      color: Colors.red, onPressed: () async {
                        final contactsService = getIt.get<ContactsService>();
                        if (contactsService.contactExists(user.uid)) {
                          await contactsService.onDeleteContact(user.uid);
                        } else {
                          PpSnackBar.contactNotExists();
                        }
                      }),
                ])

              /// me
              : isMe ?
                Column(children: [
                  PpButton(text: 'Edit avatar',
                    color: PRIMARY_COLOR_LIGHTER,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return EditAvatarView(user: user);
                      }));
                  }),

                  PpButton(text: 'Notifications', onPressed: () {
                    Navigator.pushNamed(context, NotificationsScreen.id);
                  }),

                  PpButton(text: 'Logout', color: PRIMARY_COLOR_DARKER, onPressed: () {
                    final authService = getIt.get<AuthenticationService>();
                    authService.onLogout();
                  }),

                  PpButton(text: 'Delete my account',
                      color: Colors.red, onPressed: () async {
                        final popup = getIt.get<Popup>();
                        popup.show('Are you sure?',
                            text: 'All your data will be lost!',
                            error: true,
                            buttons: [PopupButton('Delete', error: true, onPressed: () {
                              NavigationService.popToBlank();
                              DeleteAccountProcess();
                            })]
                        );
                    }),
                ])

              /// else
              : PpButton(text: 'Invite', onPressed: () {
              //  todo invitation refactor
              }),

            ],
          ),
        )

    );
  }


}
