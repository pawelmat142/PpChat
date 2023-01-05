import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/avatar/avatar_model.dart';
import 'package:flutter_chat_app/components/avatar/avatar_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    this.size = CONTACTS_AVATAR_SIZE,
    required this.model,
    Key? key
  }) : super(key: key);

  final double size;
  final AvatarModel model;

  Color get colorFromModel => AvatarService.getColor(model.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CONTACTS_AVATAR_SIZE,
      width: CONTACTS_AVATAR_SIZE,
      decoration: BoxDecoration(
          color: colorFromModel,
          shape: BoxShape.circle
      ),
      child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: CONTACTS_AVATAR_SIZE/6),
            child: Text(model.txt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AvatarService.avatarFont,
                  fontSize: CONTACTS_AVATAR_SIZE/3*2,
                  color: WHITE_COLOR,
                ),
            ),
          )
      ),
    );
  }
}
