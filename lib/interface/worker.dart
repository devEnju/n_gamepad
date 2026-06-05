import 'dart:isolate';

abstract class WorkerService {
  void workerMethod(WorkerGamepad Function() init);

  void dispose();
}

// TODO
// all the previous event channel data will be modeled with this class
sealed class WorkerMessage {
  const WorkerMessage();
}

class WorkerData extends WorkerMessage {
  const WorkerData(this.values);

  final List<int> values;
}

// TODO
// will contain all the commands for the NetworkGamepad to safely block controls
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

// TODO
// holds different objects for button, joystick, etc.
// there is one class for normal and one for network capabilities
// those implementations have generic interface for events to expect from platforms
class WorkerGamepad {
  const WorkerGamepad(this.port);

  final SendPort port;
}
