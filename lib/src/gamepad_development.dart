import 'dart:io';

import 'package:n_gamepad/n_gamepad_platform_interface.dart';

class GamepadDevelopment extends GamepadPlatform {
  static void registerWith() {
    GamepadPlatform.instance = GamepadDevelopment();
  }

  @override
  Future<void> setAddress(InternetAddress connection) async {}

  @override
  Future<void> resetAddress() async {}

  @override
  Future<void> stopControl(Enum control) async {}

  @override
  Future<void> blockControl(Enum control) async {}

  @override
  Future<bool> resumeControl(Enum control, [bool safe = true]) async => true;

  @override
  Future<bool> turnScreenOn() async => true;
  
  @override
  Future<bool> turnScreenOff() async => false;
}