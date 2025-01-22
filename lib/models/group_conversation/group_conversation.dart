import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/models/group_conversation/group_message.dart';
import 'package:flutter_chat_app/models/interfaces/fs_document_model.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_model.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/services/uid.dart';

abstract class GroupConversationFields {
  static const name = 'name';
  static const documentId = 'documentId';
  static const ownerUid = 'ownerUid';
  static const memberUids = 'memberUids';
  static const avatar = 'avatar';
  static const settings = 'settings';
  static const messages = 'messages';
}

class GroupConversation extends FsDocumentModel<GroupConversation> {

  final String name;
  final String documentId;
  final String ownerUid;
  final List<String> memberUids; //uid: nickname
  final AvatarModel avatar;
  final ConversationSettings settings;
  final List<GroupMessage> messages;

  GroupConversation({
      required this.name,
      required this.documentId,
      required this.ownerUid,
      required this.memberUids,
      required this.avatar,
      required this.settings,
      required this.messages,
  });

  static CollectionReference<Map<String, dynamic>> get collectionRef => FirebaseFirestore
      .instance.collection(Collections.GroupConversations);

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => collectionRef.doc(documentId);

  @override
  Map<String, dynamic> get stateAsMap => asMap;

  @override
  stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return fromMap(documentSnapshot.data()!);
  }


  Map<String, dynamic> get asMap => {
    GroupConversationFields.name: name,
    GroupConversationFields.documentId: documentId,
    GroupConversationFields.ownerUid: ownerUid,
    GroupConversationFields.memberUids: memberUids,
    GroupConversationFields.avatar: avatar.asMap,
    GroupConversationFields.settings: settings.asMap,
    GroupConversationFields.messages: GroupMessage.toMapsList(messages),
  };

  static GroupConversation fromMap(Map<String, dynamic> convMap) {
    return GroupConversation(
      name: convMap[GroupConversationFields.name],
      documentId: convMap[GroupConversationFields.documentId],
      ownerUid: convMap[GroupConversationFields.ownerUid],
      memberUids: convMap[GroupConversationFields.memberUids],
      avatar: AvatarModel.fromMap(convMap[GroupConversationFields.avatar]),
      messages: GroupMessage.listFromMaps(convMap[GroupConversationFields.messages]),
      settings: ConversationSettings.fromMap(convMap[GroupConversationFields.settings]),
    );
  }


  static GroupConversation create({required String name}) {
    final newDocId = collectionRef.doc().id;
    return GroupConversation(
        name: name,
        documentId: newDocId,
        ownerUid: Uid.get!,
        memberUids: [Uid.get!],
        avatar: AvatarService.createRandom(userNickname: newDocId),
        settings: ConversationSettings.create(
            contactUid: newDocId,
            timeToLive: 0,
            timeToLiveAfterRead: 0
        ),
        messages: [GroupMessage(message: 'first', nickname: Me.reference.nickname, timestamp: DateTime.now())]
    );
  }

  save() => set(get);

}


