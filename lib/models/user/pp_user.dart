import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';
import 'package:flutter_chat_app/models/user/pp_user_roles.dart';

class PpUser {
  final String uid;
  final String signature;
  final String nickname;
  final String role;
  bool logged;

  PpUser({
    required this.uid,
    required this.signature,
    required this.nickname,
    required this.role,
    required this.logged,
  });

  Map<String, dynamic> get asMap => {
    PpUserFields.uid: uid,
    PpUserFields.signature: signature,
    PpUserFields.nickname: nickname,
    PpUserFields.logged: logged,
    PpUserFields.role: role,
  };

  static PpUser fromMap(Map<String, dynamic> ppUserMap) {
    _validatePpUserMap(ppUserMap);
    return PpUser(
      uid: ppUserMap[PpUserFields.uid],
      signature: ppUserMap[PpUserFields.signature],
      nickname: ppUserMap[PpUserFields.nickname],
      role: ppUserMap[PpUserFields.role],
      logged: ppUserMap[PpUserFields.logged],
    );
  }

  static PpUser fromDB(DocumentSnapshot<Object?> doc) {
    try {
      return PpUser.fromMap(doc.data() as Map<String, dynamic>);
    } catch (error) {
      throw Exception(['FIREBASE OBJECT CAST TO MAP ERROR - USER']);
    }
  }

  static PpUser create({
    required String nickname,
    required String uid,
    required String signature
  }) => PpUser(
      uid: uid,
      signature: signature,
      nickname: nickname,
      role: PpUserRoles.USER,
      logged: false
  );

  static _validatePpUserMap(Map<String, dynamic>? ppUserMap) {
    if (ppUserMap!.keys.contains(PpUserFields.uid)
        && ppUserMap[PpUserFields.uid] is String
        && ppUserMap.keys.contains(PpUserFields.signature)
        && ppUserMap[PpUserFields.signature] is String
        && ppUserMap.keys.contains(PpUserFields.nickname)
        && ppUserMap[PpUserFields.nickname] is String
        && ppUserMap.keys.contains(PpUserFields.role)
        && PpUserRoles.list.contains(ppUserMap[PpUserFields.role])
        && ppUserMap.keys.contains(PpUserFields.logged)
        && ppUserMap[PpUserFields.logged] is bool
    ) {return;} else {
      throw Exception(["PpUser MAP ERROR"]);
    }
  }

}

