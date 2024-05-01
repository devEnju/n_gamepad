import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/models/control.dart';

import 'n_gamepad_method_channel.dart';

/// The common platform interface for gamepads.
abstract class GamepadPlatform extends PlatformInterface {
  /// Constructs a GamepadPlatform.
  GamepadPlatform() : super(token: _token);

  static final Object _token = Object();

  static GamepadPlatform _instance = MethodChannelGamepad();

  /// The default instance of [GamepadPlatform] to use.
  ///
  /// Defaults to [MethodChannelGamepad].
  static GamepadPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GamepadPlatform] when they register themselves.
  static set instance(GamepadPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// A method to set an internet address on the platform.
  Future<void> setAddress(InternetAddress connection) {
    throw UnimplementedError('setAddress() has not been implemented.');
  }

  /// A method to reset a previously set internet address on the platform.
  Future<void> resetAddress() {
    throw UnimplementedError('resetAddress() has not been implemented.');
  }

  /// A method to completely stop control transmissions to a previously set
  /// internet address on the platform.
  Future<void> stopControl(Enum control) {
    throw UnimplementedError('stopControl() has not been implemented.');
  }

  /// A method to temporarily block control transmissions to a previously set
  /// internet address on the platform.
  Future<void> blockControl(Enum control) {
    throw UnimplementedError('blockControl() has not been implemented.');
  }

  /// A method to either resume safe and therefore blocked or stopped control
  /// transmissions to a previously set internet address on the platform.
  ///
  /// Returns `true` if the control is resumed, otherwise `false`.
  Future<bool> resumeControl(Enum control, [bool safe = true]) {
    throw UnimplementedError('resumeControl() has not been implemented.');
  }

  /// A method to turn the screen's brightness of the device to the user's
  /// defaults.
  ///
  /// Returns `true` if the device's screen is bright.
  Future<bool> turnScreenOn() {
    throw UnimplementedError('turnScreenOn() has not been implemented.');
  }

  /// A method to turn the screen's brightness of the device to lowest setting
  /// possible.
  ///
  /// Returns `false` if the device's screen is dimmed.
  Future<bool> turnScreenOff() {
    throw UnimplementedError('turnScreenOff() has not been implemented.');
  }

  /// A broadcast stream of events from a button of a gamepad.
  Stream<ButtonEvent> get buttonEvents {
    throw UnimplementedError('buttonEvents has not been implemented.');
  }

  /// A broadcast stream of events from the dpad of a gamepad.
  Stream<DpadEvent> get dpadEvents {
    throw UnimplementedError('dpadEvents has not been implemented.');
  }

  /// A broadcast stream of events from a joystick of a gamepad.
  Stream<JoystickEvent> get joystickEvents {
    throw UnimplementedError('joystickEvents has not been implemented.');
  }

  /// A broadcast stream of events from a trigger of a gamepad.
  Stream<TriggerEvent> get triggerEvents {
    throw UnimplementedError('triggerEvents has not been implemented.');
  }
}
