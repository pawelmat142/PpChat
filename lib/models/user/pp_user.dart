import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/crypto/hive_rsa_pair.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_model.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';
import 'package:flutter_chat_app/models/user/pp_user_roles.dart';

class PpUser {
  final String uid;
  final String nickname;
  final String role;
  AvatarModel avatar;
  bool logged;
  String publicKeyAsString;

  PpUser({
    required this.uid,
    required this.nickname,
    required this.role,
    required this.avatar,
    required this.logged,
    required this.publicKeyAsString,
  });

  Map<String, dynamic> get asMap => {
    PpUserFields.uid: uid,
    PpUserFields.nickname: nickname,
    PpUserFields.role: role,
    PpUserFields.avatar: avatar.asMap,
    PpUserFields.logged: logged,
    PpUserFields.publicKeyAsString: publicKeyAsString,
  };

  static PpUser fromMap(Map<String, dynamic> ppUserMap) {
    PpUserFields.validate(ppUserMap);
    return PpUser(
      uid: ppUserMap[PpUserFields.uid],
      nickname: ppUserMap[PpUserFields.nickname],
      role: ppUserMap[PpUserFields.role],
      avatar: AvatarModel.fromMap(ppUserMap[PpUserFields.avatar]),
      logged: ppUserMap[PpUserFields.logged],
      publicKeyAsString: ppUserMap[PpUserFields.publicKeyAsString],
    );
  }

  static PpUser fromDB(DocumentSnapshot<Object?> doc) {
    // try {
      return PpUser.fromMap(doc.data() as Map<String, dynamic>);
    // } catch (error) {
    //   throw Exception(['FIREBASE OBJECT CAST TO MAP ERROR - USER']);
    // }
  }

  static Future<PpUser> create({
    required String nickname,
    required String uid,
  }) async {
    return PpUser(
      uid: uid,
      nickname: nickname,
      role: PpUserRoles.USER,
      avatar: AvatarService.createRandom(userNickname: nickname),
      logged: false,
      publicKeyAsString: await HiveRsaPair.generatePairAndSaveToHive()
  );}


  PpUser copyWithNewPublicKey(String newPublicKeyAsString) {
    return PpUser(
        uid: uid,
        nickname: nickname,
        role: role,
        avatar: avatar,
        logged: logged,
        publicKeyAsString: newPublicKeyAsString
    );
  }
}

