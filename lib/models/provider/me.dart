import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/config/navigation_service.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/provider/interfaces/fs_document_model.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:provider/provider.dart';

class Me extends FsDocumentModel<PpUser> {

  static Me get reference => Provider.of<Me>(NavigationService.context, listen: false);
  
  String get getUid => States.getUid!;

  String get uid => get.uid;
  String get nickname => get.nickname;


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