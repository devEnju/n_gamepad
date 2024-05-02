part of '../models/handler.dart';

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

  static List<TriggerHandler>? _list;

  @override
  bool assignMotionEvent(Trigger? onEvent) {
    if (super.assignMotionEvent(onEvent)) {
      subscription ??= GamepadPlatform.instance.triggerEvents.listen(
        (event) => Handler.trigger(event.hand)._onEvent?.call(event),
      );
      return true;
    }
    final button = ButtonHandler._list?[_button.index];

    if (button != null) {
      return button.active;
    }
    return false;
  }
}
