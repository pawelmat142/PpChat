import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/contact/contact_uids.dart';
import 'package:flutter_chat_app/models/interfaces/fs_collection_state.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';
import 'package:provider/provider.dart';

class Contacts extends FsCollectionModel<PpUser> {

  static Contacts get reference => Provider.of<Contacts>(NavigationService.context, listen: false);

  static ContactUids contactUidsRef = ContactUids.reference;

  List<String> get contactUids => contactUidsRef.get;


  start() async {
    await _contactUidsListener();
    contactUidsRef.addListener(_contactUidsListener);
    log('[Contacts] add listener');
  }

  stopContactUidsListener() {
    contactUidsRef.removeListener(_contactUidsListener);
  }

   _contactUidsListener() async {
    log('[Contacts] listener triggered');
    final contactUids = contactUidsRef.get;
    if (contactUids.isEmpty) {
      clear();
    } else {
      await resetFirestoreObserver();
    }
  }

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef => firestore
      .collection(Collections.PpUser);

  @override
  Query<Map<String, dynamic>> get collectionQuery => collectionRef
      .where(PpUserFields.uid, whereIn: contactUids);

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

  @override
  int indexFromItem(PpUser item) {
    return get.indexWhere((i) => i.uid == item.uid);
  }




  getByNickname(String nickname) {
    final index = get.indexWhere((c) => c.nickname == nickname);
    return index != -1 ? get[index] : null;
  }

  getByUid(String uid) {
    final index = get.indexWhere((c) => c.uid == uid);
    return index != -1 ? get[index] : null;
  }

  bool containsByUid(String uid) {
    return get.indexWhere((c) => c.uid == uid) != -1;
  }


}

