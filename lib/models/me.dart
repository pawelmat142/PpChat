import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/fs_document_model.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/state/states.dart';

class Me extends FsDocumentModel<PpUser> {

  String get getUid => States.getUid!;

  String get uid => get.uid;
  String get nickname => get.nickname;

  Future<PpUser> start() async {
    print('start');
    await startFirestoreObserver();
    return get;
  }

  @override
  DocumentReference<Map<String, dynamic>> get documentRef => firestore
      .collection(Collections.PpUser).doc(getUid);

  @override
  Map<String, dynamic> get stateAsMap => get.asMap;

  @override
  PpUser stateFromSnapshot(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    return PpUser.fromDB(documentSnapshot);
  }

}