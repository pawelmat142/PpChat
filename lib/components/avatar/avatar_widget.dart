import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/avatar/avatar_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    this.size = CONTACTS_AVATAR_SIZE,
    Key? key
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CONTACTS_AVATAR_SIZE,
      width: CONTACTS_AVATAR_SIZE,
      decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle
      ),
      child: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: CONTACTS_AVATAR_SIZE/6),
            child: Text('A',
                textAlign: TextAlign.center,
                style: TextStyle(
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
