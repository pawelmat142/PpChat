import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

import '../utils/style_util.dart';

class PopupButton {
  final Function? onPressed;
  final String text;
  final Color? color;
  final bool error;
  final bool preventPop;
  final bool bold;
  PopupButton(this.text, {
    this.onPressed,
    this.color,
    this.error = false,
    this.preventPop = false,
    this.bold = true,
  });
}

class Popup {
  static defaultPopAction() {
    Navigator.of(NavigationService.context).pop();
  }
  static final PopupButton defaultButton = PopupButton('Close', bold: false);
  static final PopupButton okButton = PopupButton('OK', bold: false);
  static final PopupButton navigateBackButton = PopupButton('Back', onPressed: defaultPopAction, error: true, bold: false);

  int openPopups = 0;

  List<Widget> _getButtonsWidgets(List<PopupButton> buttons, Function? defaultAction) {
    return buttons.map((btn) => TextButton(
      onPressed: () {
        if (!btn.preventPop) defaultPopAction();
        if (btn.onPressed != null) {
          btn.onPressed!();
        } else if (defaultAction != null && buttons[buttons.length - 1] == btn) {
          defaultAction();
        }
      },
      child: Text(
        btn.text,
        style: TextStyle(
            fontWeight: btn.bold || buttons[buttons.length - 1] == btn ? FontWeight.w800 : FontWeight.w500,
            color: StyleUtil.btnColor(btn)
        ),
      ),
    )).toList();
  }

  Future show(String title, {
    String? text,
    bool error = false,
    bool enableDefaultButton = true,
    bool enableNavigateBack = false,
    bool enableOkButton = false,
    Color textColor = Colors.black87,
    List<PopupButton>? buttons,
    Function? defaultAction,
    Widget? content,
    int? delay
  }) async {

    List<PopupButton> $buttons = buttons ?? [];
    $buttons = enableOkButton ? [okButton] + $buttons : $buttons;
    $buttons = enableDefaultButton ? [defaultButton] + $buttons : $buttons;
    $buttons = enableNavigateBack ? [navigateBackButton] + $buttons : $buttons;

    openPopups++;

    if (delay != null) {
      await Future.delayed(Duration(milliseconds: delay));
    }

    return showDialog(
      context: NavigationService.context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: TextStyle(
                color: error
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).primaryColorDark)
            ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text == null
                ? const SizedBox(height: 0, width: 0)
                : Text(text, style: TextStyle(color: textColor)),

            content ?? const SizedBox(height: 0, width: 0)

          ],
        ),
        actions: _getButtonsWidgets($buttons, defaultAction),
      ),
    ).then((value) => openPopups--);
  }

  closeAll() {
    final openPopupsLocal = openPopups;
    for(int i = 0; i < openPopupsLocal; i++) {
      closeOne();
    }
  }

  closeOne() {
    if (openPopups > 0) {
      defaultPopAction();
    }
  }

  sww({String? text}) {
    show('Something went wrong! :(', error: true, content: text != null ? Text(text) : null);
  }

}
