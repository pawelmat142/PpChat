import 'dart:math';

import 'package:cross_file/cross_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/avatar/avatar_model.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

abstract class AvatarService {

  // static const String avatarFont = 'Rubik Spray Paint';
  // static const String avatarFont = 'Concert One';
  static const String avatarFont = 'Luckiest Guy';

  static const Map<String, Color> colorsPalette = {
    'blue': Color(0xFF2196F3),
    'green': Color(0xFF4CAF50),
    'teal': Color(0xFF009688),
    'orange': Color(0xFFFF9800),
    'red': Color(0xFFD32F2F),
    'pink': Color(0xFFE91E63),
    'violet': Color(0xFF9C27B0),
    'purple': Color(0xFF673AB7),
    'grey': Color(0xFF455A64),
  };

  static String get randomColorKey => colorsPalette.keys
      .toList()[Random().nextInt(colorsPalette.length)];

  static Color get randomColor => colorsPalette[randomColorKey]!;

  static Color getColor(String key) => colorsPalette[key]!;

  static createRandom({required String userNickname}) {
    return AvatarModel(
        color: randomColorKey,
        txt: userNickname[0],
        imageUrl: ''
    );
  }

  static Future<void> saveAvatarEdit(AvatarModel model) async {
    PpUser newMe = Me.reference.get;
    newMe.avatar = model;
    await Me.reference.set(newMe);
    log('new avatar saved!');
  }

  static log(String txt) {
    final logService = getIt.get<LogService>();
    logService.log('[AvatarService] $txt');
  }

  /// The user selects a file, and the task is added to the list.
  static Future<UploadTask?> uploadFile(XFile? file) async {
    if (file == null) {
      ScaffoldMessenger.of(NavigationService.context).showSnackBar(
        const SnackBar(
          content: Text('No file was selected'),
        ),
      );

      return null;
    }

    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('flutter-tests')
        .child('/some-image.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      // uploadTask = ref.putFile(io.File(file.path), metadata);
    }

    // return Future.value(uploadTask);
  }


}

