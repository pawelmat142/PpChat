import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/constants/collections.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';
import 'package:flutter_chat_app/models/user/pp_user_roles.dart';

class PpUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _collection;

  DocumentReference<Map<String, dynamic>>? _documentReference;
  DocumentReference<Map<String, dynamic>> get _userDocRef => _documentReference != null ? _documentReference! : throw Exception(['NO USER DOCUMENT REFERENCE']);

  PpUserService() {
    _collection = _firestore.collection(Collections.User);
  }

  Future<void> createNewUser({required String nickname}) async {
      _documentReference = await _collection.add({
          PpUserFields.nickname: nickname,
          PpUserFields.logged: false,
          PpUserFields.role: PpUserRoles.USER,
      });
  }

  Future<PpUser> get({String? docId}) async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _collection.doc(docId ?? _userDocRef.id).get();
      return snapshot.exists ? PpUser.fromMap(snapshot.data()!) : throw Exception(['NO DATA']);
  }

  void setLogged(bool logged) => _userDocRef.update({PpUserFields.logged: logged});

  void closeDao() => _documentReference = null;
}