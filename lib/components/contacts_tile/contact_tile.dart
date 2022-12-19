import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/contacts_tile/contact_avatar.dart';
import 'package:flutter_chat_app/config/get_it.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/services/conversation_service.dart';

class ContactTile extends StatelessWidget {
  final PpUser contactUser;
  const ContactTile(this.contactUser, {super.key});


  _navigateToConversationView() {
    final conversationService = getIt.get<ConversationService>();
    conversationService.navigateToConversationView(contactUser);
  }

  _navigateToContactView() {
    UserView.navigate(contactUser);
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

                  Row(
                    children: [
                      InkWell(onTap: _navigateToContactView, child: const ContactAvatar()),

                      Content(nickname: contactUser.nickname, text: contactUser.role),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: TILE_PADDING_VERTICAL),
                    child: Icon(Icons.message,
                        size: 35,
                        color: contactUser.logged ? Colors.green : Colors.red,
                      ),
                  ),

                ],
              ),
            ),

            const Divider(
              thickness: 1,
              color: Colors.grey,
              endIndent: TILE_PADDING_HORIZONTAL,
              indent: TILE_PADDING_HORIZONTAL * 3 + CONTACTS_AVATAR_SIZE,
            ),
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