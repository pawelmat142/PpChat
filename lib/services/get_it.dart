import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/models/group_conversation/group_conversation_service.dart';
import 'package:flutter_chat_app/models/notification/invitation_service.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';
import 'package:flutter_chat_app/models/notification/pp_notification_service.dart';
import 'package:flutter_chat_app/models/user/pp_user_service.dart';
import 'package:flutter_chat_app/services/app_service.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:flutter_chat_app/models/contact/contacts_service.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:get_it/get_it.dart';

import 'deleted_account_service.dart';

final getIt = GetIt.instance;

Future<void> initGetIt() async {

  getIt.registerLazySingleton(() => Popup());

  getIt.registerLazySingleton(() => PpSpinner());

  getIt.registerLazySingleton(() => PpUserService());

  getIt.registerLazySingleton(() => DeletedAccountService());

  getIt.registerLazySingleton(() => InvitationService());

  getIt.registerLazySingleton(() => ContactsService());

  getIt.registerLazySingleton(() => ConversationService());

  getIt.registerLazySingleton(() => LogService());

  getIt.registerLazySingleton(() => ConversationSettingsService());

  getIt.registerLazySingleton(() => AppService());

  getIt.registerLazySingleton(() => GroupConversationService());

  getIt.registerSingleton(AuthenticationService());

  getIt.registerSingleton(PpNotificationService());
}
