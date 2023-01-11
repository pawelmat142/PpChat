import 'package:flutter_chat_app/models/user/pp_user_roles.dart';

abstract class PpUserFields {
  static const uid = 'uid';
  static const nickname = 'nickname';
  static const role = 'role';
  static const avatar = 'avatar';
  static const logged = 'logged';
  static const publicKeyAsString = 'publicKeyAsString';


  static void validate(Map<String, dynamic>? ppUserMap) {
    if (
      ppUserMap!.keys.contains(PpUserFields.uid)
      && ppUserMap[PpUserFields.uid] is String

      && ppUserMap.keys.contains(PpUserFields.nickname)
      && ppUserMap[PpUserFields.nickname] is String

      && ppUserMap.keys.contains(PpUserFields.role)
      && PpUserRoles.list.contains(ppUserMap[PpUserFields.role])

      && ppUserMap.keys.contains(PpUserFields.avatar)

      && ppUserMap.keys.contains(PpUserFields.logged)
      && ppUserMap[PpUserFields.logged] is bool

      && ppUserMap.keys.contains(PpUserFields.publicKeyAsString)
      && ppUserMap[PpUserFields.publicKeyAsString] is String

    ) {return;} else {
      throw Exception(["PpUser MAP ERROR"]);
    }
  }
}