import 'dart:async';
import 'dart:isolate';

import '../../interface/worker.dart';
import '../../n_gamepad_platform_interface.dart';

typedef Bootstrap = (SendPort, WorkerService Function());

class InputService {
  InputService() : _worker = GamepadPlatform.instance.instantiateWorker() {
    start(_workerMain);
  }

  final WorkerService Function() _worker;

  Isolate? _isolate;
  ReceivePort? _receiver;
  SendPort? _port;
  StreamController<WorkerMessage>? _controller;

  static InputService? instance;

  Stream<WorkerMessage> start(void Function(Bootstrap) function) {
    _receiver = ReceivePort();
    _controller = StreamController<WorkerMessage>();

    _receiver!.listen((message) {
      if (message is WorkerMessage) {
        _receiveMessage(message);
      } else if (message is SendPort) {
        _port = message;
      } else {
        _controller!.addError(ArgumentError.value(message, 'message'));
      }
    });

    Isolate.spawn(
      function,
      (_receiver!.sendPort, _worker)
    ).then((isolate) {
      _isolate = isolate;
    });

    return _controller!.stream;
  }

  void _receiveMessage(WorkerMessage message) {
    if (message is WorkerData) {
      _controller!.add(message);
    }
  }

  void dispose() {
    _port?.send(const StopWorker());
    _receiver?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _controller?.close();

    _port = null;
    _receiver = null;
    _isolate = null;
    _controller = null;
  }
}

void _workerMain(Bootstrap bootstrap) {
  final (receiver, port, service) = workerMain(bootstrap);

  service.workerMethod(() => WorkerGamepad(port));

  receiver.listen((dynamic command) => workerListener(command, service));
}

void workerListener(dynamic command, WorkerService service) {
  if (command is StopWorker) {
    service.dispose();
    Isolate.exit();
  }
}

(ReceivePort, SendPort, WorkerService) workerMain(Bootstrap bootstrap) {
  final (port, worker) = bootstrap;

  final receiver = ReceivePort();
  final service = worker();

  port.send(receiver.sendPort);

  return (receiver, port, service);
}
