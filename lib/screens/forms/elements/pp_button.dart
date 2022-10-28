import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/forms/others/form_styles.dart';

class PpButton extends StatelessWidget {
  final Function onPressed;
  final bool active;
  final String text;
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

  const PpButton({
    super.key,
    required this.onPressed,
    this.active = true,
    this.text = 'OK',

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


  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: padding,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: shadow,
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: Material(
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            color: active ? color : backgroundColor,
            child: InkWell(
              onTap: () => onPressed(),
              splashColor: rippleColor,
              child: SizedBox(
                height: height,
                child: Center(child: Text(text, style: TextStyle(
                    color: active ? textColor : inactiveTextColor,
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




