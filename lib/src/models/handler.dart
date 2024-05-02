import 'dart:async';

import 'package:n_gamepad/n_gamepad.dart';

import '../../n_gamepad_platform_interface.dart';

import 'control.dart';

part '../events/button_event.dart';
part '../events/dpad_event.dart';
part '../events/joystick_event.dart';
part '../events/trigger_event.dart';

class Handler {
  static ButtonHandler button(Button button) {
    ButtonHandler._list ??= <ButtonHandler>[
      for (final value in Button.values)
        if (!value.motion) ButtonHandler(value),
    ];
    return ButtonHandler._list![button.index];
  }

  static DpadHandler? dpad(Button button) {
    DpadHandler._map ??= <Button, DpadHandler>{
      for (final value in Button.values)
        if (value.motion) value: DpadHandler(),
    };
    return DpadHandler._map![button];
  }

  static JoystickHandler joystick(Hand hand) {
    JoystickHandler._list ??= <JoystickHandler>[
      JoystickHandler(),
      JoystickHandler(),
    ];
    return JoystickHandler._list![hand.index];
  }

  static TriggerHandler trigger(Hand hand) {
    TriggerHandler._list ??= <TriggerHandler>[
      TriggerHandler(Button.zl),
      TriggerHandler(Button.zr),
    ];
    return TriggerHandler._list![hand.index];
  }
}

abstract class KeyHandler<T> {
  StreamSubscription<T>? subscription;

  Press? _onPress;
  Release? _onRelease;

  bool get active => _onPress != null || _onRelease != null;

  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    _onPress = onPress;
    _onRelease = onRelease;

    if (active) return true;

    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
    return false;
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
  StreamSubscription<T>? subscription;

  void Function(T event)? _onEvent;

  bool get active => _onEvent != null;

  bool assignMotionEvent(void Function(T event)? onEvent) {
    _onEvent = onEvent;

    if (active) return true;

    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
    return false;
  }
}
