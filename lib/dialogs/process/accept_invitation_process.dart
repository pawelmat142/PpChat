import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/models/pp_message.dart';
import 'package:flutter_chat_app/models/provider/contact_uids.dart';
import 'package:flutter_chat_app/models/provider/me.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/dialogs/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';

class AcceptInvitationProcess extends LogProcess {

  final _conversationService = getIt.get<ConversationService>();

  final ContactUids contactUids = ContactUids.reference;
  final Me me = Me.reference;


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
        sender: invitation.receiver, receiver: invitation.sender, documentId: States.getUid!);
    batch.set(contactNotificationDocRef, document.asMap);

    //add to contacts
    contactUids.addOne(contactUid);

    //finalize
    await batch.commit();

    _resolveFirstMessage(invitation);
    log('[STOP] [AcceptInvitationProcess]');
  }

  _resolveFirstMessage(PpNotification invitation) {
    log('[AcceptInvitationProcess] _resolveFirstMessage');

    final message = PpMessage.create(
        message: invitation.text,
        sender: invitation.sender == me.nickname
            ? States.getUid!
            : invitation.documentId,
        receiver: invitation.receiver == me.nickname
            ? States.getUid!
            : invitation.documentId);

    _conversationService.messagesCollectionRef.add(message.asMap);
    _conversationService.contactMessagesCollectionRef(contactUid: invitation.documentId)
        .add(message.asMap);
  }

}