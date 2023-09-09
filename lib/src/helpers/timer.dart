import 'dart:async';

class ObservableTimer {
  ObservableTimer(
    this._duration,
    this._onEnd,
    this._onCancel,
  ) : _watch = Stopwatch() {
    start(_duration);
  }

  final void Function() _onEnd;
  final void Function() _onCancel;
  final Stopwatch _watch;

  Duration _duration;

  late Timer _timer;

  void start(Duration duration) {
    _duration = duration;
    _watch.start();
    _timer = Timer(_duration, _onEnd);
  }

  void cancel() {
    if (!_timer.isActive) _onCancel.call();

    _timer.cancel();
    _watch.stop();
    _watch.reset();
  }

  void reset(Duration duration) {
    if (_duration - _watch.elapsed < duration) {
      cancel();
      start(duration);
    }
  }
}
