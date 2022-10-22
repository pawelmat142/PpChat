import 'package:flutter/material.dart';
import 'package:flutter_chat_app/config/getIt.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_submit.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_text_field.dart';
import 'package:flutter_chat_app/screens/forms/validators.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class Fields {
  static const String login = 'login';
  static const String relogin = 'relogin';
  static const String password = 'password';
  static const String repassword = 'repassword';
}

class RegisterFormScreen extends StatelessWidget {
  RegisterFormScreen({super.key});
  static const String id = 'register_form_screen';

  final _authService = getIt.get<AuthenticationService>();

  final form = FormGroup({
    Fields.login: FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
    Fields.relogin: FormControl<String>(),
    Fields.password: FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
    Fields.repassword: FormControl<String>(),
  }, validators: [
    myMustMatch(Fields.login, Fields.relogin),
    myMustMatch(Fields.password, Fields.repassword)
  ]);

  void _submitForm(BuildContext context) {
    if (form.valid) {
      _authService.register(
          login: form.control(Fields.login).value,
          password: form.control(Fields.password).value
      );
      form.reset();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('REGISTRATION'),
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
                onSubmitted: () => form.focus(Fields.relogin)
            ),

            PpTextField(
                fieldName: Fields.relogin,
                labelHint: 'REPEAT LOGIN',
                mustMatchMsg: 'Login must match.',
                onSubmitted: () => form.focus(Fields.password)
            ),

            PpTextField(
                fieldName: Fields.password,
                labelHint: 'PASSWORD',
                requiredMsg: 'Password is required.',
                minLengthMsg: 'Password must have at least 6 characters',
                passwordMode: true,
                onSubmitted: () => form.focus(Fields.repassword)
            ),

            PpTextField(
                fieldName: Fields.repassword,
                labelHint: 'REPEAT PASSWORD',
                mustMatchMsg: 'Password must match.',
                passwordMode: true,
                onSubmitted: () => _submitForm(context),
            ),

            PpFormSubmit(
                formStatusChanged: form.statusChanged,
                onSubmit: () => _submitForm(context),
            ),

          ],
        ),

      ),
    );
  }
}