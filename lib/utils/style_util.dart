import 'package:flutter/material.dart';
import 'package:flutter_chat_app/dialogs/popup.dart';

import '../services/navigation_service.dart';

abstract class StyleUtil {

  static btnColor(PopupButton btn) {
    if (btn.color != null) {
      return btn.color;
    }
    if (btn.error) {
      return Theme.of(NavigationService.context).colorScheme.error;
    }
    return Theme.of(NavigationService.context).primaryColor;
  }

}