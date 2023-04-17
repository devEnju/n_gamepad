import 'dart:async';

import 'package:flutter/services.dart';

import '../../n_gamepad_platform_interface.dart';

part '../events/button_event.dart';
part '../events/dpad_event.dart';
part '../events/joystick_event.dart';
part '../events/trigger_event.dart';

enum Control {
  gyro,
  a,
  b,
  x,
  y,
  l,
  r,
  zl,
  zr,
  tl,
  tr,
  jl,
  jr,
  select,
  start,
  dpad,
}

enum Button {
  a(LogicalKeyboardKey.gameButtonA),
  b(LogicalKeyboardKey.gameButtonB),
  x(LogicalKeyboardKey.gameButtonX),
  y(LogicalKeyboardKey.gameButtonY),
  l(LogicalKeyboardKey.gameButtonLeft1),
  r(LogicalKeyboardKey.gameButtonRight1),
  zl(LogicalKeyboardKey.gameButtonLeft2),
  zr(LogicalKeyboardKey.gameButtonRight2),
  tl(LogicalKeyboardKey.gameButtonThumbLeft),
  tr(LogicalKeyboardKey.gameButtonThumbRight),
  select(LogicalKeyboardKey.gameButtonSelect),
  start(LogicalKeyboardKey.gameButtonStart),
  up(null),
  down(null),
  left(null),
  right(null);

  const Button(this.key);

  final LogicalKeyboardKey? key;
}

abstract class KeyHandler {
  Press? _onPress;
  Release? _onRelease;

  bool isPressed = false;

  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    _onPress = onPress;
    _onRelease = onRelease;

    return onPress != null || onRelease != null;
  }

  bool _onKeyDown() {
    if (!isPressed) {
      isPressed = true;
      if (_onPress != null) {
        _onPress!();
        return true;
      }
    }
    return false;
  }

  bool _onKeyUp() {
    if (isPressed) {
      isPressed = false;
      if (_onRelease != null) {
        _onRelease!();
        return true;
      }
    }
    return false;
  }
}

abstract class MotionHandler<T> {
  MotionHandler(this._events);

  final Stream<T> _events;

  StreamSubscription<T>? _subscription;

  void Function(T event)? _onEvent;

  bool assignMotionEvent(void Function(T event)? onEvent) {
    _onEvent = onEvent;

    return onEvent != null;
  }
}
