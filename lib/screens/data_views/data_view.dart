import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:flutter_chat_app/constants/styles.dart';

class DataViewInterface {
  final String title;
  final String? textOne;
  final String? textTwo;
  final String? textThree;
  final String? textThreePrefix;
  final List<Widget> buttons;

  const DataViewInterface({
    this.title = 'initial title',
    this.textOne,
    this.textTwo,
    this.textThree,
    this.textThreePrefix,
    this.buttons = const [],
  });
}

class DataView extends StatelessWidget {

  static navigate({DataViewInterface? interface}) {
    Navigator.push(
      NavigationService.context,
      MaterialPageRoute(builder: (context) => DataView(interface: interface ?? const DataViewInterface()))
    );
  }

  final DataViewInterface interface;

  const DataView({
    required this.interface,
    super.key
  });

  getTextOneWidget() {
    if (interface.textOne != null) {
      return Text(interface.textOne!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 30,
          color: PRIMARY_COLOR_DARKER,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  getTextTwoWidget() {
    if (interface.textTwo != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(interface.textTwo!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            letterSpacing: 0.8,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  getTextThreeWidget() {
    if (interface.textThree != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 20),
        child: RichText(text: TextSpan(children: [
          TextSpan(text: '${interface.textThreePrefix!}: ', style: const TextStyle(fontSize: 16, color: PRIMARY_COLOR_LIGHTER)),
          TextSpan(text: interface.textThree, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ])),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text(interface.title)),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              //AVATAR
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle
                  ),
                ),
              ),

              //NICKNAME
              getTextOneWidget(),

              getTextTwoWidget(),

              const SizedBox(height: 12),

              //MESSAGE
              getTextThreeWidget(),

              //BUTTONS
              Column(children: interface.buttons)

            ]),
      ),
    );
  }
}
