import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/notification/pp_notification.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_model_widget.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_image_widget.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_model.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    this.size = AVATAR_SIZE,
    required this.model,
    this.pickedImageFile,
    required this.uid,
    Key? key
  }) : super(key: key);

  final double? size;
  final AvatarModel model;
  final File? pickedImageFile;
  final String uid;

  static AvatarWidget createFromNotification(PpNotification notification, {double? size}) {
    return AvatarWidget(model: AvatarService.createRandom(
        userNickname: notification.sender),
        uid: notification.documentId,
        size: size,
    );
  }

  //todo: zrobic cos zeby kazdy pojedynczy widget mial jedna instancje caly czas i zeby sie nie rerenderował
  @override
  Widget build(BuildContext context) {

    return Hero(
      tag: 'tag_$uid',
      child: pickedImageFile != null

          ? AvatarImageWidget(size: size!, file: pickedImageFile!)

          : model.hasImage

          ? FutureBuilder<File?>(
          future: AvatarService.getImageFile(uid: uid, model: model),
          builder: (context, snapshot) {
            final imageFile = snapshot.data;

            return imageFile == null
                ? AvatarModelWidget(model, size: size!)
                : AvatarImageWidget(size: size!, file: imageFile);
          }
      )
          : AvatarModelWidget(model, size: size!),
    );

  }
}
