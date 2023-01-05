import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/services/get_it.dart';
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

  final conversationSettingsService = getIt.get<ConversationSettingsService>();
  final spinner = getIt.get<PpSpinner>();

  late int _timeToLiveDays;
  late int _timeToLiveHours;
  late int _timeToLiveMinutes;
  late int _limitMinTimeToLiveMinutes;
  late int _limitMaxTimeToLiveMinutes;
  late int _limitMaxTimeToLiveHours;

  late int _timeToLiveAfterReadDays;
  late int _timeToLiveAfterReadHours;
  late int _timeToLiveAfterReadMinutes;
  late int _limitMinTimeToLiveAfterReadMinutes;
  late int _limitMaxTimeToLiveAfterReadMinutes;
  late int _limitMaxTimeToLiveAfterReadHours;

  late String _contactUid;

  int get getTimeToLiveInMinutes => (((_timeToLiveDays * 24) + _timeToLiveHours) * 60) + _timeToLiveMinutes;
  int get getTimeToLiveAfterReadInMinutes => (((_timeToLiveAfterReadDays * 24) + _timeToLiveAfterReadHours) * 60) + _timeToLiveAfterReadMinutes;

  onSave() async {
    try {
      spinner.start();
      final settings = ConversationSettings.create(
          contactUid: _contactUid,
          timeToLive: getTimeToLiveInMinutes,
          timeToLiveAfterRead: getTimeToLiveAfterReadInMinutes
      );
      await conversationSettingsService.saveSettings(settings);
      spinner.stop();
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
      });
    } catch(e) {
      spinner.stop();
    }
  }

  onSetDefault() {
    setState(setDefault);
  }

  setDefault() {
    _timeToLiveDays = ConversationSettings.timeToLiveInMinutesDefault ~/ (60 * 24);
    _timeToLiveHours = 0;
    _timeToLiveMinutes = 0;
    _limitMinTimeToLiveMinutes = 0;
    _limitMaxTimeToLiveMinutes = 50;
    _limitMaxTimeToLiveHours = 23;

    _timeToLiveAfterReadDays = ConversationSettings.timeToLiveAfterReadInMinutesDefault ~/ (60 * 24);
    _timeToLiveAfterReadHours = 0;
    _timeToLiveAfterReadMinutes = 0;
    _limitMinTimeToLiveAfterReadMinutes = 0;
    _limitMaxTimeToLiveAfterReadMinutes = 50;
    _limitMaxTimeToLiveAfterReadHours = 23;
  }

  _checkLimitMinTimeToLive() {
    if (_timeToLiveDays == 0 && _timeToLiveHours == 0) {
      if (_timeToLiveMinutes == 0) _timeToLiveMinutes = 10;
      _limitMinTimeToLiveMinutes = 10;
    } else {
      _limitMinTimeToLiveMinutes = 0;
    }
  }

  _checkLimitMaxTimeToLive() {
    if (getTimeToLiveInMinutes >= ConversationSettings.timeToLiveMax) {
      _timeToLiveHours = 0;
      _timeToLiveMinutes = 0;
      _limitMaxTimeToLiveHours = 0;
      _limitMaxTimeToLiveMinutes = 0;
    } else {
      _limitMaxTimeToLiveHours = 24;
      _limitMaxTimeToLiveMinutes = 50;
    }
  }

  _checkLimitMinTimeToLiveAfterRead() {
    if (_timeToLiveAfterReadDays == 0 && _timeToLiveAfterReadHours == 0) {
      if (_timeToLiveAfterReadMinutes == 0) _timeToLiveAfterReadMinutes = 10;
      _limitMinTimeToLiveAfterReadMinutes = 10;
    } else {
      _limitMinTimeToLiveAfterReadMinutes = 0;
    }
  }

  _checkLimitMaxTimeToLiveAfterRead() {
    if (getTimeToLiveAfterReadInMinutes >= ConversationSettings.timeToLiveAfterReadMax) {
      _timeToLiveAfterReadHours = 0;
      _timeToLiveAfterReadMinutes = 0;
      _limitMaxTimeToLiveAfterReadHours = 0;
      _limitMaxTimeToLiveAfterReadMinutes = 0;
    } else {
      _limitMaxTimeToLiveAfterReadHours = 24;
      _limitMaxTimeToLiveAfterReadMinutes = 50;
    }
  }


  @override
  void initState() {
    setDefault();
    super.initState();
    initSettings();
  }

  initSettings() {
    Future.delayed(Duration.zero, () async {
      await setStateFromSettings();
      Future.delayed(Duration.zero, () async{
        await setStateFromSettings();
      });
    });
  }

  setStateFromSettings() async {
    // if (_contactUid == null) return;
    final settings = await conversationSettingsService.getSettings(contactUid: _contactUid);
    setState(() {
      _timeToLiveDays = settings.timeToLiveInMinutes ~/ (60 * 24);
      _timeToLiveHours = (settings.timeToLiveInMinutes - (_timeToLiveDays * 60 * 24)) ~/ 60;
      _timeToLiveMinutes = settings.timeToLiveInMinutes - (_timeToLiveDays * 60 * 24) - (_timeToLiveHours * 60);

      _timeToLiveAfterReadDays = settings.timeToLiveAfterReadInMinutes ~/ (60 * 24);
      _timeToLiveAfterReadHours = (settings.timeToLiveAfterReadInMinutes - (_timeToLiveAfterReadDays * 60 * 24)) ~/ 60;
      _timeToLiveAfterReadMinutes = settings.timeToLiveAfterReadInMinutes - (_timeToLiveAfterReadDays * 60 * 24) - (_timeToLiveAfterReadHours * 60);
    });
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
                      _checkLimitMinTimeToLive();
                      _checkLimitMaxTimeToLive();
                    }),
                  ),
                  const Text('Days', style: TextStyle(color: Colors.black54)),
                ]),
              Column(
                children: [
                  NumberPicker(
                    value: _timeToLiveHours,
                    minValue: 0,
                    maxValue: _limitMaxTimeToLiveHours,
                    onChanged: (v) => setState(() {
                      _timeToLiveHours = v;
                      _checkLimitMinTimeToLive();
                    }),
                  ),
                  const Text('Hours', style: TextStyle(color: Colors.black54)),
                ]),
              Column(
                children: [
                  NumberPicker(
                    value: _timeToLiveMinutes,
                    minValue: _limitMinTimeToLiveMinutes,
                    maxValue: _limitMaxTimeToLiveMinutes,
                    step: 10,
                    onChanged: (v) => setState(() {
                      _timeToLiveMinutes = v;
                    }),
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
                        value: _timeToLiveAfterReadDays,
                        minValue: 0,
                        maxValue: 7,
                        onChanged: (v) => setState(() {
                          _timeToLiveAfterReadDays = v;
                          _checkLimitMinTimeToLiveAfterRead();
                          _checkLimitMaxTimeToLiveAfterRead();
                        }),
                      ),
                      const Text('Days', style: TextStyle(color: Colors.black54)),
                    ]),
                Column(
                    children: [
                      NumberPicker(
                        value: _timeToLiveAfterReadHours,
                        minValue: 0,
                        maxValue: _limitMaxTimeToLiveAfterReadHours,
                        onChanged: (v) => setState(() {
                          _timeToLiveAfterReadHours = v;
                          _checkLimitMinTimeToLiveAfterRead();
                        }),
                      ),
                      const Text('Hours', style: TextStyle(color: Colors.black54)),
                    ]),
                Column(
                  children: [
                    NumberPicker(
                      value: _timeToLiveAfterReadMinutes,
                      minValue: _limitMinTimeToLiveAfterReadMinutes,
                      maxValue: _limitMaxTimeToLiveAfterReadMinutes,
                      step: 10,
                      onChanged: (v) => setState(() {
                        _timeToLiveAfterReadMinutes = v;
                      }),
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

// ignore: must_be_immutable
// class TimeInMinutesPicker extends StatefulWidget {
//   TimeInMinutesPicker({
//     required this.title,
//     required this.initialValue,
//     required this.minLimitMinutes,
//     required this.maxLimitMinutes,
//     Key? key}) : super(key: key) {
//     _state = initialValue;
//   }
//
//   final String title;
//   final int initialValue;
//   final int minLimitMinutes;
//   final int maxLimitMinutes;
//
//   late int _state;
//   int get state => _state;
//
//
//   set(int value) {
//     if (value < minLimitMinutes || value > maxLimitMinutes) {
//       throw Exception('[TimeMinutesPicker] set limit exceeded');
//     }
//     _state = value;
//   }
//
//   @override
//   State<TimeInMinutesPicker> createState() => _TimeInMinutesPickerState();
// }
//
// class _TimeInMinutesPickerState extends State<TimeInMinutesPicker> {
//
//   late int _days;
//   late int _hours;
//   late int _minutes;
//
//   late int _maxDays;
//   late int _minDays;
//   late int _maxHours;
//   late int _minHours;
//   late int _maxMinutes;
//   late int _minMinutes;
//
//   int get getTimeInMinutes => (((_days * 24) + _hours) * 60) + _minutes;
//
//   int get getMaxLimitDays => widget.maxLimitMinutes ~/ (60 * 24);
//   int get getMaxLimitHours => widget.maxLimitMinutes ~/ 60;
//
//   _onChangeDays(value) {
//
//     setState(() {
//
//     });
//   }
//
//   _onChangeHours(value) {
//     setState(() {
//
//     });
//   }
//
//   @override
//   void initState() {
//     setDefault();
//     super.initState();
//   }
//
//   setDefault() {
//     _maxDays = 30;
//     _minDays = 0;
//     _maxHours = 23;
//     _minHours = 0;
//     _maxMinutes = 50;
//     _minMinutes = 0;
//   }
//
//   int get getMinMinutesLimit => _days > 0 || _hours > 0 ? 0 : 10;
//   int get getMaxMinutesLimit =>  widget.maxLimitMinutes >= 50 ? 50 : widget.maxLimitMinutes;
//
//   int get getMinHoursLimit => widget.minLimitMinutes > 60 ?
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 15),
//           child: Text(widget.title, textAlign: TextAlign.center ,style: const TextStyle(
//             fontSize: 20,
//           )),
//         ),
//
//         Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//
//               getMaxLimitDays < 1 ? const SizedBox(width: 0) : Column(
//                   children: [
//                     NumberPicker(
//                       value: _days,
//                       minValue: _minDays,
//                       maxValue: _maxDays,
//                       onChanged: _onChangeDays
//                     ),
//                     const Text('Days', style: TextStyle(color: Colors.black54)),
//                   ]),
//
//               getMaxLimitHours < 1 ? const SizedBox(width: 0) : Column(
//                   children: [
//                     NumberPicker(
//                       value: _hours,
//                       minValue: _minHours,
//                       maxValue: _maxHours,
//                       onChanged: _onChangeHours
//                     ),
//                     const Text('Hours', style: TextStyle(color: Colors.black54)),
//                   ]),
//
//               Column(
//                 children: [
//                   NumberPicker(
//                     value: _minutes,
//                     minValue: _minMinutes,
//                     maxValue: _maxMinutes,
//                     step: 10,
//                     onChanged: (v) => setState(() {
//                       _minutes = v;
//                     }),
//                   ),
//                   const Text('Minutes', style: TextStyle(color: Colors.black54)),
//                 ],
//               )
//         ]),
//       ],
//     );
//   }
// }
