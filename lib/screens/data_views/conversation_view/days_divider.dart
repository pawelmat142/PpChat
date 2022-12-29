import 'package:flutter/material.dart';

class DaysDivider extends StatelessWidget {
  final String date;
  const DaysDivider({required this.date, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(date, style: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
      ),
        ),
    );
  }
}
