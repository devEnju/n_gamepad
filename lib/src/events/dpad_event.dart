part of '../models/handler.dart';

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

class DpadHandler extends KeyHandler<DpadEvent> {
  bool state = false;

  static Map<Button, DpadHandler>? map;

  static void Function(DpadEvent event)? _onEvent;

  static StreamSubscription<DpadEvent>? _subscription;

  static bool assignMotionEvent(Dpad? onEvent) {
    _onEvent = onEvent;

    if (_onEvent != null) {
      _subscription ??= onMotion();
      return true;
    }
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
    return false;
  }

  static StreamSubscription<DpadEvent> onMotion() {
    return GamepadPlatform.instance.dpadEvents.listen((event) {
      if (map != null) {
        final up = map![Button.up]!;
        final down = map![Button.down]!;
        final left = map![Button.left]!;
        final right = map![Button.right]!;

        if (event.x < 0) {
          left.onKeyDown(ButtonEvent(Button.left.index, event.device, true));
          right.onKeyUp(ButtonEvent(Button.right.index, event.device, false));
        } else if (event.x > 0) {
          left.onKeyUp(ButtonEvent(Button.left.index, event.device, false));
          right.onKeyDown(ButtonEvent(Button.right.index, event.device, true));
        } else {
          left.onKeyUp(ButtonEvent(Button.left.index, event.device, false));
          right.onKeyUp(ButtonEvent(Button.right.index, event.device, false));
        }
        if (event.y < 0) {
          up.onKeyDown(ButtonEvent(Button.up.index, event.device, true));
          down.onKeyUp(ButtonEvent(Button.down.index, event.device, false));
        } else if (event.y > 0) {
          up.onKeyUp(ButtonEvent(Button.up.index, event.device, false));
          down.onKeyDown(ButtonEvent(Button.down.index, event.device, true));
        } else {
          up.onKeyUp(ButtonEvent(Button.up.index, event.device, false));
          down.onKeyUp(ButtonEvent(Button.down.index, event.device, false));
        }
      }
      _onEvent?.call(event);
    });
  }

  @override
  StreamSubscription<DpadEvent> onKey() => onMotion();

  @override
  bool onKeyDown(ButtonEvent event) {
    if (!state) {
      state = true;
      return super.onKeyDown(event);
    }
    return false;
  }

  @override
  bool onKeyUp(ButtonEvent event) {
    if (state) {
      state = false;
      return super.onKeyUp(event);
    }
    return false;
  }
}
