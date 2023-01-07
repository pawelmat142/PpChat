import 'dart:io';

import 'package:flutter/material.dart';

class AvatarImageWidget extends StatelessWidget {
  const AvatarImageWidget({
    required this.size,
    required this.file,
    Key? key
  }) : super(key: key);

  final double size;
  final File file;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size/2,
      backgroundColor: Colors.transparent,
      child: ClipOval(child: Image.file(file,
          fit: BoxFit.cover,
          width: size,
          height: size
      )),
    );
  }
}
