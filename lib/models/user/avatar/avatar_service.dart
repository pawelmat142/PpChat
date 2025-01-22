import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_model.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_hive_image.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/log_service.dart';
import 'package:flutter_chat_app/services/uid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  static AvatarModel createRandom({required String userNickname}) {
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

  ///SAVE

  static Future<String> uploadFileToFs({required File file}) async {
    final Reference storageRef = _userAvatarFsStorageRefByUid(Uid.get!);
    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }

  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result == null) return null;
    return File(result.path);
  }


  ///GET

  static Future<File?> getImageFile({required String uid, required AvatarModel model}) async {
    final hiveImage = await AvatarHiveImage.getByUid(uid: uid);

    if (hiveImage != null && hiveImage.imageUrl == model.imageUrl) {
      return await _getAvatarFileFromDevice(uid: uid);
    } else {
      return await _getAvatarFileFromFsAndSaveToDevice(model: model, uid: uid);
    }
  }

  static Future<File> _getAvatarFileFromDevice({required String uid}) async {
    final path = await _userAvatarPathInDevice(uid: uid);
    log('get file from device - uid: $uid');
    return File(path);
  }

  static Future<String> _userAvatarPathInDevice({required String uid}) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    return '${appDirectory.path}/avatars/$uid';
  }

  static Future<File?> _getAvatarFileFromFsAndSaveToDevice({required AvatarModel model, required String uid}) async {
    final storageRef = FirebaseStorage.instance.refFromURL(model.imageUrl);

    final bytes =  await storageRef.getData();
    if (bytes == null) return null;

    final newPath = await _userAvatarPathInDevice(uid: uid);
    final newFile = await File(newPath).create(recursive: true);
    final resultFile = await newFile.writeAsBytes(bytes);

    final hiveImage = AvatarHiveImage(
        uid: uid,
        imageUrl: model.imageUrl,
        devicePath: newPath
    );
    await hiveImage.saveIt();

    log('get file from firebase storage - uid: $uid');
    return resultFile;
  }

  static Reference _userAvatarFsStorageRefByUid(String uid) {
    return FirebaseStorage.instance.ref('avatars/$uid');
  }


  /// DELETE

  static Future<void> deleteFileFromFs({required String uid}) async {
    await _userAvatarFsStorageRefByUid(uid).delete();
  }

  static Future<void> deleteIfExistsInDevice({required String uid}) async {
    if (await AvatarHiveImage.exists(uid: uid)) {
      final hiveImage = await AvatarHiveImage.getByUid(uid: uid);
      File(hiveImage!.devicePath).deleteSync(recursive: true);
      await AvatarHiveImage.deletePath(uid: uid);
      log('deleted avatar from device - uid: $uid');
    }
  }

  static Future<void> deleteAllAvatarsFromDeviceAndHive() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final avatarsDirectory = Directory('${appDirectory.path}/avatars');
    if (avatarsDirectory.existsSync()) {
      avatarsDirectory.deleteSync(recursive: true);
    }
    await AvatarHiveImage.cleanBox();
    log('deleted all avatar files and hive box clean');
  }

  static Future<void> deleteMyAvatarImageInFsStorage() async {
    final myImageUrl = Me.reference.get.avatar.imageUrl;
    if (myImageUrl == '') return;
    final imageRef = FirebaseStorage.instance.refFromURL(myImageUrl);
    await imageRef.delete();
    log('deleted image in storage');
  }

}

