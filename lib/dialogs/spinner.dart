import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

class PpSpinner {

  get context => NavigationService.context;

  bool _spinning = false;

  // this is where you would do your fullscreen loading
  void start() async {
    _spinning = true;
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent, // can change this to your prefered color
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        );
      },
    );
  }

  void stop() {
    if (_spinning) {
      Navigator.of(context).pop();
      _spinning = false;
    }
  }

}