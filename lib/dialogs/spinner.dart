import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

class PpSpinner {

  get getContext => NavigationService.context;

  bool _spinning = false;

  // this is where you would do your fullscreen loading
  void start({BuildContext? context}) async {
    _spinning = true;
    return await showDialog<void>(
      context: context ?? getContext,
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

  void stop({BuildContext? context}) {
    if (_spinning) {
      Navigator.of(context ?? getContext).pop();
      _spinning = false;
    }
  }

}