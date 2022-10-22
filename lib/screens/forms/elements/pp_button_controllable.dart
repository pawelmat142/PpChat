import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/animations/color_from_to_animation.dart';
import 'package:flutter_chat_app/constants/form_styles.dart';

// ignore: must_be_immutable
class PpButtonControllable extends StatefulWidget {
  final Function onPressed;
  bool active;
  final bool controllable;
  final String text;
  final int transition;
  final double height;
  final EdgeInsets padding;
  final double borderRadius;
  final double borderWidth;
  final Color color;
  final Color backgroundColor;
  final Color textColor;
  final Color inactiveTextColor;
  final Color rippleColor;
  final double shadow;


  PpButtonControllable({
    super.key,
    required this.onPressed,
    this.active = true,
    this.controllable = true,
    this.text = 'OK',
    this.transition = 100,

    ///STYLES
    //sizes
    this.height = primaryButtonHeight,
    this.padding = primaryButtonPadding,
    //border
    this.borderRadius = primaryButtonBorderRadius,
    this.borderWidth = primaryButtonBorderWidth,
    //colors
    this.color = primaryButtonColor,
    this.backgroundColor = primaryButtonBackgroundColor,
    this.textColor = primaryButtonTextColor,
    this.inactiveTextColor = primaryButtonInactiveTextColor,
    this.rippleColor = primaryButtonRippleColor,
    //shadow
    this.shadow = primaryButtonShadow
  });

  final _controller = StreamController<void>();
  Stream<void> get stream => _controller.stream;
  void killStream() => _controller.close();

  void activation() {
    if (!active) {
      active = true;
      _controller.add(null);
    }
  }

  void deactivation() {
    if (active) {
      active = false;
      _controller.add(null);
    }
  }

  @override
  State<PpButtonControllable> createState() => PpButtonControllableState();
}

class PpButtonControllableState extends State<PpButtonControllable> with TickerProviderStateMixin {

  late ColorFromToAnimation mainColorAnimation;
  late ColorFromToAnimation textColorAnimation;

  Color get _mainColor => widget.controllable ? mainColorAnimation.value : widget.active ? widget.color : widget.backgroundColor;
  Color get _textColor => widget.controllable ? textColorAnimation.value : widget.active ? widget.textColor : widget.inactiveTextColor;

  @override
  void initState() {
    if (widget.controllable) {

      mainColorAnimation = ColorFromToAnimation(this,
          from: widget.color,
          to: widget.backgroundColor,
          duration: Duration(milliseconds: widget.transition)
      );

      textColorAnimation = ColorFromToAnimation(this,
          from: widget.textColor,
          to: widget.inactiveTextColor,
          duration: Duration(milliseconds: widget.transition)
      );

      widget.stream.listen((nothing) => animation());
    }
    super.initState();
    animation();
  }

  @override
  void dispose() {
    mainColorAnimation.stop();
    textColorAnimation.stop();
    widget.killStream();
    super.dispose();
  }

  animation() {
    if (widget.active) {
      mainColorAnimation.back(setState);
      textColorAnimation.back(setState);
    } else {
      mainColorAnimation.go(setState);
      textColorAnimation.go(setState);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: widget.padding,
      child: Material(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        elevation: widget.shadow,
        child: Padding(
          padding: EdgeInsets.all(widget.borderWidth),
          child: Material(
            borderRadius: BorderRadius.circular(widget.borderRadius - widget.borderWidth),
            color: _mainColor,
            child: InkWell(
              onTap: () => widget.active ? widget.onPressed() : null,
              splashColor: widget.rippleColor,
              child: SizedBox(
                height: widget.height,
                child: Center(child: Text(widget.text, style: TextStyle(
                    color: _textColor,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w900
                ))),
              ),
            ),
          ),
        ),
      ),
    );

  }
}
