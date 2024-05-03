import 'dart:io';

import 'package:flutter/services.dart';

import 'src/models/handler.dart';

import 'n_gamepad_platform_interface.dart';

/// An implementation of [GamepadPlatform] that uses method channels.
class MethodChannelGamepad extends GamepadPlatform {
  /// The method channel used to interact with the native platform.
  static const methodChannel = MethodChannel('com.marvinvogl.n_gamepad/method');

  /// The event channel to receive button events from the native platform.
  static const buttonChannel = EventChannel('com.marvinvogl.n_gamepad/button');

  /// The event channel to receive dpad events from the native platform.
  static const dpadChannel = EventChannel('com.marvinvogl.n_gamepad/dpad');

  /// The event channel to receive joystick events from the native platform.
  static const joystickChannel =
      EventChannel('com.marvinvogl.n_gamepad/joystick');

  /// The event channel to receive trigger events from the native platform.
  static const triggerChannel =
      EventChannel('com.marvinvogl.n_gamepad/trigger');

  Stream<ButtonEvent>? _buttonEvents;
  Stream<DpadEvent>? _dpadEvents;
  Stream<JoystickEvent>? _joystickEvents;
  Stream<TriggerEvent>? _triggerEvents;

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
        .map((list) => DpadEvent(list[0], list[1], list[2]));
    return _dpadEvents!;
  }

  /// A broadcast stream of events from a button of a gamepad.
  @override
  Stream<ButtonEvent> get buttonEvents {
    _buttonEvents ??= buttonChannel
        .receiveBroadcastStream()
        .map((list) => ButtonEvent(list[0], list[1], list[2]));
    return _buttonEvents!;
  }

  /// A broadcast stream of events from a joystick of a gamepad.
  @override
  Stream<JoystickEvent> get joystickEvents {
    _joystickEvents ??= joystickChannel
        .receiveBroadcastStream()
        .map((list) => JoystickEvent(list[0], list[1], list[2], list[3]));
    return _joystickEvents!;
  }

  /// A broadcast stream of events from a trigger of a gamepad.
  @override
  Stream<TriggerEvent> get triggerEvents {
    _triggerEvents ??= triggerChannel
        .receiveBroadcastStream()
        .map((list) => TriggerEvent(list[0], list[1], list[2]));
    return _triggerEvents!;
  }
}
