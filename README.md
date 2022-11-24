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

### [011] firebase authentication - configuration and implementation
Firebase core initialization:
</br>`flutter pub add firebase_core`
</br>Firebase authentication initialization:
</br>`flutter pub add firebase_auth`
</br></br>

### [012] authentication error handling and spinner
Spinner UI component implemented what shows that something is loading. </br>
Logout option, log / logout navigation and error handling with popups.
</br></br>

### [013] user data model
basic user data model is prepared
</br> + little fix with form_styles and validators files moving
</br></br>

### [014] -||- fix
little fix with form_styles and validators files moving
</br></br>

### [015] -||- still fix moving files fix

### [016] firestore implementation - user service
cloud firestore example implementation
</br>`flutter pub add cloud_firestore`
</br> user service prepared, test screen to test first firestore requests
</br></br>

### [017] firestore - security rules
basic firebase security rules written
</br> little refactor what makes nickname equals user document id so nickname is unique
</br> 

### [018] firestore - security rules - continued
private sub collection created inside user what makes user modifiable only for owner
</br> additional rules added
</br> that makes user document modifiable only for owner
</br>

### [019] user service develop
findByNickname and delete methods

### [020] user and auth services integration
authentication system completed

### [021] contacts screen view prepared
contacts screen view, basic contact tile component

### [022] contact search option
contact finding UI process

### [023] notification data model
basic notification data model is prepared
</br> send invitation option
</br> basic notification security rules

### [024] Stream builder - notifications screen
notifications screen,
</br> notifications service,
</br> stream builder with notification tile implemented

### [025] State services refactor
services what keeps some user state refactored with login/logout triggering 
notifications screen refactor - no more stream builder
little screens refactors

### [026] Notification tile
Made with stream listener notification tile shows notifications number

### [027] Notification flushbar
`flutter pub add another_flushbar`
</br> flushbar notifications implementation

### [028] Invitation view
notification view - mark as read when open

### [029] Stream broadcast - notifications screen
multiple stream usage example with widget building and storage listening
</br> Refactor notifications service and screen to make screen reactive

### [030] Notification flushbar tap
navigate to notification view if tap flushbar

### [031] Notifications screen sort
unread notifications are on the top of notifications screen

### [032] Self notification
sending invitation triggers invitation self notification what is read by default

### [033] Widget class extension example
refactor notification view and create invitation view as extension

### [034] Factory project pattern
Invitation self notification view with factory pattern implemented

### [035] UX improvements and invitation reject feature
reject / cancel invitation
</br> flushbar for invitation sent / deleted
</br> navigation to notifications from flushbar

### [036] Delete all notifications feature
notifications ale deleted also for senders

### [037] Delete account feature
delete account includes delete user and PRIVATE docs
</br> includes also delete all notifications also for senders
</br> adds record to DELETED_ACCOUNTS collection to show info about deleted account
</br> fireAuth account needs to be deleted manually

### [038] Contacts service
contacts service prepared and registered

### [039] Notifications refactor
notifications has sender and receiver properties now
new notification type - invitation acceptance

### [040] Invitation acceptance - receiver
Contacts as one document subcollection of User - list of nicknames
</br> security rules for CONTACTS subcollection - only owner
</br>receiver accept invitation = add to contacts sender nickname
</br>invitation acceptance view added

### [041] Invitation acceptance - sender
sender get invitationAcceptance = add to contacts receiver nickname - only if not read
</br> invitation acceptance flushbar

### [042] Contacts screen and service develop
reactive contacts screen
</br> service stores each user subscription
</br> any change sets state to contacts screen

### [043] Contact tile develop
contact tile shows if user is logged or not
</br> contact view added as data view extension
</br> contact tiles sorting - logged first

### [044] Delete contact feature
new notification type - contactDeletedNotification - has no view
</br> is sent to receiver when sender deletes contact
</br> and automatically deletes contact for receiver if logged or when login

### [045] Sww popup, delete all contacts

### [046] Navigator improvements and delete single notification feature

### [047] small todos cleanup