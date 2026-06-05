import 'package:jni/jni.dart';

import '../../interface/worker.dart';

import 'channel.g.dart';

class AndroidWorker extends WorkerService {
  WorkerConfiguration configuration = const WorkerConfiguration();

  late final KeyCallable? listener;

  @override
  void workerMethod(WorkerGamepad Function() init) {
    final implementer = JImplementer();

    KeyCallable.implementIn(
      implementer,
      $KeyCallable(
        callback: (id, keyCode, action) {
          // TODO
          // instantiation of WorkerGamepad for ID if not already existing
          // state update for that specific gamepad
          // instantiation only happens with lambda to ensure normal or network mode
          // network mode has WorkerGamepad with Network instances for button, joystick, etc.

          // port.send([keyCode, action]);
        },
      ),
    );

    listener = GamepadChannel.assignKeyCallable(
      implementer.implement<KeyCallable>(),
    );
  }

  @override
  void dispose() {
    listener?.release();
  }
}
