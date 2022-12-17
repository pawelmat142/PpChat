import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/state/interfaces/firestore_document_state.dart';
import 'package:flutter_chat_app/state/states.dart';

class ContactUids extends FirestoreDocumentState<String> {

  static const String contactUidsFieldName = 'contactUids';

  static get getUid => States.getUid;

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore
      .collection(Collections.PpUser).doc(getUid).collection(Collections.CONTACTS);

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => collectionRef.doc(getUid);

  @override
  Map<String, dynamic> get stateAsMap => {contactUidsFieldName: state};

  @override
  List<String> stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data();
    if (data == null) return [];
    final result = data[contactUidsFieldName];
    if (result == null) return [];
    return (result as List).map((item) => item as String).toList();
  }

  @override
  clear() async {
    await super.clear();
  }

  @override
  int getItemIndex(String item) {
    throw UnimplementedError();
  }

}