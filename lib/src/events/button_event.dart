part of '../models/control.dart';

typedef Press = void Function(ButtonEvent event);
typedef Release = void Function(ButtonEvent event);

class ButtonEvent {
  ButtonEvent(
    int button,
    this.device,
    this.state,
  ) : button = Button.values[button];

  final Button button;

  final int device;

  final bool state;

  String get _state => state ? 'pressed' : 'released';

  @override
  String toString() => '[ButtonEvent (${button.name}: $_state)]';
}

class ButtonHandler extends KeyHandler {
  ButtonHandler(this._button);

  final Button _button;

  static int _count = 0;

  static StreamSubscription<ButtonEvent>? _subscription;

  static List<ButtonHandler>? _list;

  static ButtonHandler map(Button button) {
    _list ??= <ButtonHandler>[
      for (final value in Button.values)
        if (!value.motion) ButtonHandler(value),
    ];
    return _list![button.index];
  }

  @override
  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    checkReferenceCount(onPress, onRelease) == true ? _count++ : _count--;

    if (super.assignKeyEvent(onPress, onRelease)) {
      _subscription ??= GamepadPlatform.instance.buttonEvents.listen(
        (event) => map(event.button)._onKey(event),
      );
      return true;
    }
    if (_subscription != null && _count == 0) {
      _subscription!.cancel();
      _subscription = null;
    }
    if (_button == Button.zl && TriggerHandler.map(Hand.left).active) {
      return true;
    }
    if (_button == Button.zr && TriggerHandler.map(Hand.right).active) {
      return true;
    }
    return false;
  }

  bool _onKey(ButtonEvent event) {
    return event.state ? _onKeyDown(event) : _onKeyUp(event);
  }
}
