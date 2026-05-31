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
    if (message is WorkerStarted) {
      _port = message.sendPort;
    } else if (message is WorkerData) {
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
  workerMain(bootstrap);
}

(SendPort, WorkerService) workerMain(Bootstrap bootstrap) {
  final (port, worker) = bootstrap;

  final receiver = ReceivePort();
  final service = worker();

  port.send(WorkerStarted(receiver.sendPort));

  late StreamSubscription<dynamic> subscription;

  subscription = receiver.listen((dynamic message) {
    if (message is WorkerCommand) {
      service.handleCommand(message);
    }
    if (message is StopWorker) {
      subscription.cancel();
      receiver.close();
    }
  });

  service.workerMethod(port);

  return (port, service);
}
