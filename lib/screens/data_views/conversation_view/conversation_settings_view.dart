import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';
import 'package:numberpicker/numberpicker.dart';

class ConversationSettingsView extends StatefulWidget {
  const ConversationSettingsView({Key? key}) : super(key: key);

  static const String id = 'conversation_settings_view';

  static navigate(String contactUid) {
    Navigator.pushNamed(
        NavigationService.context,
        ConversationSettingsView.id,
        arguments: contactUid
    );
  }

  @override
  State<ConversationSettingsView> createState() => _ConversationSettingsViewState();
}

class _ConversationSettingsViewState extends State<ConversationSettingsView> {

  int _timeToLiveDays = 0;
  int _timeToLiveHours = 0;
  int _timeToLiveMinutes = 0;
  int _limitMinTimeToLiveMinutes = 0;

  int _timeToAfterReadLiveDays = 0;
  int _timeToAfterReadLiveHours = 0;
  int _timeToAfterReadLiveMinutes = 0;
  int _limitMinTimeToLiveAfterReadMinutes = 0;


  late String _contactUid;

  onSave() {

    print(_contactUid);
  }

  onSetDefault() {
    setState(setDefault);
  }

  setDefault() {
    ConversationSettings.timeToLiveInMinutesDefault;
    _timeToLiveDays = ConversationSettings.timeToLiveInMinutesDefault ~/ (60 * 24);
    _timeToLiveHours = 0;
    _timeToLiveMinutes = 0;

    _timeToAfterReadLiveDays = ConversationSettings.timeToLiveAfterReadInMinutesDefault ~/ (60 * 24);
    _timeToAfterReadLiveHours = 0;
    _timeToAfterReadLiveMinutes = 0;
  }

  _checkTimeToLiveMin() {
    if (_timeToLiveDays == 0 && _timeToLiveHours == 0) {
      if (_timeToLiveMinutes == 0) _timeToLiveMinutes = 10;
      _limitMinTimeToLiveMinutes = 10;
    } else {
      _limitMinTimeToLiveMinutes = 0;
    }
  }

  _checkTimeToLiveAfterReadMin() {
    if (_timeToAfterReadLiveDays == 0 && _timeToAfterReadLiveHours == 0) {
      if (_timeToAfterReadLiveMinutes == 0) _timeToAfterReadLiveMinutes = 10;
      _limitMinTimeToLiveAfterReadMinutes = 10;
    } else {
      _limitMinTimeToLiveAfterReadMinutes = 0;
    }
  }


  @override
  void initState() {
    setDefault();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _contactUid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(

      appBar: AppBar(title: const Text('Conversation settings')),

      body: ListView(
        padding: BASIC_HORIZONTAL_PADDING,
        children: [

          const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text('Time to live:', textAlign: TextAlign.center ,style: TextStyle(
              fontSize: 20,
            )),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  NumberPicker(
                    value: _timeToLiveDays,
                    minValue: 0,
                    maxValue: 30,
                    onChanged: (v) => setState(() {
                      _timeToLiveDays = v;
                      _checkTimeToLiveMin();
                    }),
                  ),
                  const Text('Days', style: TextStyle(color: Colors.black54)),
                ]),
              Column(
                children: [
                  NumberPicker(
                    value: _timeToLiveHours,
                    minValue: 0,
                    maxValue: 23,
                    onChanged: (v) => setState(() {
                      _timeToLiveHours = v;
                      _checkTimeToLiveMin();
                    }),
                  ),
                  const Text('Hours', style: TextStyle(color: Colors.black54)),
                ]),
              Column(
                children: [
                  NumberPicker(
                    value: _timeToLiveMinutes,
                    minValue: _limitMinTimeToLiveMinutes,
                    maxValue: 50,
                    step: 10,
                    onChanged: (v) => setState(() => _timeToLiveMinutes = v),
                  ),
                  const Text('Minutes', style: TextStyle(color: Colors.black54)),
                ],
              )
          ]),

          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text('Time to live after read:', textAlign: TextAlign.center ,style: TextStyle(
              fontSize: 20,
            )),
          ),

          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                    children: [
                      NumberPicker(
                        value: _timeToAfterReadLiveDays,
                        minValue: 0,
                        maxValue: 7,
                        onChanged: (v) => setState(() {
                          _timeToAfterReadLiveDays = v;
                          _checkTimeToLiveAfterReadMin();
                        }),
                      ),
                      const Text('Days', style: TextStyle(color: Colors.black54)),
                    ]),
                Column(
                    children: [
                      NumberPicker(
                        value: _timeToAfterReadLiveHours,
                        minValue: 0,
                        maxValue: 23,
                        onChanged: (v) => setState(() {
                          _timeToAfterReadLiveHours = v;
                          _checkTimeToLiveAfterReadMin();
                        }),
                      ),
                      const Text('Hours', style: TextStyle(color: Colors.black54)),
                    ]),
                Column(
                  children: [
                    NumberPicker(
                      value: _timeToAfterReadLiveMinutes,
                      minValue: _limitMinTimeToLiveAfterReadMinutes,
                      maxValue: 50,
                      step: 10,
                      onChanged: (v) => setState(() => _timeToAfterReadLiveMinutes = v),
                    ),
                    const Text('Minutes', style: TextStyle(color: Colors.black54)),
                  ],
                )
              ]),

          PpButton(text: 'SAVE',
              onPressed: onSave,
          ),

          PpButton(text: 'Set default',
              color: Colors.green,
              onPressed: onSetDefault,
          )

        ],
      )
    );
  }
}
