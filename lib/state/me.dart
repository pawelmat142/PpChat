import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_document_state.dart';
import 'package:flutter_chat_app/state/states.dart';

class Me extends FirestoreDocumentState<PpUser> {

  String get signature => state.isNotEmpty ? state[0].signature : throw Exception('!!!!!!!!!!!Me not set');

  String get nickname => state.isNotEmpty
      ? state[0].nickname
      : throw Exception('no nickname!');

  @override
  int getItemIndex(PpUser item) => 0;

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore.collection(Collections.PpUser);

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => collectionRef.doc(States.getUid);

  @override
  Map<String, dynamic> get stateAsMap => state.first.asMap;

  @override
  List<PpUser> stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return [PpUser.fromDB(documentSnapshot)];
  }

}