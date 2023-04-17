part of '../models/control.dart';

typedef Press = void Function();
typedef Release = void Function();

class ButtonHandler extends KeyHandler {
  ButtonHandler(this._button);

  final Button _button;

  static Map<LogicalKeyboardKey, ButtonHandler>? _map;

  static Map<LogicalKeyboardKey, ButtonHandler> get map {
    if (_map == null) {
      _map = <LogicalKeyboardKey, ButtonHandler>{
        for (final value in Button.values)
          if (value.key != null) value.key!: ButtonHandler(value),
      };

      HardwareKeyboard.instance.addHandler(
        (event) => _map![event.logicalKey]?.onKey(event) ?? false,
      );
    }
    return _map!;
  }

  @override
  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    if (super.assignKeyEvent(onPress, onRelease)) {
      return true;
    } else if (_button == Button.zl && JoystickHandler.left._onEvent != null) {
      return true;
    } else if (_button == Button.zr && JoystickHandler.right._onEvent != null) {
      return true;
    }
    return false;
  }

  bool onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      return _onKeyDown();
    }
    if (event is KeyUpEvent) {
      return _onKeyUp();
    }
    return false;
  }
}
