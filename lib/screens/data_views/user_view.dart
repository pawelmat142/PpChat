import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/models/contact/contacts.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/process/delete_account_process.dart';
import 'package:flutter_chat_app/screens/data_views/edit_avatar_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/notifications_screen.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';


class UserView extends StatelessWidget {
  UserView({Key? key}) : super(key: key);

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

  String? message;

  @override
  Widget build(BuildContext context) {

    final user = ModalRoute.of(context)!.settings.arguments as PpUser;
    final bool isMe = Uid.get == user.uid;

    final bool isContact = Contacts.reference.getByNickname(user.nickname) != null;

    final bool isFoundUser = !isMe && !isContact;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: Text(
            isMe ?  'My account'
                : isContact ? 'Contact view'
                  : isFoundUser ? 'You have found user' : '')
        ),

        body: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: ListView(
            padding: BASIC_HORIZONTAL_PADDING,
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

              ///
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
              : Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 200),
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: TextField(
                        // scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 200),
                        onChanged: (x) => message = x,
                        decoration: const InputDecoration(
                          labelText: 'FIRST MESSAGE',
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                    ),

                    PpButton(text: 'Invite', onPressed: () {
                      _onInvite(user, context: context);
                    })

                  ],
                ),
              ),

            ],
          ),
        )

    );
  }

  _onInvite(PpUser foundUser, {required BuildContext context}) async {
    final spinner = getIt.get<PpSpinner>();
    final popup = getIt.get<Popup>();
    try {
      spinner.start();
      await _sendInvitationNotifications(foundUser);
      PpSnackBar.invitationSent();
    } catch (error) {
      spinner.stop();
      popup.show('Something went wrong', error: true, delay: 200);
    }
    spinner.stop();
    _goToNotifications(context: context);
  }

  _goToNotifications({required BuildContext context}) {
    Navigator.popAndPushNamed(context, NotificationsScreen.id);
  }

  _sendInvitationNotifications(PpUser foundUser) async {
    final userService = getIt.get<PpUserService>();

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final receiverNotificationsRef = firestore
        .collection(Collections.PpUser).doc(foundUser.uid)
        .collection(Collections.NOTIFICATIONS).doc(Uid.get);
    //contact's notification docId = my uid so any next notification from me will overwrite it
    batch.set(receiverNotificationsRef, PpNotification.createInvitation(
        sender: userService.nickname,
        receiver: foundUser.nickname,
        text: message ?? '').asMap);

    final myNotificationsRef = firestore
        .collection(Collections.PpUser).doc(Uid.get)
        .collection(Collections.NOTIFICATIONS).doc(foundUser.uid);
    //my self notification docId = contact's uid so any notification from contact will overwrite it
    PpNotification selfNotification = PpNotification.createInvitationSelfNotification(
      documentId: foundUser.uid,
      sender: userService.nickname,
      receiver: foundUser.nickname,
      text: message ?? '',
    );
    batch.set(myNotificationsRef, selfNotification.asMap);

    await batch.commit();
  }


}
