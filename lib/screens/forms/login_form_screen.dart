import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class Fields {
  static const String login = 'login';
  static const String password = 'password';
}

class LoginFormScreen extends StatelessWidget {
  LoginFormScreen({super.key});
  static const String id = 'login_form_screen';


  final form = FormGroup({
    Fields.login: FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
    Fields.password: FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('LOGIN'),
      ),

      body: ReactiveForm(
        formGroup: form,
        child: ListView(
          padding: BASIC_HORIZONTAL_PADDING,
          children: [

            PpTextField(
                fieldName: Fields.login,
                labelHint: 'LOGIN',
                requiredMsg: 'Login is required.',
                minLengthMsg: 'Login must have at least 6 characters',
                onSubmitted: () => form.focus(Fields.password)
            ),

            PpTextField(
              fieldName: Fields.password,
              labelHint: 'PASSWORD',
              requiredMsg: 'Password is required.',
              minLengthMsg: 'Password must have at least 6 characters',
              passwordMode: true,
            ),

          ],
        ),

      ),
    );
  }
}