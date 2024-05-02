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
    ButtonHandler.list ??= <ButtonHandler>[
      for (final value in Button.values)
        if (!value.motion) ButtonHandler(value),
    ];
    return ButtonHandler.list![button.index];
  }

  static DpadHandler? dpad(Button button) {
    DpadHandler.map ??= <Button, DpadHandler>{
      for (final value in Button.values)
        if (value.motion) value: DpadHandler(),
    };
    return DpadHandler.map![button];
  }

  static JoystickHandler joystick(Hand hand) {
    JoystickHandler.list ??= <JoystickHandler>[
      JoystickHandler(Hand.left),
      JoystickHandler(Hand.right),
    ];
    return JoystickHandler.list![hand.index];
  }

  static TriggerHandler trigger(Hand hand) {
    TriggerHandler.list ??= <TriggerHandler>[
      TriggerHandler(Hand.left),
      TriggerHandler(Hand.right),
    ];
    return TriggerHandler.list![hand.index];
  }
}

abstract class KeyHandler<T> {
  void Function(ButtonEvent event)? _onPress;
  void Function(ButtonEvent event)? _onRelease;

  StreamSubscription<T>? subscription;

  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    _onPress = onPress;
    _onRelease = onRelease;

    if (_onPress != null || _onRelease != null) {
      subscription ??= onKey();
      return true;
    }
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
    return false;
  }

  StreamSubscription<T> onKey();

  bool onKeyDown(ButtonEvent event) {
    if (_onPress != null) {
      _onPress!.call(event);
      return true;
    }
    return false;
  }

  bool onKeyUp(ButtonEvent event) {
    if (_onRelease != null) {
      _onRelease!.call(event);
      return true;
    }
    return false;
  }
}

abstract class MotionHandler<T> {
  void Function(T event)? _onEvent;

  StreamSubscription<T>? subscription;

  bool assignMotionEvent(void Function(T event)? onEvent) {
    _onEvent = onEvent;

    if (_onEvent != null) {
      subscription ??= onMotion();
      return true;
    }
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
    return false;
  }

  StreamSubscription<T> onMotion();
}
