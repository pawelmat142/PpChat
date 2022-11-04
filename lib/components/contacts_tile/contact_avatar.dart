import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CONTACTS_AVATAR_SIZE,
      width: CONTACTS_AVATAR_SIZE,
      decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle
      ),
    );
  }
}
