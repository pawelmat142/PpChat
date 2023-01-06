import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/avatar/avatar_model.dart';
import 'package:flutter_chat_app/components/avatar/avatar_service.dart';
import 'package:flutter_chat_app/components/avatar/avatar_widget.dart';
import 'package:flutter_chat_app/constants/styles.dart';
import 'package:flutter_chat_app/dialogs/pp_snack_bar.dart';
import 'package:flutter_chat_app/dialogs/spinner.dart';
import 'package:flutter_chat_app/models/user/me.dart';
import 'package:flutter_chat_app/models/user/pp_user.dart';
import 'package:flutter_chat_app/screens/data_views/user_view.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button.dart';
import 'package:flutter_chat_app/screens/forms/elements/pp_button_controllable.dart';
import 'package:flutter_chat_app/services/get_it.dart';
import 'package:flutter_chat_app/services/navigation_service.dart';

class EditAvatarView extends StatefulWidget {
  final PpUser user;
  const EditAvatarView({
    required this.user,
    Key? key
  }) : super(key: key);

  @override
  State<EditAvatarView> createState() => _EditAvatarViewState();
}

class _EditAvatarViewState extends State<EditAvatarView> {

  final _spinner = getIt.get<PpSpinner>();

  final List<String> colorKeys = AvatarService.colorsPalette.keys.toList();

  late AvatarModel currentAvatarModel;

  static const double circleSize = 50;

  bool get isAnyChange => currentAvatarModel.txt != widget.user.avatar.txt
      || currentAvatarModel.color != widget.user.avatar.color;

  late PpButtonControllable saveButton;
  late PpButtonControllable resetButton;

  final TextEditingController _textFieldController = TextEditingController();
  bool _textFieldInvalid = false;

  @override
  void initState() {
    currentAvatarModel = AvatarModel.copy(widget.user.avatar);

    _textFieldController.text = currentAvatarModel.txt;
    _textFieldController.addListener(_onTextFieldChange);
    initButtons();
    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.removeListener(_onTextFieldChange);
    super.dispose();
  }

  _onTextFieldChange() {
    setState(() {
      if (_textFieldController.text.isEmpty) {
        _textFieldInvalid = true;
      } else {
        _textFieldInvalid = false;
        currentAvatarModel.txt = _textFieldController.text;
      }
    });
    _checkChanges();
  }



  _onColorTap(String colorKey) => setState((){
    FocusScope.of(context).unfocus();
    currentAvatarModel.color = colorKey;
    _checkChanges();
  });

  _checkChanges() {
    if (isAnyChange) {
      saveButton.activation();
      resetButton.activation();
    } else {
      saveButton.deactivation();
      resetButton.deactivation();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('Edit my avatar')),

      body: Padding(
        padding: BASIC_HORIZONTAL_PADDING,
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: ListView(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: AvatarWidget(
                    size: 150,
                    model: currentAvatarModel
                ),
              ),

              Center(
                child: SizedBox(
                  width: 100,
                  child: TextField(
                    maxLength: 3,
                    textAlign: TextAlign.center,
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      labelText: 'LETTERS',
                      errorText: _textFieldInvalid ? 'min one!' : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// COLORS

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: colorKeys.getRange(0, 4).map((c) => ColorCircle(
                      onTap: _onColorTap,
                      size: circleSize,
                      colorKey: c,
                    )).toList()
              ),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: colorKeys.getRange(4, 8).map((c) => ColorCircle(
                        onTap: _onColorTap,
                        size: circleSize,
                        colorKey: c,
                      )).toList()
              ),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: colorKeys.getRange(8, colorKeys.length).map((c) => ColorCircle(
                        onTap: _onColorTap,
                        size: circleSize,
                        colorKey: c,
                      )).toList()
              ),


              ///BUTTONS

              PpButton(text: 'Upload image', color: PRIMARY_COLOR_DARKER, onPressed: () {

              }),

              saveButton,
              resetButton,
            ],
          ),
        ),
      ),
    );
  }

  initButtons() {
    saveButton = PpButtonControllable(text: 'SAVE', active: false,
        onPressed: () async {
          try {
            _spinner.start();
            await AvatarService.saveAvatarEdit(currentAvatarModel);
            _spinner.stop();
            await Future.delayed(const Duration(milliseconds: 100));
            NavigationService.popToHome();
            UserView.navigate(user: Me.reference.get);
            PpSnackBar.success();
          } catch (error) {
            _spinner.stop();
            PpSnackBar.error();
          }
        });

    resetButton = PpButtonControllable(text: 'Reset changes', active: false,
        color: PRIMARY_COLOR_LIGHTER,
        onPressed: () => setState((){
          currentAvatarModel = AvatarModel.copy(widget.user.avatar);
          _textFieldController.text = widget.user.avatar.txt;
          _checkChanges();
        }));
  }

}

class ColorCircle extends StatelessWidget {
  const ColorCircle({
    required this.colorKey,
    required this.size,
    required this.onTap,
    Key? key
  }) : super(key: key);
  final String colorKey;
  final double size;
  final void Function(String colorKey)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      onTap: () => onTap!(colorKey),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
              color: AvatarService.getColor(colorKey),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AvatarService.getColor(colorKey).withOpacity(0.5),
                  spreadRadius: size/50,
                  blurRadius: size/30,
                  offset: Offset(0, size/50),
                )
              ]
          ),
        ),
      ),
    );
  }
}

