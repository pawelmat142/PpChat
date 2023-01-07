import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_from_model.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_image_widget.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_model.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_service.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    this.size = CONTACTS_AVATAR_SIZE,
    required this.model,
    this.pickedImageFile,
    required this.uid,
    Key? key
  }) : super(key: key);

  final double size;
  final AvatarModel model;
  final File? pickedImageFile;
  final String uid;

  @override
  Widget build(BuildContext context) {

    return pickedImageFile != null

      ? AvatarImageWidget(size: size, file: pickedImageFile!)

      : model.hasImage

        ? FutureBuilder<File?>(
            future: AvatarService.getImageFile(uid: uid, model: model),
            builder: (context, snapshot) {
              final imageFile = snapshot.data;

              return imageFile == null
                ? AvatarFromModel(model, size: size)
                : AvatarImageWidget(size: size, file: imageFile);
            }
          )
        : AvatarFromModel(model, size: size);

  }
}
