import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_gamepad/n_gamepad_method_channel.dart';

void main() {
  MethodChannelGamepad platform = MethodChannelGamepad();
  const MethodChannel channel = MethodChannel('com.marvinvogl.n_gamepad/method');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('turnScreenOn', () async {
    expect(await platform.turnScreenOn(), true);
  });
}
