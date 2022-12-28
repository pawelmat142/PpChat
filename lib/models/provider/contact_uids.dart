import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/provider/interfaces/fs_document_model.dart';
import 'package:flutter_chat_app/state/states.dart';

class ContactUids extends FsDocumentModel<List<String>> {

  static const String contactUidsFieldName = 'contactUids';

  Future<List<String>> start() async {
    await startFirestoreObserver();
    return get;
  }

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => firestore
      .collection(Collections.PpUser).doc(States.getUid)
      .collection(Collections.CONTACTS).doc(States.getUid);

  @override
  Map<String, dynamic> get stateAsMap => {contactUidsFieldName: get};


  @override
  stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data();
    if (data == null) return [];
    final result = data[contactUidsFieldName];
    if (result == null) return [];
    return (result as List).map((item) => item as String).toList();
  }

  addOne(String item) {
    get.add(item);
    set(get);
  }

  addMany(List<String> items) {
    get.addAll(items);
    set(get);
  }

}