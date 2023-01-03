import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/process/log_process.dart';
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
    final invitationRef = firestore
        .collection(Collections.PpUser).doc(Uid.get)
        .collection(Collections.NOTIFICATIONS).doc(contactUid);
    batch.delete(invitationRef);

    // update sender invitationSelfNotification to invitation acceptance
    final contactNotificationDocRef = firestore
        .collection(Collections.PpUser).doc(contactUid)
        .collection(Collections.NOTIFICATIONS).doc(Uid.get);

    final document = PpNotification.createInvitationAcceptance(
        text: invitation.text,
        sender: invitation.receiver,
        receiver: invitation.sender,
        documentId: Uid.get!);
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
            ? Uid.get!
            : invitation.documentId,
        receiver: invitation.receiver == me.nickname
            ? Uid.get!
            : invitation.documentId,
        timeToLive: ConversationSettings.timeToLiveInMinutesDefault,
        timeToLiveAfterRead: ConversationSettings.timeToLiveAfterReadInMinutesDefault,
    );

    ConversationService.messagesCollectionRef.add(message.asMap);
    _conversationService.contactMessagesCollectionRef(contactUid: invitation.documentId)
        .add(message.asMap);
  }

}