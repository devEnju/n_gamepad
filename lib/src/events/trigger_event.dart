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
  String toString() => '[TriggerEvent (${hand.name} - z: $z)]';
}

class TriggerHandler extends MotionHandler<TriggerEvent> {
  TriggerHandler(this.hand);

  final Hand hand;

  static List<TriggerHandler>? list;

  @override
  bool assignMotionEvent(Trigger? onEvent) {
    if (super.assignMotionEvent(onEvent)) {
      return true;
    }
    final handler = ButtonHandler.list?[hand.button.index];

    if (handler != null) {
      return handler._onPress != null || handler._onRelease != null;
    }
    return false;
  }

  @override
  StreamSubscription<TriggerEvent> onMotion() {
    return GamepadPlatform.instance.triggerEvents.listen((event) {
      Handler.trigger(hand)._onEvent?.call(event);
    });
  }

  bool isKey(Button button) {
    return hand.button == button && _onEvent != null;
  }
}
