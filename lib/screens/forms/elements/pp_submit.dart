import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button_controllable.dart';
import 'package:reactive_forms/reactive_forms.dart';

class PpFormSubmit extends StatelessWidget {
  /// EXPECTS: form.statusChanged (reactive form)
  final Stream formStatusChanged;
  final Function onSubmit;
  final String text;
  final bool initActive;
  const PpFormSubmit({
    super.key,
    required this.formStatusChanged,
    required this.onSubmit,
    this.text = 'Submit',
    this.initActive = false,
  });

  @override
  Widget build(BuildContext context) {

    bool isValid = initActive;

    PpButtonControllable button = PpButtonControllable(
      onPressed: onSubmit,
      controllable: true,
      text: text,
      active: initActive,
    );

    formStatusChanged.listen((status) {
      if (isValid && status == ControlStatus.invalid) {
        button.deactivation();
        isValid = false;
      } else if (!isValid && status == ControlStatus.valid) {
        button.activation();
        isValid = true;
      }
    });

    return button;
  }
}
