part of '../models/control.dart';

typedef Dpad = void Function(DpadEvent event);

class DpadEvent {
  DpadEvent(
    this.device,
    this.x,
    this.y,
  );

  final int device;

  final int x;
  final int y;

  @override
  String toString() => '[DpadEvent (x: $x, y: $y)]';
}

class DpadHandler extends KeyHandler {
  bool state = false;

  static int _count = 0;

  static StreamSubscription<DpadEvent>? _subscription;

  static Dpad? _onEvent;

  static Map<Button, DpadHandler>? _map;

  static DpadHandler? map(Button button) {
    _map ??= <Button, DpadHandler>{
      for (final value in Button.values)
        if (value.motion) value: DpadHandler(),
    };
    return _map![button];
  }

  static bool assignMotionEvent(Dpad? onEvent) {
    if (_onEvent == null && onEvent != null) _count++;
    if (_onEvent != null && onEvent == null) _count--;

    _onEvent = onEvent;

    if (_onEvent != null) {
      _subscription ??= GamepadPlatform.instance.dpadEvents.listen(_onDpad);
      return true;
    }
    if (_subscription != null && _count == 0) {
      _subscription!.cancel();
      _subscription = null;
    }
    return false;
  }

  static void _onDpad(DpadEvent event) {
    if (_map != null) {
      final up = _map![Button.up]!;
      final down = _map![Button.down]!;
      final left = _map![Button.left]!;
      final right = _map![Button.right]!;

      if (event.x < 0) {
        left._onKeyDown(ButtonEvent(Button.left.index, event.device, true));
        right._onKeyUp(ButtonEvent(Button.right.index, event.device, false));
      } else if (event.x > 0) {
        left._onKeyUp(ButtonEvent(Button.left.index, event.device, false));
        right._onKeyDown(ButtonEvent(Button.right.index, event.device, true));
      } else {
        left._onKeyUp(ButtonEvent(Button.left.index, event.device, false));
        right._onKeyUp(ButtonEvent(Button.right.index, event.device, false));
      }
      if (event.y < 0) {
        up._onKeyDown(ButtonEvent(Button.up.index, event.device, true));
        down._onKeyUp(ButtonEvent(Button.down.index, event.device, false));
      } else if (event.y > 0) {
        up._onKeyUp(ButtonEvent(Button.up.index, event.device, false));
        down._onKeyDown(ButtonEvent(Button.down.index, event.device, true));
      } else {
        up._onKeyUp(ButtonEvent(Button.up.index, event.device, false));
        down._onKeyUp(ButtonEvent(Button.down.index, event.device, false));
      }
    }
    _onEvent?.call(event);
  }

  @override
  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    checkReferenceCount(onPress, onRelease) == true ? _count++ : _count--;

    if (super.assignKeyEvent(onPress, onRelease)) {
      _subscription ??= GamepadPlatform.instance.dpadEvents.listen(_onDpad);
      return true;
    }
    if (_subscription != null && _count == 0) {
      _subscription!.cancel();
      _subscription = null;
    }
    return false;
  }

  @override
  bool _onKeyDown(ButtonEvent event) {
    if (!state) {
      state = true;
      return super._onKeyDown(event);
    }
    return false;
  }

  @override
  bool _onKeyUp(ButtonEvent event) {
    if (state) {
      state = false;
      return super._onKeyUp(event);
    }
    return false;
  }
}
