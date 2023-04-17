part of '../models/control.dart';

typedef Trigger = void Function(TriggerEvent event);

class TriggerEvent {
  TriggerEvent(List<double> list) : z = list[0];

  final double z;

  @override
  String toString() => '[TriggerEvent (z: $z)]';
}

class TriggerHandler extends MotionHandler<TriggerEvent> {
  TriggerHandler(super._events, this._button);

  final Button _button;

  static TriggerHandler? _left;
  static TriggerHandler? _right;

  @override
  bool assignMotionEvent(Trigger? onEvent) {
    if (super.assignMotionEvent(onEvent)) {
      _subscription ??= _events.listen(_onEvent);
      return true;
    } else if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;

      final button = ButtonHandler._map?[_button.key];

      if (button != null) {
        if (button._onPress != null || button._onRelease != null) {
          return true;
        }
      }
    }
    return false;
  }

  static TriggerHandler get left {
    _left ??= TriggerHandler(
      GamepadPlatform.instance.triggerLeftEvents,
      Button.zl,
    );
    return _left!;
  }

  static TriggerHandler get right {
    _right ??= TriggerHandler(
      GamepadPlatform.instance.triggerRightEvents,
      Button.zr,
    );
    return _right!;
  }
}
