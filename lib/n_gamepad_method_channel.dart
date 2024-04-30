import 'dart:io';

import 'package:flutter/services.dart';

import 'src/models/control.dart';

import 'n_gamepad_platform_interface.dart';

/// An implementation of [GamepadPlatform] that uses method channels.
class MethodChannelGamepad extends GamepadPlatform {
  /// The method channel used to interact with the native platform.
  static const methodChannel = MethodChannel('com.marvinvogl.n_gamepad/method');

  /// The event channel to receive dpad events with the native platform.
  static const dpadChannel = EventChannel('com.marvinvogl.n_gamepad/dpad');

  /// The event channel to receive left joystick events with the native
  /// platform.
  static const joystickLeftChannel =
      EventChannel('com.marvinvogl.n_gamepad/joystick_left');

  /// The event channel to receive right joystick events with the native
  /// platform.
  static const joystickRightChannel =
      EventChannel('com.marvinvogl.n_gamepad/joystick_right');

  /// The event channel to receive left trigger events with the native platform.
  static const triggerLeftChannel =
      EventChannel('com.marvinvogl.n_gamepad/trigger_left');

  /// The event channel to receive right trigger events with the native
  /// platform.
  static const triggerRightChannel =
      EventChannel('com.marvinvogl.n_gamepad/trigger_right');

  Stream<DpadEvent>? _dpadEvents;
  Stream<JoystickEvent>? _joystickLeftEvents;
  Stream<JoystickEvent>? _joystickRightEvents;
  Stream<TriggerEvent>? _triggerLeftEvents;
  Stream<TriggerEvent>? _triggerRightEvents;

  /// A method to set an internet address on the platform.
  @override
  Future<void> setAddress(InternetAddress connection) async {
    await methodChannel.invokeMethod(
      'set_address',
      <String, dynamic>{
        'address': connection.address,
        'port': 44700,
      },
    );
  }

  /// A method to reset a previously set internet address on the platform.
  @override
  Future<void> resetAddress() async {
    await methodChannel.invokeMethod('reset_address');
  }

  /// A method to completely stop control transmissions to a previously set
  /// internet address on the platform.
  @override
  Future<void> stopControl(Enum control) async {
    await methodChannel.invokeMethod(
      'stop_control',
      <String, dynamic>{
        'control': control.name,
      },
    );
  }

  /// A method to temporarily block control transmissions to a previously set
  /// internet address on the platform.
  @override
  Future<void> blockControl(Enum control) async {
    await methodChannel.invokeMethod(
      'block_control',
      <String, dynamic>{
        'control': control.name,
      },
    );
  }

  /// A method to either resume safe and therefore blocked or stopped control
  /// transmissions to a previously set internet address on the platform.
  ///
  /// Returns `true` if the control is resumed, otherwise `false`.
  @override
  Future<bool> resumeControl(Enum control, [bool safe = true]) {
    return methodChannel.invokeMethod(
      'resume_control',
      <String, dynamic>{
        'control': control.name,
        'safe': safe,
      },
    ).then<bool>((value) => value);
  }

  /// A method to turn the screen's brightness of the device to the user's
  /// defaults.
  ///
  /// Returns `true` if the device's screen is bright.
  @override
  Future<bool> turnScreenOn() {
    return methodChannel
        .invokeMethod('turn_screen_on')
        .then<bool>((value) => value);
  }

  /// A method to turn the screen's brightness of the device to lowest setting
  /// possible.
  ///
  /// Returns `false` if the device's screen is dimmed.
  @override
  Future<bool> turnScreenOff() {
    return methodChannel
        .invokeMethod('turn_screen_off')
        .then<bool>((value) => value);
  }

  /// A broadcast stream of events from the dpad of a gamepad.
  @override
  Stream<DpadEvent> get dpadEvents {
    _dpadEvents ??= dpadChannel
        .receiveBroadcastStream()
        .map((event) => DpadEvent(event[0], event[1], event[2]));
    return _dpadEvents!;
  }

  /// A broadcast stream of events from the left joystick of a gamepad.
  @override
  Stream<JoystickEvent> get joystickLeftEvents {
    _joystickLeftEvents ??= joystickLeftChannel
        .receiveBroadcastStream()
        .map((event) => JoystickEvent(event[0], event[1], event[2]));
    return _joystickLeftEvents!;
  }

  /// A broadcast stream of events from the right joystick of a gamepad.
  @override
  Stream<JoystickEvent> get joystickRightEvents {
    _joystickRightEvents ??= joystickRightChannel
        .receiveBroadcastStream()
        .map((event) => JoystickEvent(event[0], event[1], event[2]));
    return _joystickRightEvents!;
  }

  /// A broadcast stream of events from the left trigger of a gamepad.
  @override
  Stream<TriggerEvent> get triggerLeftEvents {
    _triggerLeftEvents ??= triggerLeftChannel
        .receiveBroadcastStream()
        .map((event) => TriggerEvent(event[0], event[1]));
    return _triggerLeftEvents!;
  }

  /// A broadcast stream of events from the right trigger of a gamepad.
  @override
  Stream<TriggerEvent> get triggerRightEvents {
    _triggerRightEvents ??= triggerRightChannel
        .receiveBroadcastStream()
        .map((event) => TriggerEvent(event[0], event[1]));
    return _triggerRightEvents!;
  }
}
