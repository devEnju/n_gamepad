part of '../models/control.dart';

typedef Dpad = void Function(DpadEvent event);

class DpadEvent {
  DpadEvent(this.device, this.x, this.y);

  final int device;

  final int x;
  final int y;

  @override
  String toString() => '[DpadEvent (x: $x, y: $y)]';
}

class DpadHandler extends KeyHandler {
  static Map<Button, DpadHandler>? _map;

  static StreamSubscription<DpadEvent>? _subscription;

  static Dpad? _onEvent;

  @override
  bool assignKeyEvent(Press? onPress, Release? onRelease) {
    if (super.assignKeyEvent(onPress, onRelease)) {
      _subscription ??= GamepadPlatform.instance.dpadEvents.listen(_onDpad);
      return true;
    } else if (_subscription != null) {
      bool isUnused = _onEvent == null;

      for (DpadHandler value in _map!.values) {
        isUnused &= value._onPress == null;
        isUnused &= value._onRelease == null;
        if (!isUnused) return true;
      }
      _subscription!.cancel();
      _subscription = null;
    }
    return false;
  }

  static Map<Button, DpadHandler> get map {
    _map ??= <Button, DpadHandler>{
      for (final value in Button.values)
        if (value.key == null) value: DpadHandler(),
    };
    return _map!;
  }

  static bool assignMotionEvent(Dpad? onEvent) {
    _onEvent = onEvent;

    if (onEvent != null) {
      _subscription ??= GamepadPlatform.instance.dpadEvents.listen(_onDpad);
      return true;
    } else if (_subscription != null) {
      bool isUnused = true;

      if (_map != null) {
        for (DpadHandler value in _map!.values) {
          isUnused &= value._onPress == null;
          isUnused &= value._onRelease == null;
          if (!isUnused) return true;
        }
      }
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
        left._onKeyDown();
        right._onKeyUp();
      } else if (event.x > 0) {
        left._onKeyUp();
        right._onKeyDown();
      } else {
        left._onKeyUp();
        right._onKeyUp();
      }
      if (event.y < 0) {
        up._onKeyDown();
        down._onKeyUp();
      } else if (event.y > 0) {
        up._onKeyUp();
        down._onKeyDown();
      } else {
        up._onKeyUp();
        down._onKeyUp();
      }
    }
    _onEvent?.call(event);
  }
}
