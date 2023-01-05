import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/avatar/avatar_model.dart';

class AvatarService {

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

}

