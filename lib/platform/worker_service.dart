import 'dart:isolate';

import 'package:jni/jni.dart';

import '../../interface/worker.dart';

import 'channel.g.dart';

class AndroidWorker extends WorkerService {
  WorkerConfiguration configuration = const WorkerConfiguration();

  KeyEventListener? listener;

  @override
  void workerMethod(SendPort mainSendPort) {
    final implementer = JImplementer();

    KeyEventListener.implementIn(
      implementer,
      $KeyEventListener(
        onKeyEvent: (keyCode, action) {
          mainSendPort.send([keyCode, action]);
        },
      ),
    );

    listener = GamepadChannel.assignListener(
      implementer.implement<KeyEventListener>(),
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
