import '../../interface/worker.dart';

import 'input_service.dart';

class StreamService extends InputService {
  @override
  Stream<WorkerMessage> start(void Function(Bootstrap) function) {
    return super.start(_workerMain);
  }
}

void _workerMain(Bootstrap bootstrap) {
  final (_, _) = workerMain(bootstrap);
}
