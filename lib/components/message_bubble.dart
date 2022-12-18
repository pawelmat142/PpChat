import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool my;

  const MessageBubble({
    required this.message,
    required this.my,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: my ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [

          /// message bubble
          Material(
            color: my ? PRIMARY_COLOR_LIGHTER : PRIMARY_COLOR_DARKER,
            borderRadius: my ? msgSenderBorder : msgBorder,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Text(message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

const double borderEdgeRadius = 5;
const double roundBorderRadius = 30;

const msgSenderBorder = BorderRadius.only(
  topRight: Radius.circular(roundBorderRadius),
  topLeft: Radius.circular(roundBorderRadius),
  bottomLeft: Radius.circular(roundBorderRadius),
  bottomRight: Radius.circular(borderEdgeRadius),
);

const msgBorder = BorderRadius.only(
  topRight: Radius.circular(roundBorderRadius),
  topLeft: Radius.circular(borderEdgeRadius),
  bottomLeft: Radius.circular(roundBorderRadius),
  bottomRight: Radius.circular(roundBorderRadius),
);


