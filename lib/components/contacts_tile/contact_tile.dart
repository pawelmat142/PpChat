import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/tile_divider.dart';
import 'package:flutter_chat_app/models/user/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/components/contacts_tile/unread_messages.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/models/conversation/conversation_service.dart';

class ContactTile extends StatelessWidget {
  final PpUser contactUser;
  const ContactTile(this.contactUser, {super.key});


  _navigateToConversationView() {
    final conversationService = getIt.get<ConversationService>();
    conversationService.navigateToConversationView(contactUser);
  }

  _navigateToContactView() {
    UserView.navigate(user: contactUser);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _navigateToConversationView,

      child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TILE_PADDING_HORIZONTAL, vertical: TILE_PADDING_VERTICAL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ///LEFT side of tile
                  Row(
                    children: [
                      InkWell(
                          onTap: _navigateToContactView,
                          child: AvatarWidget(
                            uid: contactUser.uid,
                            model: contactUser.avatar,
                          )),

                      Content(nickname: contactUser.nickname, text: contactUser.role),
                    ],
                  ),

                  ///RIGHT side of tile
                  Row (
                    children: [

                      UnreadMessages(contactUid: contactUser.uid),

                      Padding(
                        padding: const EdgeInsets.only(right: TILE_PADDING_HORIZONTAL),
                        child: Icon(contactUser.logged ? Icons.person_rounded : Icons.person_off_outlined,
                          size: 35,
                          color: contactUser.logged ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            const TileDivider(),

          ]

      ),
    );
  }
}

class Content extends StatelessWidget {
  final String nickname;
  final String text;
  const Content({Key? key, required this.nickname, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TILE_PADDING_HORIZONTAL*2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(nickname, style: const TextStyle(
              fontSize: 18,
              color: PRIMARY_COLOR_DARKER,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5
          )),

          const SizedBox(height: 4),

          Text(text, style: const TextStyle(
            fontSize: 15,
            color: PRIMARY_COLOR_LIGHTER,
          )),

        ],
      ),
    );
  }
}