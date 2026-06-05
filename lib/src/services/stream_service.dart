import '../../interface/worker.dart';

import 'input_service.dart';

class StreamService extends InputService {
  @override
  Stream<WorkerMessage> start(void Function(Bootstrap) function) {
    return super.start(_workerMain);
  }
}

void _workerMain(Bootstrap bootstrap) {
  final (receiver, port, service) = workerMain(bootstrap);

  service.workerMethod(() => WorkerGamepad(port));

  receiver.listen((dynamic command) => _workerListener(command, service));
}

void _workerListener(dynamic command, WorkerService service) {
  workerListener(command, service);

  // TODO
  // implement all the commands for the NetworkGamepad functionality
}
