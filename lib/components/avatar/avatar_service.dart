import 'dart:math';

import 'package:flutter/material.dart';

class AvatarService {

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
      .toList()[Random().nextInt(colorsPalette.length + 1)];
  
  static Color get randomColor => colorsPalette[randomColorKey]!;

  static Color getColor(String key) => colorsPalette[key]!;

  AvatarModel getRandomAvatar({required String userNickname}) {
    return AvatarModel(color: randomColorKey, txt: userNickname[0]);
  }


}

class AvatarModel {
  String color;
  String txt;
  String? url;

  AvatarModel({
    required this.color,
    required this.txt
  });

  // get asMap {
  //   final result = {
  //     'color': color,
  //     'txt': txt
  //   };
  //   if (url != null) {
  //     result['url'] = url!;
  //   }
  //   return result;
  // }

}