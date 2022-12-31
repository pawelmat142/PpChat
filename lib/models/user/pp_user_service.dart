import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';

class PpUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final logService = getIt.get<LogService>();

  Me get me => Me.reference;
  String get nickname => me.nickname.isNotEmpty ? me.nickname : AuthenticationService.nickname;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection(Collections.PpUser);
  DocumentReference<Map<String, dynamic>> get documentRef => _collection.doc(Uid.get);
  DocumentReference<Map<String, dynamic>> get _privateDocumentRef => documentRef.collection(Collections.PRIVATE).doc(Uid.get);

  bool initialized = false;

  Future<PpUser> get userSnapshot async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await documentRef.get();
    return snapshot.exists ? PpUser.fromDB(snapshot) : throw Exception(['NO USER DATA IN FIRESTORE']);
  }


  Future<PpUser?> findByNickname(String nickname) async {
    final querySnapshot = await _collection
        .where(PpUserFields.nickname, isEqualTo: nickname)
        .get();
    return querySnapshot.size > 0
      ? PpUser.fromDB(querySnapshot.docs.first)
      : null;
  }

  Future<PpUser?> findBySignature(String signature) async {
    final querySnapshot = await _collection
        .where(PpUserFields.signature, isEqualTo: signature)
        .get();
    return querySnapshot.size > 0
      ? PpUser.fromDB(querySnapshot.docs.first)
      : null;
  }


  Future<void> createNewUser({required String nickname}) async {
    final signature = _collection.doc().id;
    final newUser = PpUser.create(nickname: nickname, uid: Uid.get!, signature: signature);
    await documentRef.set(newUser.asMap);
  }


  deleteUserDocument() async {
    final batch = _firestore.batch();
    batch.delete(_privateDocumentRef);
    batch.delete(documentRef);
    await batch.commit();
  }
  
  setLoggedTrue() async {
    await documentRef.update({PpUserFields.logged : true});
  }

  updateLogged(bool logged) async {
    await documentRef.update({PpUserFields.logged : logged});
  }

}