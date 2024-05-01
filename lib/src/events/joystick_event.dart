part of '../models/control.dart';

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
  static int _count = 0;

  static List<JoystickHandler>? _list;

  static JoystickHandler map(Hand hand) {
    _list ??= <JoystickHandler>[
      JoystickHandler(),
      JoystickHandler(),
    ];
    return _list![hand.index];
  }

  @override
  bool assignMotionEvent(Joystick? onEvent) {
    checkReferenceCount(onEvent) == true ? _count++ : _count--;

    if (super.assignMotionEvent(onEvent)) {
      _subscription ??= GamepadPlatform.instance.joystickEvents.listen(
        (event) => map(event.hand)._onEvent?.call(event),
      );
      return true;
    }
    if (_subscription != null && _count == 0) {
      _subscription!.cancel();
      _subscription = null;
    }
    return false;
  }
}
