import 'package:flutter_chat_app/screens/data_screens/notification_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';

class InvitationSelfNotificationView extends NotificationView {
  InvitationSelfNotificationView(super.notification, {super.key});

  //TODO: delete notification button
  //TODO: something is wrong here - lets have a look
  @override
  get title => 'YOUR INVITATION';

  @override
  get content => 'You sent an invitation!';

  @override
  get buttons {
    return [
      PpButton(text: 'CANCEL', onPressed: () async {
        await super.notificationService.deleteInvitation(super.notification);
      })
    ];
  }


}