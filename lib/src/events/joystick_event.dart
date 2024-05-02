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
  String toString() => '[JoystickEvent (${hand.name} - x: $x, y: $y)]';
}

class JoystickHandler extends MotionHandler<JoystickEvent> {
  JoystickHandler(this.hand);

  final Hand hand;

  static List<JoystickHandler>? list;

  @override
  StreamSubscription<JoystickEvent> onMotion() {
    return GamepadPlatform.instance.joystickEvents.listen(
      (event) => Handler.joystick(hand)._onEvent?.call(event),
    );
  }
}
