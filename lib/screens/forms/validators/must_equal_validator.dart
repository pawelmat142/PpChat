import 'package:reactive_forms/reactive_forms.dart';

class MustEqualValidator extends Validator {
  final String controlNameOne;
  final String controlNameTwo;

  const MustEqualValidator(this.controlNameOne, this.controlNameTwo);

  @override
  Map<String, dynamic>? validate(AbstractControl control) {
    if (control is FormGroup) {
      final formGroup = control;
      final controlOne = formGroup.control(controlNameOne);

      if (controlOne.value is String && controlOne.value.isNotEmpty) {
        final controlTwo = formGroup.control(controlNameTwo);

        if (controlOne.value != controlTwo.value) {

          controlTwo.setErrors({ 'mustEqual': true });
        } else {
          controlTwo.removeError('mustEqual');
        }
      }
    }
    return null;
  }
}
