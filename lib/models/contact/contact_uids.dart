import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/interfaces/fs_document_model.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:provider/provider.dart';

class ContactUids extends FsDocumentModel<List<String>> {

  static ContactUids get reference => Provider.of<ContactUids>(NavigationService.context, listen: false);

  static const String contactUidsFieldName = 'contactUids';

  @override
  List<String> get get {
    return super.isNotEmpty ? super.get : [];
  }

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => firestore
      .collection(Collections.PpUser).doc(Uid.get)
      .collection(Collections.CONTACTS).doc(Uid.get);

  @override
  Map<String, dynamic> get stateAsMap => { contactUidsFieldName: get };


  @override
  stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final data = documentSnapshot.data();
    if (data == null) {
      return [];
    }
    final result = data[contactUidsFieldName];
    if (result == null) {
      return [];
    }
    return (result as List).map((item) => item as String).toList();
  }

  addOne(String item) {
    final List<String> currentUids = get;
    currentUids.add(item);
    set(currentUids);
  }

  addMany(List<String> items) {
    final List<String> currentUids = get;
    currentUids.addAll(items);
    set(currentUids);
  }

  deleteOne(String item) {
    final index = get.indexWhere((c) => c == item);
    if (index != -1) {
      final List<String> currentUids = get;
      currentUids.removeAt(index);
      set(currentUids);
      log('[$runtimeType] delete item index: $index');
    }
  }

  bool contains(String contactUid) {
    return get.indexWhere((c) => c == contactUid) != -1;
  }
}