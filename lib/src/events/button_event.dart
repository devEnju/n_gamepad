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
  String toString() => '[ButtonEvent (${button.name} - $_state)]';
}

class ButtonHandler extends KeyHandler<ButtonEvent> {
  ButtonHandler(this.button);

  final Button button;

  static List<ButtonHandler>? list;

  @override
  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    if (super.assignKeyEvent(onPress, onRelease)) {
      return true;
    }
    if (Handler.trigger(Hand.left).isKey(button)) {
      return true;
    }
    if (Handler.trigger(Hand.right).isKey(button)) {
      return true;
    }
    return false;
  }

  @override
  StreamSubscription<ButtonEvent> onKey() {
    return GamepadPlatform.instance.buttonEvents.listen((event) {
      ButtonHandler handler = Handler.button(button);

      event.state ? handler.onKeyDown(event) : handler.onKeyUp(event);
    });
  }
}
