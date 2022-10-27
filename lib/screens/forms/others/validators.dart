import 'package:reactive_forms/reactive_forms.dart';

ValidatorFunction myMustMatch(String controlName, String matchingControlName) {
  return (AbstractControl<dynamic> control) {
    final form = control as FormGroup;

    final formControl = form.control(controlName);
    final matchingFormControl = form.control(matchingControlName);

    if (formControl.value != matchingFormControl.value) {
      matchingFormControl.setErrors({'mustMatch': true});

      if (matchingFormControl.value != null
          && formControl.value != null
          && matchingFormControl.value.length >= formControl.value.length) {
        // force messages to show up as soon as possible
        matchingFormControl.markAsTouched();
      }

    } else {
      matchingFormControl.removeError('mustMatch');
    }

    return null;
  };
}