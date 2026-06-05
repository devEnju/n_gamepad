import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  final exampleRoot = packageRoot.resolve('example');

  Config generateConfig(Iterable<String> input, String output) => Config(
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: packageRoot.resolve('lib/platform/$output.g.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    androidSdkConfig: AndroidSdkConfig(
      addGradleDeps: true,
      androidExample: exampleRoot.toFilePath(),
    ),
    sourcePath: [packageRoot.resolve('android/src/main/java')],
    classes: input
        .map((element) => 'com.marvinvogl.n_gamepad.$element')
        .toList(),
  );

  generateJniBindings(
    generateConfig([
      'GamepadChannel',
      'KeyCallable',
      'MotionCallable',
    ], 'channel'),
  );

  generateJniBindings(
    generateConfig([
      'GamepadBridge',
    ], 'bridge'),
  );
}
