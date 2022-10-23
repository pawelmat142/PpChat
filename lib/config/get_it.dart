import 'package:flutter_chat_app/dialogs/popup.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initGetIt() async {

  getIt.registerLazySingleton(() => Popup());

  getIt.registerSingleton(AuthenticationService());

}
