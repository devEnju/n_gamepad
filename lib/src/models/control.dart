import 'dart:async';

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
  select,
  start,
  up(true),
  down(true),
  left(true),
  right(true);

  const Button([this.motion = false]);

  final bool motion;
}

enum Hand {
  left(Control.jl, Control.tl),
  right(Control.jr, Control.tr);

  const Hand(this.joystick, this.trigger);

  final Control joystick;
  final Control trigger;
}

abstract class KeyHandler {
  Press? _onPress;
  Release? _onRelease;

  bool get active => _onPress != null || _onRelease != null;

  bool? checkReferenceCount(Press? onPress, Release? onRelease) {
    if (_onPress == null && _onRelease == null) {
      if (onPress != null || onRelease != null) {
        return true;
      }
    }
    if (_onPress != null || _onRelease != null) {
      if (onPress == null && onRelease == null) {
        return false;
      }
    }
    return null;
  }

  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    _onPress = onPress;
    _onRelease = onRelease;

    return active;
  }

  bool _onKeyDown(ButtonEvent event) {
    if (_onPress != null) {
      _onPress!.call(event);
      return true;
    }
    return false;
  }

  bool _onKeyUp(ButtonEvent event) {
    if (_onRelease != null) {
      _onRelease!.call(event);
      return true;
    }
    return false;
  }
}

abstract class MotionHandler<T> {
  StreamSubscription<T>? _subscription;

  void Function(T event)? _onEvent;

  bool get active => _onEvent != null;

  bool? checkReferenceCount(void Function(T event)? onEvent) {
    if (_onEvent == null && onEvent != null) {
      _onEvent = onEvent;
      return true;
    }
    if (_onEvent != null && onEvent == null) {
      _onEvent = onEvent;
      return false;
    }
    return null;
  }

  bool assignMotionEvent(void Function(T event)? onEvent) {
    _onEvent = onEvent;

    return active;
  }
}
