import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBf_j5vVtRBuxqppdY5TiDpTuoaeuPgxZs',
    appId: '1:221057103443:android:695ab619d30ff55237b8a6',
    messagingSenderId: '221057103443',
    projectId: 'flash-chat-e537e',
    storageBucket: 'flash-chat-e537e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVTX-NYVYcSpES09jU9czqRNK2c48Pe94',
    appId: '1:221057103443:ios:bee16f47169b294337b8a6',
    messagingSenderId: '221057103443',
    projectId: 'flash-chat-e537e',
    storageBucket: 'flash-chat-e537e.appspot.com',
    iosClientId: '221057103443-b3md1iigq6to6avd59uuv63mbhi3b8vn.apps.googleusercontent.com',
    iosBundleId: 'pl.pppmmm.flutterChatApp',
  );
}
