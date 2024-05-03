part of '../models/handler.dart';

typedef Joystick = void Function(JoystickEvent event);

class JoystickEvent {
  JoystickEvent(
    int index,
    this.device,
    this.x,
    this.y,
  ) : hand = Hand.values[index];

  final Hand hand;
  final int device;
  final double x;
  final double y;

  String get _x => x.toStringAsFixed(5);
  String get _y => y.toStringAsFixed(5);

  @override
  String toString() => '[JoystickEvent (${hand.name} - x: $_x, y: $_y)]';
}

class JoystickHandler extends MotionHandler<JoystickEvent> {
  JoystickHandler(this.hand);

  final Hand hand;

  static List<JoystickHandler>? list;

  @override
  StreamSubscription<JoystickEvent> onMotion() {
    return GamepadPlatform.instance.joystickEvents.listen(
      (event) => Handler.joystick(event.hand)._onUse?.call(event),
    );
  }
}
