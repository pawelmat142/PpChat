
import 'package:flutter_chat_app/models/user/pp_user_fields.dart';
import 'package:flutter_chat_app/models/user/pp_user_roles.dart';

class PpUser {
  final String nickname;
  final String role;
  bool logged;

  PpUser({
    required this.nickname,
    required this.role,
    required this.logged,
  });

  Map<String, dynamic> get asMap => {
      PpUserFields.nickname: nickname,
      PpUserFields.logged: logged,
      PpUserFields.role: role,
  };

  static PpUser fromMap(Map<String, dynamic>? ppUserMap) {
      _validatePpUserMap(ppUserMap);
      return PpUser(
          nickname: ppUserMap![PpUserFields.nickname],
          role: ppUserMap[PpUserFields.role],
          logged: ppUserMap[PpUserFields.logged],
      );
  }

  static PpUser create({required String nickname}) => PpUser(
      nickname: nickname,
      role: PpUserRoles.USER,
      logged: false
  );

  static _validatePpUserMap(Map<String, dynamic>? ppUserMap) {
      if (ppUserMap!.keys.contains(PpUserFields.nickname)
          && ppUserMap[PpUserFields.nickname] is String
          && ppUserMap.keys.contains(PpUserFields.role)
          && PpUserRoles.list.contains(ppUserMap[PpUserFields.role])
          && ppUserMap.keys.contains(PpUserFields.logged)
          && ppUserMap[PpUserFields.logged] is bool
      ) {return;} else {
          throw Exception(["PpUser MAP ERROR"]);
      //  TODO: obsłużyć popup?
      }
  }

}

