import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationAcceptanceView extends NotificationView {
  InvitationAcceptanceView(super.notification, {super.key});

  @override
  get title => 'INVITATION ACCEPTANCE';

  @override
  get content => 'Accepted your invitation!';

  @override
  get buttons {
    return [

      PpButton(text: 'SHOW', onPressed: () {
        //TODO: navigate to contacts from any place
        print('TODO: NAVIGATE');
      }),

      PpButton(text: 'Write message', onPressed: () {
        //TODO: navigate to message
        print('TODO: message');
      }),

    ];
  }

//  TODO: delete notification on leave

}