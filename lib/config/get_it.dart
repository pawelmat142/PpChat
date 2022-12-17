import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/pp_flushbar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/services/contacts_service.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/state/states.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initGetIt() async {

  getIt.registerLazySingleton(() => Popup());

  getIt.registerLazySingleton(() => PpSpinner());

  getIt.registerLazySingleton(() => PpUserService());

  getIt.registerLazySingleton(() => PpFlushbar());

  getIt.registerLazySingleton(() => PpNotificationService());

  getIt.registerLazySingleton(() => InvitationService());

  getIt.registerLazySingleton(() => ContactsService());

  getIt.registerLazySingleton(() => ConversationService());

  getIt.registerLazySingleton(() => States());

  getIt.registerLazySingleton(() => LogService());

  getIt.registerSingleton(AuthenticationService());
}
