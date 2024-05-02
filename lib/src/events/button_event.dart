part of '../models/handler.dart';

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

class ButtonHandler extends KeyHandler<ButtonEvent> {
  ButtonHandler(this._button);

  final Button _button;

  static List<ButtonHandler>? _list;

  @override
  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    if (super.assignKeyEvent(onPress, onRelease)) {
      subscription ??= GamepadPlatform.instance.buttonEvents.listen(
        (event) => Handler.button(event.button)._onKey(event),
      );
      return true;
    }
    if (_button == Button.zl && Handler.trigger(Hand.left).active) {
      return true;
    }
    if (_button == Button.zr && Handler.trigger(Hand.right).active) {
      return true;
    }
    return false;
  }

  bool _onKey(ButtonEvent event) {
    return event.state ? _onKeyDown(event) : _onKeyUp(event);
  }
}
