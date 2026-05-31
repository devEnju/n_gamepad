import 'dart:isolate';

import 'package:jni/jni.dart';

import '../../interface/worker.dart';

import 'channel.g.dart';

class AndroidWorker extends WorkerService {
  WorkerConfiguration configuration = const WorkerConfiguration();

  KeyCallback? listener;

  @override
  void workerMethod(SendPort mainSendPort) {
    final implementer = JImplementer();

    KeyCallback.implementIn(
      implementer,
      $KeyCallback(
        onKeyEvent: (keyCode, action) {
          mainSendPort.send([keyCode, action]);
        },
      ),
    );

    listener = GamepadChannel.assignKeyCallback(
      implementer.implement<KeyCallback>(),
    );
  }

  @override
  void dispose() {
    listener?.release();
  }

  @override
  void handleCommand(WorkerCommand command) {
    if (command is WorkerConfiguration) {
      configuration = command;
    }
    if (command is StopWorker) {
      dispose();
    }
  }
}
