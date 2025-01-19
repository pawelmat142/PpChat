import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/models/conversation/pp_message.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:hive/hive.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

import '../models/crypto/hive_rsa_pair.dart';

class AcceptInvitationProcess extends LogProcess {

  final PpNotification invitation;
  final ContactUids contactUids = ContactUids.reference;
  final Me me = Me.reference;

  AcceptInvitationProcess({required this.invitation});

  late String contactUid;
  late DocumentReference<Map<String, dynamic>> contactPpUserDocRef;


  process() async {
    log('[START] [AcceptInvitationProcess]');
    final batch = firestore.batch();

    contactUid = invitation.documentId;

    contactPpUserDocRef = firestore
        .collection(Collections.PpUser)
        .doc(contactUid);

    final contactNotificationDocRef = contactPpUserDocRef
        .collection(Collections.NOTIFICATIONS).doc(Uid.get);

    // delete invitation notification
    final invitationRef = firestore
        .collection(Collections.PpUser).doc(Uid.get)
        .collection(Collections.NOTIFICATIONS).doc(contactUid);
    batch.delete(invitationRef);

    // update sender invitationSelfNotification to invitationAcceptance
    final document = PpNotification.createInvitationAcceptance(
        text: invitation.text,
        sender: invitation.receiver,
        receiver: invitation.sender,
        documentId: Uid.get!,
        avatar: Me.reference.get.avatar
    );
    batch.set(contactNotificationDocRef, document.asMap);

    //add to contacts
    contactUids.addOne(contactUid);

    //finalize
    await batch.commit();

    _firstMessageSimulation(invitation);
    log('[STOP] [AcceptInvitationProcess]');
  }

  _firstMessageSimulation(PpNotification invitation) async {
    if (invitation.text.isEmpty) {
      log('[SKIP] [AcceptInvitationProcess] _firstMessageSimulation');
      return;
    }
    log('[AcceptInvitationProcess] _firstMessageSimulation');

    final PpMessage firstMessage = PpMessage.create(
        message: invitation.text,
        sender: contactUid,
        receiver: Uid.get!,
        timeToLive: ConversationSettings.timeToLiveInMinutesDefault,
        timeToLiveAfterRead: ConversationSettings.timeToLiveAfterReadInMinutesDefault
    );

    final PpMessage encryptedFirstMessage = PpMessage.create(
        message: encrypt(invitation.text, HiveRsaPair.stringToRsaPublic(Me.reference.get.publicKeyAsString)),
        sender: contactUid,
        receiver: Uid.get!,
        timeToLive: ConversationSettings.timeToLiveInMinutesDefault,
        timeToLiveAfterRead: ConversationSettings.timeToLiveAfterReadInMinutesDefault
    );

    await firestore.collection(Collections.PpUser)
        .doc(contactUid)
        .collection(Collections.Messages)
        .add(firstMessage.asMap);

    Box<PpMessage> box = await Hive.openBox(Conversation.hiveKey(contactUid: contactUid));
    await box.add(encryptedFirstMessage);
  }
}