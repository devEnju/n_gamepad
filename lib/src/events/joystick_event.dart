part of '../models/handler.dart';

typedef Joystick = void Function(JoystickEvent event);

class JoystickEvent {
  JoystickEvent(
    int hand,
    this.device,
    this.x,
    this.y,
  ) : hand = Hand.values[hand];

  final Hand hand;

  final int device;

  final double x;
  final double y;

  @override
  String toString() => '[JoystickEvent (x: $x, y: $y)]';
}

class JoystickHandler extends MotionHandler<JoystickEvent> {
  static List<JoystickHandler>? _list;

  @override
  bool assignMotionEvent(Joystick? onEvent) {
    if (super.assignMotionEvent(onEvent)) {
      subscription ??= GamepadPlatform.instance.joystickEvents.listen(
        (event) => Handler.joystick(event.hand)._onEvent?.call(event),
      );
      return true;
    }
    return false;
  }
}
