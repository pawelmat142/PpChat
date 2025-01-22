import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/forms/validators/must_equal_validator.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_submit.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_text_field.dart';
import 'package:flutter_chat_app/services/authentication_service.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class Fields {
  static const String nickname = 'login';
  static const String renickname = 'relogin';
  static const String password = 'password';
  static const String repassword = 'repassword';
}

class RegisterFormScreen extends StatelessWidget {
  RegisterFormScreen({super.key});
  static const String id = 'register_form_screen';

  final _authService = getIt.get<AuthenticationService>();

  final form = FormGroup({
    Fields.nickname: FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
    Fields.renickname: FormControl<String>(),
    Fields.password: FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
    Fields.repassword: FormControl<String>(),
  }, validators: [
    MustEqualValidator(Fields.nickname, Fields.renickname),
    MustEqualValidator(Fields.password, Fields.repassword)
  ]);

  void _submitForm(BuildContext context) {
    if (form.valid) {
      _authService.register(context,
        nickname: form.control(Fields.nickname).value,
        password: form.control(Fields.password).value,
      );
      form.reset();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Registration'),
      ),

      body: ReactiveForm(
        formGroup: form,
        child: ListView(
          padding: BASIC_HORIZONTAL_PADDING,
          children: [

            PpTextField(
                fieldName: Fields.nickname,
                labelHint: 'Nickname',
                requiredMsg: 'Login is required.',
                minLengthMsg: 'Login must have at least 6 characters',
                onSubmitted: () => form.focus(Fields.renickname)
            ),

            PpTextField(
                fieldName: Fields.renickname,
                labelHint: 'Repeat nickname',
                mustEqualMsg: 'Repeat nickname must equal nickname',
                onSubmitted: () => form.focus(Fields.password)
            ),

            PpTextField(
                fieldName: Fields.password,
                labelHint: 'Password',
                requiredMsg: 'Password is required.',
                minLengthMsg: 'Password must have at least 6 characters',
                passwordMode: true,
                onSubmitted: () => form.focus(Fields.repassword)
            ),

            PpTextField(
                fieldName: Fields.repassword,
                labelHint: 'Repeat password',
                mustEqualMsg: 'Repeat password must equal password',
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