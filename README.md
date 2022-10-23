# flutter_chat_app

This project is meant to be an example of building my flutter application step by step. Each commit will be a documentation of expanding the application with next feature.
</br></br>

## Commits

### [000] initial commit - blank Flutter app
As blank app as possible Flutter application.
</br></br>

### [001] routing and navigation
Added screens directory, two Scaffold screens as stateless widgets and routing in main file.
</br></br>

### [002] custom button widget - styles constants
Added styles files with constant values and custom button widget with configurable styles but default set by constants.
</br></br>

### [003] login form screen - reactive form
Added reactive form package, custom text field widget, login form screen.
</br>`flutter pub add reactive_forms`
</br></br>

### [004] basic reactive form validators
Added basic reactive form validators and error messages to text fields.
</br></br>

### [005] animation, stream, stateful controllable button widget
Added animation what changes color, used in controllable stateful widget with stream usage example.
</br></br>

### [006] reactive form submit made with controllable button widget
Submit button added to reactive form what automatically activates / deactivates when form is valid / invalid.
</br></br>

### [007] register page
Register page, navigate button with new color and form submit methods added.
</br></br>

### [008] custom form validation - must match
Added must match custom validation to register form and error messages also.
</br></br>

### [009] getIt - dependency injection package
Authentication service template as dependency injection example made with getIt package.
</br>`flutter pub add get_it`
</br></br>

### [010] alert / popup, navigation service
Implementation reusable and configurable UI popup component and navigation service what provides current BuildContext at any place in the application.</br>
Popup used in registration / login methods, injected as lazy singleton by getIt.
</br></br>