import 'dart:isolate';

abstract class WorkerService {
  void workerMethod(SendPort mainSendPort);

  void handleCommand(WorkerCommand command) {}

  void dispose() {}
}

abstract class WorkerMessage {
  const WorkerMessage();
}

class WorkerStarted extends WorkerMessage {
  const WorkerStarted(this.sendPort);

  final SendPort sendPort;
}

class WorkerData extends WorkerMessage {
  const WorkerData(this.values);

  final List<int> values;
}

abstract class WorkerCommand {
  const WorkerCommand();
}

class WorkerConfiguration extends WorkerCommand {
  const WorkerConfiguration({this.enabled = true});

  final bool enabled;
}

class StopWorker extends WorkerCommand {
  const StopWorker();
}
