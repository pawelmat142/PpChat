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
      height: size,
      width: size,
      decoration: BoxDecoration(
          color: colorFromModel,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorFromModel.withOpacity(0.5),
              spreadRadius: size/50,
              blurRadius: size/30,
              offset: Offset(0, size/50),
            )
          ]
      ),
      child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: size/6),
            child: Text(model.txt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AvatarService.avatarFont,
                  fontSize: size/3*2,
                  color: WHITE_COLOR,
                ),
            ),
          )
      ),
    );
  }
}
