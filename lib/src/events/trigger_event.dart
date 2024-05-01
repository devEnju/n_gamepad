part of '../models/control.dart';

typedef Trigger = void Function(TriggerEvent event);

class TriggerEvent {
  TriggerEvent(
    int hand,
    this.device,
    this.z,
  ) : hand = Hand.values[hand];

  final Hand hand;

  final int device;

  final double z;

  @override
  String toString() => '[TriggerEvent (z: $z)]';
}

class TriggerHandler extends MotionHandler<TriggerEvent> {
  TriggerHandler(this._button);

  final Button _button;

  static int _count = 0;

  static List<TriggerHandler>? _list;

  static TriggerHandler map(Hand hand) {
    _list ??= <TriggerHandler>[
      TriggerHandler(Button.zl),
      TriggerHandler(Button.zr),
    ];
    return _list![hand.index];
  }

  @override
  bool assignMotionEvent(Trigger? onEvent) {
    checkReferenceCount(onEvent) == true ? _count++ : _count--;

    if (super.assignMotionEvent(onEvent)) {
      _subscription ??= GamepadPlatform.instance.triggerEvents.listen(
        (event) => map(event.hand)._onEvent?.call(event),
      );
      return true;
    }
    if (_subscription != null && _count == 0) {
      _subscription!.cancel();
      _subscription = null;

      final button = ButtonHandler._list?[_button.index];

      if (button != null) {
        return button.active;
      }
    }
    return false;
  }
}
