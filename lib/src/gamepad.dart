import 'dart:async';

import '../n_gamepad_platform_interface.dart';

import 'models/control.dart';
import 'models/handler.dart';

/// A class for managing gamepad inputs in a Flutter application.
///
/// The [Gamepad] class provides a convenient way to handle various gamepad
/// inputs such as buttons, dpad, joysticks, and triggers. It acts as a wrapper
/// around platform-specific code.
///
/// Use the singleton [instance] to access the methods provided by this class.
class Gamepad {
  /// Private constructor to enforce singleton pattern.
  Gamepad._();

  /// The unique instance of the [Gamepad] class.
  static final instance = Gamepad._();

  /// Assigns press and release listeners to a specified [Button].
  ///
  /// [button] is the [Button] to which the listeners will be assigned.
  /// [onPress] is an optional callback for button [Press] events.
  /// [onRelease] is an optional callback for button [Release] events.
  ///
  /// Returns `true` if listeners are assigned, even if those listeners are from
  /// a mutual [MotionHandler], `false` when all listeners are set to `null`. In
  /// order to reset listeners of this [KeyHandler], [assignButtonListener]
  /// needs to be called only specifying a [button].
  bool assignButtonListener(
    Button button, {
    Press? onPress,
    Release? onRelease,
  }) {
    if (button.motion) {
      return Handler.dpad(button)!.assignKeyEvent(onPress, onRelease);
    }
    return Handler.button(button).assignKeyEvent(onPress, onRelease);
  }

  /// Assigns an event listener to the gamepad's dpad.
  ///
  /// [onEvent] is an optional callback for [DpadEvent]s.
  ///
  /// Returns `true` if a listener is assigned, even if there is an active
  /// listener previously assigned with the [assignButtonListener] method,
  /// `false` if all those possible listeners of a [DpadHandler] are set to
  /// `null`. In order to reset the [Dpad] event listener, [assignDpadListener]
  /// needs to be called without specifying anything.
  bool assignDpadListener({Dpad? onEvent}) {
    return DpadHandler.assignMotionEvent(onEvent);
  }

  /// Assigns an event listener to a gamepad's joystick.
  ///
  /// [hand] is the joystick to which the listener will be assigned.
  /// [onEvent] is an optional callback for [JoystickEvent]s.
  ///
  /// Returns `true` if the listener is assigned, `false` if the listener was
  /// set to `null`. In order to reset the [Joystick] event listener,
  /// [assignJoystickListener] needs to be called only specifying a [hand].
  bool assignJoystickListener(Hand hand, {Joystick? onEvent}) {
    return Handler.joystick(hand).assignMotionEvent(onEvent);
  }

  /// Assigns an event listener to a gamepad's trigger.
  ///
  /// [hand] is the trigger to which the listener will be assigned.
  /// [onEvent] is an optional callback for [TriggerEvent]s.
  ///
  /// Returns `true` if the listener is assigned, even if there is an active
  /// listener previously assigned with the [assignButtonListener] method,
  /// `false` if the other possible listener for the trigger in [TriggerHandler]
  /// is also set to `null`. In order to reset the [Trigger] event listener,
  /// [assignTriggerListener] needs to be called only specifying a [hand].
  bool assignTriggerListener(Hand hand, {Trigger? onEvent}) {
    return Handler.trigger(hand).assignMotionEvent(onEvent);
  }

  /// Resets all control listeners to their default state.
  ///
  /// This method clears all the listeners assigned to buttons, dpad, joysticks,
  /// and triggers. After calling this method, no listeners will be active for
  /// any gamepad input. This can be useful when switching between different
  /// screens or game states where numerous input handlings need to be restored.
  ///
  /// To reassign listeners, use the corresponding assign methods for each
  /// control.
  void resetControls() {
    for (final value in Button.values) {
      assignButtonListener(value);
    }
    assignDpadListener();
    assignJoystickListener(Hand.left);
    assignJoystickListener(Hand.right);
    assignTriggerListener(Hand.left);
    assignTriggerListener(Hand.right);
  }
}

/// A subclass of [Gamepad] for managing gamepad inputs in a Flutter application
/// with some additional features to disable inputs to usually be sent to a game
/// server.
///
/// The [NetworkGamepad] class extends the [Gamepad] class and provides methods
/// for automatically blocking transmissions on the platform-specific code. This
/// can be useful when you need to ensure that no input events are transmitted,
/// for example, when the current state of the application requires the use of
/// an input which at the same time would be used in the game.
///
/// This class is not meant to be used directly. Use the gamepad reference of
/// the [Connection] class which uses the [instance] of this class to access its
/// methods.
class NetworkGamepad extends Gamepad {
  /// Private constructor to enforce singleton pattern.
  NetworkGamepad._() : super._();

  /// The unique instance of the [NetworkGamepad] class.
  static final instance = NetworkGamepad._();

  /// Stops transmission of a specific [Control].
  ///
  /// This method is useful for directly disabling a specific gamepad control on
  /// the platform, in case the control is never used in the game but only on
  /// the application side. This method ensures that the platform-specific code
  /// will not transmit any events until it is explicitly resumed.
  Future<void> stopTransmission(Control control) {
    return GamepadPlatform.instance.stopControl(control);
  }

  /// Resumes transmission of a specific [Control].
  ///
  /// Both blocked and stopped controls are resumed by calling this method for
  /// the specified [control].
  Future<bool> resumeTransmission(Control control) {
    return GamepadPlatform.instance.resumeControl(control, false);
  }

  /// Switches the screen's brightness of the device to an on or off state.
  ///
  /// This method can be used to dim the light of a screen or turn it back to
  /// its default state, depending on the value of the [state] parameter in
  /// order to be able to prevent screen burns over time. Set [state] to `true`
  /// to turn the screen on, or `false` to turn the screen off.
  ///
  /// Returns `true` if the screen is turned on, `false` otherwise.
  Future<bool> switchScreenBrightness(bool state) {
    return state
        ? GamepadPlatform.instance.turnScreenOn()
        : GamepadPlatform.instance.turnScreenOff();
  }

  /// Safely assigns press and release listeners to a specified [Button].
  ///
  /// [button] is a [Button] to which the listeners will be assigned.
  /// [onPress] is an optional callback for button [Press] events.
  /// [onRelease] is an optional callback for button [Release] events.
  ///
  /// Automatically blocks transmission for the [button] before assigning the
  /// listeners. If listeners are reset by calling [assignButtonListenerSafely],
  /// only specifying a [button], it resumes transmission for the [button] and
  /// only returns true if the button had not already been stopped by the
  /// [stopTransmission] method sometime before.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignButtonListenerSafely(
    Button button, {
    Press? onPress,
    Release? onRelease,
  }) async {
    if (onPress != null || onRelease != null) {
      await GamepadPlatform.instance.blockControl(button);
    }
    if (!assignButtonListener(button, onPress: onPress, onRelease: onRelease)) {
      return await GamepadPlatform.instance.resumeControl(button);
    }
    return null;
  }

  /// Assigns a listener safely to the dpad.
  ///
  /// [onEvent] is an optional callback for [DpadEvent]s.
  ///
  /// Automatically blocks transmission for the dpad before assigning the
  /// listener. If the listener is reset by calling [assignDpadListenerSafely]
  /// without specifying anything, it resumes transmission for the dpad and only
  /// returns true if the dpad had not already been stopped by the
  /// [stopTransmission] method sometime before.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignDpadListenerSafely({Dpad? onEvent}) async {
    if (onEvent != null) {
      await GamepadPlatform.instance.blockControl(Control.dpad);
    }
    if (!assignDpadListener(onEvent: onEvent)) {
      return await GamepadPlatform.instance.resumeControl(Control.dpad);
    }
    return null;
  }

  /// Assigns a listener safely to a joystick.
  ///
  /// [hand] is the joystick to which the listener will be assigned.
  /// [onEvent] is an optional callback for [JoystickEvent]s.
  ///
  /// Automatically blocks transmission for the joystick before assigning the
  /// listener. If the listener is reset by calling
  /// [assignJoystickListenerSafely], only specifying a [hand], it resumes
  /// transmission for the joystick and only returns true if this joystick had
  /// not already been stopped by the [stopTransmission] method sometime before.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignJoystickListenerSafely(
    Hand hand, {
    Joystick? onEvent,
  }) async {
    if (onEvent != null) {
      await GamepadPlatform.instance.blockControl(hand.joystick);
    }
    if (!assignJoystickListener(hand, onEvent: onEvent)) {
      return await GamepadPlatform.instance.resumeControl(hand.joystick);
    }
    return null;
  }

  /// Assigns a listener safely to a trigger.
  ///
  /// [hand] is the trigger to which the listener will be assigned.
  /// [onEvent] is an optional callback for [TriggerEvent]s.
  ///
  /// Automatically blocks transmission for the trigger before assigning the
  /// listener. If the listener is reset by calling
  /// [assignTriggerListenerSafely], only specifying a [hand], it resumes
  /// transmission for the trigger and only returns true if this trigger had not
  /// already been stopped by the [stopTransmission] method sometime before.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignTriggerListenerSafely(
    Hand hand, {
    Trigger? onEvent,
  }) async {
    if (onEvent != null) {
      await GamepadPlatform.instance.blockControl(hand.trigger);
    }
    if (!assignTriggerListener(hand, onEvent: onEvent)) {
      return await GamepadPlatform.instance.resumeControl(hand.trigger);
    }
    return null;
  }

  /// Resets all control listeners to their default state and resumes their
  /// transmission.
  ///
  /// This method clears all the listeners assigned to buttons, dpad, joysticks,
  /// and triggers. After calling this method, no event listeners will be active
  /// for any gamepad input. This can be useful when switching between different
  /// screens or game states where various input handlings need to be restored
  /// to their default and resumed.
  ///
  /// To reassign listeners, use the corresponding assign methods for each
  /// control.
  @override
  void resetControls() {
    super.resetControls();
    for (final value in Control.values) {
      resumeTransmission(value);
    }
  }
}
