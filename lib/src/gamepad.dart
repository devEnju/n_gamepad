import 'dart:async';

import '../n_gamepad_platform_interface.dart';

import 'models/control.dart';

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
  /// [button] is a [Button] to which the listeners will be assigned.
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
    final handler = button.key != null
        ? ButtonHandler.map[button.key]!
        : DpadHandler.map[button]!;

    return handler.assignKeyEvent(onPress, onRelease);
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

  /// Assigns an event listener to the gamepad's left joystick.
  ///
  /// [onEvent] is an optional callback for left [JoystickEvent]s.
  ///
  /// Returns `true` if the listener is assigned, `false` if the listener was
  /// set to `null`. In order to reset the left [Joystick] event listener,
  /// [assignLeftJoystickListener] needs to be called without specifying
  /// anything.
  bool assignLeftJoystickListener({Joystick? onEvent}) {
    return JoystickHandler.left.assignMotionEvent(onEvent);
  }

  /// Assigns an event listener to the gamepad's right joystick.
  ///
  /// [onEvent] is an optional callback for right [JoystickEvent]s.
  ///
  /// Returns `true` if the listener is assigned, `false` if the listener was
  /// set to `null`. In order to reset the right [Joystick] event listener,
  /// [assignRightJoystickListener] needs to be called without specifying
  /// anything.
  bool assignRightJoystickListener({Joystick? onEvent}) {
    return JoystickHandler.right.assignMotionEvent(onEvent);
  }

  /// Assigns an event listener to the gamepad's left trigger.
  ///
  /// [onEvent] is an optional callback for left [TriggerEvent]s.
  ///
  /// Returns `true` if the listener is assigned, even if there is an active
  /// listener previously assigned with the [assignButtonListener] method,
  /// `false` if the other possible listener for the left trigger in
  /// [TriggerHandler] is also set to `null`. In order to reset the left
  /// [Trigger] event listener, [assignLeftTriggerListener] needs to be called
  /// without specifying anything.
  bool assignLeftTriggerListener({Trigger? onEvent}) {
    return TriggerHandler.left.assignMotionEvent(onEvent);
  }

  /// Assigns an event listener to the gamepad's right trigger.
  ///
  /// [onEvent] is an optional callback for right [TriggerEvent]s.
  ///
  /// Returns `true` if the listener is assigned, even if there is an active
  /// listener previously assigned with the [assignButtonListener] method,
  /// `false` if the other possible listener for the right trigger in
  /// [TriggerHandler] is also set to `null`. In order to reset the right
  /// [Trigger] event listener, [assignRightTriggerListener] needs to be called
  /// without specifying anything.
  bool assignRightTriggerListener({Trigger? onEvent}) {
    return TriggerHandler.right.assignMotionEvent(onEvent);
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
    assignLeftJoystickListener();
    assignRightJoystickListener();
    assignLeftTriggerListener();
    assignRightTriggerListener();
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

  /// Assigns a listener safely to the left joystick.
  ///
  /// [onEvent] is an optional callback for [JoystickEvent]s.
  ///
  /// Automatically blocks transmission for the left joystick before assigning
  /// the listener. If the listener is reset by calling
  /// [assignLeftJoystickListenerSafely]  without specifying anything, it
  /// resumes transmission for the left joystick and only returns true if the
  /// left joystick had not already been stopped by the [stopTransmission]
  /// method sometime before.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignLeftJoystickListenerSafely({Joystick? onEvent}) async {
    if (onEvent != null) {
      await GamepadPlatform.instance.blockControl(Control.jl);
    }
    if (!assignLeftJoystickListener(onEvent: onEvent)) {
      return await GamepadPlatform.instance.resumeControl(Control.jl);
    }
    return null;
  }

  /// Assigns a listener safely to the right joystick.
  ///
  /// [onEvent] is an optional callback for [JoystickEvent]s.
  ///
  /// Automatically blocks transmission for the right joystick before assigning
  /// the listener. If the listener is reset by calling
  /// [assignRightJoystickListenerSafely]  without specifying anything, it
  /// resumes transmission for the right joystick and only returns true if the
  /// right joystick had not already been stopped by the [stopTransmission]
  /// method sometime before.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignRightJoystickListenerSafely({Joystick? onEvent}) async {
    if (onEvent != null) {
      await GamepadPlatform.instance.blockControl(Control.jr);
    }
    if (!assignRightJoystickListener(onEvent: onEvent)) {
      return await GamepadPlatform.instance.resumeControl(Control.jr);
    }
    return null;
  }

  /// Assigns a listener safely to the left trigger.
  ///
  /// [onEvent] is an optional callback for [TriggerEvent]s.
  ///
  /// Automatically blocks transmission for the left trigger before assigning
  /// the listener. If the listener is reset by calling
  /// [assignLeftTriggerListenerSafely]  without specifying anything, it
  /// resumes transmission for the left trigger and only returns true if the
  /// left trigger had not already been stopped by the [stopTransmission] method
  /// sometime before.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignLeftTriggerListenerSafely({Trigger? onEvent}) async {
    if (onEvent != null) {
      await GamepadPlatform.instance.blockControl(Control.zl);
    }
    if (!assignLeftTriggerListener(onEvent: onEvent)) {
      return await GamepadPlatform.instance.resumeControl(Control.zl);
    }
    return null;
  }

  /// Assigns a listener safely to the right trigger.
  ///
  /// [onEvent] is an optional callback for [TriggerEvent]s.
  ///
  /// Automatically blocks transmission for the right trigger before assigning
  /// the listener. If the listener is reset by calling
  /// [assignRightTriggerListenerSafely]  without specifying anything, it
  /// resumes transmission for the right trigger and only returns true if the
  /// right trigger had not already been before by the [stopTransmission] method
  /// stopped sometime.
  ///
  /// Returns null if the control could not be resumed because there are still
  /// listeners assigned to it.
  Future<bool?> assignRightTriggerListenerSafely({Trigger? onEvent}) async {
    if (onEvent != null) {
      await GamepadPlatform.instance.blockControl(Control.zr);
    }
    if (!assignRightTriggerListener(onEvent: onEvent)) {
      return await GamepadPlatform.instance.resumeControl(Control.zr);
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
