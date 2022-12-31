import 'package:firebase_auth/firebase_auth.dart';

class Uid {

  static String? get get => FirebaseAuth.instance.currentUser?.uid;

}