import 'package:flutter_test/flutter_test.dart';

import 'package:n_gamepad/n_gamepad.dart';
import 'package:n_gamepad/n_gamepad_platform_interface.dart';
import 'package:n_gamepad/n_gamepad_method_channel.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGamepadPlatform extends GamepadPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<bool> turnScreenOn() async => true;

  @override
  Future<bool> turnScreenOff() async => false;
}

void main() {
  final GamepadPlatform initialPlatform = GamepadPlatform.instance;

  test('MethodChannelGamepad is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGamepad>());
  });

  group('Selected method channel function test', () {
    setUp(() {
      final fakePlatform = MockGamepadPlatform();
      GamepadPlatform.instance = fakePlatform;
    });

    test('turnScreenOn returns true after finishing', () async {
      expect(await Connection.gamepad.switchScreenBrightness(true), true);
    });

    test('turnScreenOff returns false after finishing', () async {
      expect(await Connection.gamepad.switchScreenBrightness(false), false);
    });
  });
}
