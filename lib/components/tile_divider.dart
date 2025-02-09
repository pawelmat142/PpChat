import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class TileDivider extends StatelessWidget {
  const TileDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 1,
      color: Colors.grey,
      endIndent: TILE_PADDING_HORIZONTAL,
      indent: TILE_PADDING_HORIZONTAL * 3 + AVATAR_SIZE,
    );
  }
}
