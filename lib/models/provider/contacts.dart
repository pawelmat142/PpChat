import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/provider/interfaces/fs_collection_state.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';

class Contacts extends FsCollectionModel<PpUser> {

  List<String> contactUids = [];

  reload(List<String> contactUids) async {
    this.contactUids = contactUids;
    if (this.contactUids.isEmpty) {
      clear();
    } else {
      await resetFirestoreObserver();
    }
  }

  @override
  Query<Map<String, dynamic>> get collectionQuery => firestore
      .collection(Collections.PpUser).where(PpUserFields.uid, whereIn: contactUids);

  @override
  String docIdFromItem(PpUser item) {
    return item.uid;
  }

  @override
  PpUser itemFromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpUser.fromDB(documentSnapshot);
  }

  @override
  Map<String, dynamic> toMap(PpUser item) {
    return item.asMap;
  }

}

