import 'dart:io';

import 'package:flutter/material.dart';
// TODO: colors pallette on edit view as slider!
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(
            color: Colors.black87.withOpacity(0.5),
            spreadRadius: size/50,
            blurRadius: size/30,
            offset: Offset(0, size/50))],
      ),
      child: CircleAvatar(
        radius: size/2,
        backgroundColor: Colors.transparent,
        child: ClipOval(child: Image.file(file,
            fit: BoxFit.cover,
            width: size,
            height: size,
        )),
      ),
    );


  }
}
