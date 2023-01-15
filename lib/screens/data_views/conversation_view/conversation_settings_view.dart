import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings.dart';
import 'package:flutter_chat_app/models/conversation/conversation_settings_service.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button_controllable.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

class ConversationSettingsView extends StatefulWidget {
  static const String id = 'conversation_settings_view';

  static navigate(String contactUid) {
    Navigator.pushNamed(
        NavigationService.context,
        ConversationSettingsView.id,
        arguments: contactUid
    );
  }
  const ConversationSettingsView({Key? key}) : super(key: key);

  @override
  State<ConversationSettingsView> createState() => _ConversationSettingsViewState();
}

class _ConversationSettingsViewState extends State<ConversationSettingsView> {

  static const Map<String, int> options = {
    'disabled': 0,
    '1 minute': 1,
    '5 minutes': 5,
    '15 minutes': 15,
    '30 minutes': 30,
    '1 hour': 60,
    '6 hour': 360,
    '12 hours': 720,
    '1 day': 1440,
    '3 days': 4320,
    '1 week': 10080,
    '1 month': 43200,
  };

  static String get getDefaultTimeToLive => options.keys
      .firstWhere((key) => options[key] == ConversationSettings.timeToLiveInMinutesDefault);

  static String get getDefaultTimeToLiveAfterRead => options.keys
      .firstWhere((key) => options[key] == ConversationSettings.timeToLiveAfterReadInMinutesDefault);

  final conversationSettingsService = getIt.get<ConversationSettingsService>();
  final spinner = getIt.get<PpSpinner>();

  String? contactUid;

  bool _autoDeleteEnabled = true;
  String _selectedTimeToLive = getDefaultTimeToLive;
  String _selectedTimeToLiveAfterRead = getDefaultTimeToLiveAfterRead;

  late ConversationSettings currentSettingsState;
  PpButtonControllable? saveButton;
  bool initialized = false;

  setDefault() {
    _autoDeleteEnabled = true;
    _selectedTimeToLive = getDefaultTimeToLive;
    _selectedTimeToLiveAfterRead = getDefaultTimeToLiveAfterRead;
  }
  setDefaultState() => setState(() {
    setDefault();
    checkIfHasChanges();
  });

  void checkIfHasChanges() {
    if (saveButton == null) return;
    options[_selectedTimeToLiveAfterRead] ==
          currentSettingsState.timeToLiveAfterReadInMinutes
          && options[_selectedTimeToLive] ==
              currentSettingsState.timeToLiveInMinutes
    ? saveButton!.deactivation()
    : saveButton!.activation();
  }

  _onSave() async {
    try {
      spinner.start();
      final settings = ConversationSettings.create(
        contactUid: contactUid!,
        timeToLive: options[_selectedTimeToLive]!,
        timeToLiveAfterRead: options[_selectedTimeToLiveAfterRead]!,
      );
      await conversationSettingsService.saveSettings(settings);
      spinner.stop();
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
        PpSnackBar.success();
      });
    } catch(e) {
      spinner.stop();
      PpSnackBar.error();
    }
  }


  @override
  void initState() {
    setDefault();
    saveButton = PpButtonControllable(text: 'SAVE',
      active: false,
      padding: const EdgeInsets.only(top: 40),
      color: PRIMARY_COLOR,
      onPressed: _onSave,
    );
    super.initState();

    Future.delayed(Duration.zero, () async {
      currentSettingsState = await conversationSettingsService.getSettings(contactUid: contactUid!);

      setState(() {
        _selectedTimeToLive = options.keys
            .firstWhere((key) => options[key] == currentSettingsState.timeToLiveInMinutes);

        _selectedTimeToLiveAfterRead = options.keys
            .firstWhere((key) => options[key] == currentSettingsState.timeToLiveAfterReadInMinutes);

        _autoDeleteEnabled = !(_selectedTimeToLive == 'disabled' && _selectedTimeToLiveAfterRead == 'disabled');

        checkIfHasChanges();
        initialized = true;
        // saveButton!.deactivation();
      });

    });
  }

  @override
  Widget build(BuildContext context) {

    contactUid ??= ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(

      appBar: AppBar(title: const Text('Conversation settings')),

      body: !initialized ? const CircularProgressIndicator() : ListView(
        padding: BASIC_HORIZONTAL_PADDING,
        children: [

          SwitchListTile(
              contentPadding: const EdgeInsets.only(top: 20),
              title:  const Text('Auto delete enabled'),
              value: _autoDeleteEnabled,
              onChanged: (bool isEnabled) => setState(() {
                _autoDeleteEnabled = isEnabled;
                _selectedTimeToLive = isEnabled ? getDefaultTimeToLive : 'disabled';
                _selectedTimeToLiveAfterRead = isEnabled ? getDefaultTimeToLiveAfterRead : 'disabled';
                checkIfHasChanges();
              }),
          ),

          _autoDeleteEnabled ? Column(children: [

            const Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text('Time to live:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20)
            )),

            PpButton(color: PRIMARY_COLOR_LIGHTER,
                text: _selectedTimeToLive,
                onPressed: () => showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => Container(
                      height: 350,
                      color: CupertinoColors.systemBackground.resolveFrom(context),
                      child: SafeArea(
                        child: CupertinoPicker(
                          itemExtent: 50,
                          looping: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: options.keys.toList()
                                  .indexWhere((option) => option == _selectedTimeToLive)
                          ),
                          onSelectedItemChanged: (int selectedItem) => setState(() {
                            _selectedTimeToLive = options.keys.toList()[selectedItem];
                            checkIfHasChanges();
                          }),
                          children: List<Widget>.generate(options.length, (int index) {
                            return Center(child: Text(options.keys.toList()[index]));
                          }),
                        ),
                      ),
                    ))

            ),

            const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text('Time to live after read:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20)
              )),

            PpButton(color: PRIMARY_COLOR_DARKER,
                text: _selectedTimeToLiveAfterRead,
                onPressed: () => showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => Container(
                      height: 350,
                      color: CupertinoColors.systemBackground.resolveFrom(context),
                      child: SafeArea(
                        child: CupertinoPicker(
                          itemExtent: 50,
                          looping: true,
                          scrollController: FixedExtentScrollController(
                              initialItem: options.keys.toList()
                                  .indexWhere((option) => option == _selectedTimeToLiveAfterRead)
                          ),
                          onSelectedItemChanged: (int selectedItem) => setState(() {
                            _selectedTimeToLiveAfterRead = options.keys.toList()[selectedItem];
                            checkIfHasChanges();
                          }),
                          children: List<Widget>.generate(options.length, (int index) {
                            return Center(child: Text(options.keys.toList()[index]));
                          }),
                        ),
                      ),
                    ))
            ),

          ]) : const SizedBox(height: 0),

          PpButton(text: 'Set default',
              padding: const EdgeInsets.only(top: 40),
              onPressed: setDefaultState,
              color: Colors.green,
          ),

          saveButton!,

        ],
      )
    );
  }

}