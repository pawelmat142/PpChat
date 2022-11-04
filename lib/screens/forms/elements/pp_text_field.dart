import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/forms/others/form_styles.dart';
import 'package:reactive_forms/reactive_forms.dart';

class PpTextField extends StatelessWidget {
  final String fieldName;
  final String labelHint;
  final Function? onSubmitted;
  final bool passwordMode;
  final String requiredMsg;
  final String minLengthMsg;
  final String mustMatchMsg;
  const PpTextField({
    super.key,
    required this.fieldName,
    required this.labelHint,
    this.onSubmitted,
    this.passwordMode = false,
    this.requiredMsg = 'Field is required.',
    this.minLengthMsg = 'Too short!',
    this.mustMatchMsg = 'Must match!',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: primaryButtonPadding,
      child: ReactiveTextField(
        formControlName: fieldName,
        textAlign: TextAlign.center,
        showErrors: (control) => control.invalid && control.touched && control.dirty,
        decoration: InputDecoration(
          labelText: labelHint,
          floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        obscureText: passwordMode,
        textInputAction: TextInputAction.next,
        onSubmitted: onSubmitted != null ? (x) => onSubmitted!() : (x){},
        validationMessages: {
          'required': (error) => requiredMsg,
          'minLength': (error) => minLengthMsg,
          'mustMatch': (error) => mustMatchMsg,
        },
      ),
    );
  }
}






