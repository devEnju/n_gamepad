import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n_gamepad/n_gamepad.dart';
import 'package:n_gamepad/n_gamepad_platform_interface.dart';
import 'package:n_gamepad/n_gamepad_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGamepadPlatform
    with MockPlatformInterfaceMixin
    implements GamepadPlatform {
  @override
  Future<void> setAddress(InternetAddress connection) async {}

  @override
  Future<void> resetAddress() async {}

  @override
  Future<void> stopControl(Enum control) async {}

  @override
  Future<void> blockControl(Enum control) async {}

  @override
  Future<bool> resumeControl(Enum control, [bool block = true]) async => true;

  @override
  Future<bool> turnScreenOn() async => true;

  @override
  Future<bool> turnScreenOff() async => false;

  @override
  Stream<DpadEvent> get dpadEvents => throw UnimplementedError();

  @override
  Stream<JoystickEvent> get joystickLeftEvents => throw UnimplementedError();

  @override
  Stream<JoystickEvent> get joystickRightEvents => throw UnimplementedError();

  @override
  Stream<TriggerEvent> get triggerLeftEvents => throw UnimplementedError();

  @override
  Stream<TriggerEvent> get triggerRightEvents => throw UnimplementedError();
}

void main() {
  final GamepadPlatform initialPlatform = GamepadPlatform.instance;

  test('$MethodChannelGamepad is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGamepad>());
  });

  test('turnScreenOn', () async {
    MockGamepadPlatform fakePlatform = MockGamepadPlatform();
    GamepadPlatform.instance = fakePlatform;

    expect(await Connection.gamepad.switchScreenBrightness(true), true);
  });

  test('turnScreenOff', () async {
    MockGamepadPlatform fakePlatform = MockGamepadPlatform();
    GamepadPlatform.instance = fakePlatform;

    expect(await Connection.gamepad.switchScreenBrightness(false), false);
  });
}
