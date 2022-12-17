import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_document_state.dart';

class ContactNicknames extends FirestoreDocumentState<String> {

  static const String contactsFieldName = 'contacts';


  String? _nickname;
  setNickname(String nickname) => _nickname = nickname;
  String get nickname => _nickname != null ? _nickname! : throw Exception('no nickname - use setNickname first!');

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore
      .collection(Collections.PpUser).doc(nickname).collection(Collections.CONTACTS);

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => collectionRef.doc(nickname);

  @override
  Map<String, dynamic> get stateAsMap => {contactsFieldName: state};

  @override
  List<String> stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data();
    if (data == null) return [];
    final result = data[contactsFieldName];
    if (result == null) return [];
    return (result as List).map((item) => item as String).toList();
  }

  @override
  clear() async {
    await super.clear();
    _nickname = null;
  }

  @override
  int getItemIndex(String item) {
    throw UnimplementedError();
  }

}