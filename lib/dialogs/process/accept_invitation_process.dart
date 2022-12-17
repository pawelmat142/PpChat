import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/state/contacts.dart';

class AcceptInvitationProcess extends LogProcess {

  final state = getIt.get<States>();

  final PpNotification invitation;

  AcceptInvitationProcess({required this.invitation});

  process() async {
    log('[START] [AcceptInvitationProcess]');
    final batch = firestore.batch();

    final contactUid = invitation.documentId;

    // delete invitation
    batch.delete(firestore.collection(Collections.PpUser).doc(States.getUid)
        .collection(Collections.NOTIFICATIONS).doc(contactUid));

    // update sender invitationSelfNotification to invitation acceptance
    final contactNotificationDocRef = firestore
        .collection(Collections.PpUser).doc(contactUid)
        .collection(Collections.NOTIFICATIONS).doc(States.getUid);

    final document = PpNotification.createInvitationAcceptance(text: invitation.text,
        sender: invitation.receiver, receiver: invitation.sender, documentId: States.getUid);
    batch.set(contactNotificationDocRef, document.asMap);

    //add to contacts
    final newContactNicknames = state.contacts.nicknames + [contactUid];
    final contactNicknamesDocRef = firestore
        .collection(Collections.PpUser).doc(States.getUid)
        .collection(Collections.CONTACTS).doc(States.getUid);
    batch.set(contactNicknamesDocRef,
        {Contacts.contactsFieldName: newContactNicknames});

    //finalize
    await batch.commit();
    log('[STOP] [AcceptInvitationProcess]');
  }
}