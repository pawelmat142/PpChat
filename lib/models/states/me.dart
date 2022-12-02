import 'package:flutter_chat_app/models/states/single_data_state_object.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';

class Me extends SingleDataStateObject<PpUser> {

  String get nickname => get.nickname;

}