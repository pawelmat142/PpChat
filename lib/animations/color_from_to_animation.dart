import 'package:flutter/material.dart';

/// USAGE:
/// 1. add to _NameScreenState extends State<NameScreen> 'with TickerProviderStateMixin' or 'with SingleTickerProviderStateMixin'
/// 2. add 'ColorFromToAnimation animation' to state widget class
/// 3. before super.initState() add instance of: 'animation = ColorFromToAnimation(this, <OPTIONAL PROPERTIES>)'
/// 4. after super.initState() add: 'animation.start(setState)'
/// 5. before super.dispose() add: 'animation.stop()'
/// 6. to animated widget color property add: 'animation.value'

class ColorFromToAnimation {
  late AnimationController _controller;
  late Animation animation;
  bool _inProgress = false;

  final Color from;
  final Color to;
  final Duration duration;
  final bool loop;

  ColorFromToAnimation(TickerProvider vsync, {

  ///OPTIONAL PROPERTIES
    this.from = Colors.blueGrey,
    this.to = Colors.white,
    this.duration = const Duration(seconds: 2),
    this.loop = false,
  }) {
    _controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    animation = ColorTween(begin: from, end: to).animate(_controller);

    ///LOOP ANIMATION
    if (loop) {
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse(from: 1);
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    }
  }

  get value => _inProgress ? animation.value : from;

  start(Function setState) {
    if (!_inProgress) {
      _inProgress = true;
      _controller.forward();
      _controller.addListener(() => setState((){}));
    }
  }

  stop() {
    if (_inProgress) {
      _controller.dispose();
      _inProgress = false;
    }
  }

  go(Function setState) {
    _inProgress = true;
    _controller.forward();
    _controller.addListener(() => setState(() {}));
  }

  back(Function setState) {
    _inProgress = true;
    _controller.reverse();
    _controller.addListener(() => setState((){}));
  }

}
