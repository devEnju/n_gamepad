part of '../models/control.dart';

typedef Joystick = void Function(JoystickEvent event);

class JoystickEvent {
  JoystickEvent(List<double> list)
      : x = list[0],
        y = list[1];

  final double x;
  final double y;

  @override
  String toString() => '[JoystickEvent (x: $x, y: $y)]';
}

class JoystickHandler extends MotionHandler<JoystickEvent> {
  JoystickHandler(super._events);

  static JoystickHandler? _left;
  static JoystickHandler? _right;

  @override
  bool assignMotionEvent(Joystick? onEvent) {
    if (super.assignMotionEvent(onEvent)) {
      _subscription ??= _events.listen(_onEvent);
      return true;
    } else if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
    return false;
  }

  static JoystickHandler get left {
    _left ??= JoystickHandler(GamepadPlatform.instance.joystickLeftEvents);
    return _left!;
  }

  static JoystickHandler get right {
    _right ??= JoystickHandler(GamepadPlatform.instance.joystickRightEvents);
    return _right!;
  }
}
