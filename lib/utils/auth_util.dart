import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthUtil {

  static const String _firebaseEmailSuffix = '@no.email';

  static String toEmail(String login) => login + _firebaseEmailSuffix;

  static String _toNickname(String email) => email.replaceAll(_firebaseEmailSuffix, '');

  static String get nickname => _toNickname(FirebaseAuth.instance.currentUser!.email!);
}