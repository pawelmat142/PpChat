import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/data_views/conversation_view/days_divider.dart';
import 'package:intl/intl.dart';

class MessageBubbleInterface {
  final String message;
  final bool my;
  final DateTime timestamp;
  final DateTime readTimestamp;
  final int timeToLive;
  final int timeToLiveAfterRead;
  bool divider;
  MessageBubbleInterface({
    required this.message,
    required this.my,
    required this.timestamp,
    required this.readTimestamp,
    required this.timeToLive,
    required this.timeToLiveAfterRead,
    this.divider = false
  });
}

class MessageBubble extends StatefulWidget {
  final MessageBubbleInterface interface;
  const MessageBubble({
    required this.interface,
    Key? key
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  MessageBubbleInterface get get => widget.interface;

  _onTap() {
    hidden = '$formattedTimestamp${_getDurationToExpireAsString(widget.interface)}';
    setState(() => showHidden = !showHidden);
  }

  String formattedTimestamp = '';
  String hidden = '';
  bool showHidden = false;

  String day = '';

  String? _getDurationToExpireAsString(MessageBubbleInterface m) {
    if (m.timeToLive == 0 && m.timeToLiveAfterRead == 0) {
      return null;
    }
    final a = m.timestamp.add(Duration(minutes: m.timeToLive)).difference(DateTime.now());
    final b = m.readTimestamp.add(Duration(minutes: m.timeToLiveAfterRead)).difference(DateTime.now());
    final duration = a.compareTo(b) < 0 ? a : b;
    if (duration.inDays > 0) return ' - (${duration.inDays} days left to expire)';
    if (duration.inHours > 0) return ' - (${duration.inHours} h left to expire)';
    if (duration.inMinutes > 0) return ' - (${duration.inMinutes} min left to expire)';
    return ' - (${duration.inSeconds} s left to expire)';
  }

  @override
  void initState() {
    formattedTimestamp = DateFormat('hh:mm').format(get.timestamp);
    if (get.divider) {
      day = DateFormat('MMMd').format(get.timestamp);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: _onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          crossAxisAlignment: get.my ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [

            /// days divider
            get.divider ? DaysDivider(date: day) : const SizedBox(height: 0),

            /// message bubble
            Material(
              color: get.my ? PRIMARY_COLOR_LIGHTER : PRIMARY_COLOR_DARKER,
              borderRadius: get.my ? msgSenderBorder : msgBorder,
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(get.message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17
                  ),
                ),
              ),
            ),

            /// timestamp
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              height: showHidden ? 15 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                scale: showHidden ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, top: 1),
                  child: Text(hidden, style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14
                  )),
                ),
              ),
            ),

          ],
        ),
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


