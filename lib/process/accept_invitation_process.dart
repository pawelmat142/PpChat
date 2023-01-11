import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/conversation/conversation.dart';
import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/process/log_process.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:pointycastle/asymmetric/api.dart';

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
        .collection(Collections.PpUser).doc(contactUid);

    final contactNotificationDocRef = contactPpUserDocRef
        .collection(Collections.NOTIFICATIONS).doc(Uid.get);

    // delete invitation
    final invitationRef = firestore
        .collection(Collections.PpUser).doc(Uid.get)
        .collection(Collections.NOTIFICATIONS).doc(contactUid);
    batch.delete(invitationRef);


    // update sender invitationSelfNotification to invitation acceptance
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

  _resolveFirstMessage(PpNotification invitation) async {
    log('[AcceptInvitationProcess] _resolveFirstMessage');

    final publicKey = await _getContactPublicKey();
    if (publicKey == null) throw Exception('Public key not found for contactUid: $contactUid');

    final temporaryConversationObject = Conversation(contactUid: contactUid);
    await temporaryConversationObject.open(temporary: true);
    temporaryConversationObject.contactPublicKey = publicKey;

    temporaryConversationObject.sendMessage(invitation.text);
  }

  Future<RSAPublicKey?> _getContactPublicKey() async {
    final user = await _getPpUserObjectByUid();
    return user == null ? null : HiveRsaPair.stringToRsaPublic(user.publicKeyAsString);
  }

  Future<PpUser?> _getPpUserObjectByUid() async {
    final result = await contactPpUserDocRef.get();
    final data = result.data();
    return data == null ? null : PpUser.fromMap(data);
  }

}