import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_document_state.dart';

class Me extends FirestoreDocumentState<PpUser> {

  String? _nickname;
  setNickname(String nickname) => _nickname = nickname;

  String get nickname => state.isNotEmpty
      ? state[0].nickname
      : _nickname != null ? _nickname! : '';

  @override
  int getItemIndex(PpUser item) => 0;

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore.collection(Collections.User);

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => collectionRef.doc(nickname);

  @override
  Map<String, dynamic> get stateAsMap => state.first.asMap;

  @override
  List<PpUser> stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return [PpUser.fromDB(documentSnapshot)];
  }

}