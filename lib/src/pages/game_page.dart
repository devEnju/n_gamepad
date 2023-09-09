import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/layout.dart';
import '../models/protocol.dart';

import '../connection.dart';

class GamePage extends StatefulWidget {
  const GamePage(this.game, this.initial, {super.key});

  final Game game;
  final StatePacket initial;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  late StatePacket previous;
  ObservableTimer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    previous = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<StatePacket>(
        initialData: widget.initial,
        stream: Connection.service.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final current = snapshot.data!;

            final layout = widget.game.buildLayout(current);

            if (layout.screenTimeout == null) {
              timer?.cancel();
              timer = null;
            } else if (timer == null) {
              timer = ObservableTimer(
                layout.screenTimeout!.onInteraction,
                () => Connection.gamepad.switchScreenBrightness(false),
                () => Connection.gamepad.switchScreenBrightness(true),
              );
            } else if (previous != current) {
              resetTimer(layout.screenTimeout!.onStateChange);
            } else {
              resetTimer(layout.screenTimeout!.onStateUpdate);
            }
            previous = current;

            return Listener(
              onPointerDown: (event) => cancelTimer(layout.screenTimeout),
              onPointerUp: (event) => startTimer(layout.screenTimeout),
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: layout.backgroundColor,
                child: layout.widget,
              ),
            );
          }
          return ErrorWidget.withDetails(
            message: 'stream is null',
          );
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    }
  }

  @override
  void dispose() {
    Connection.service.reset();
    WidgetsBinding.instance.removeObserver(this);
    Connection.gamepad.switchScreenBrightness(true);
    Connection.gamepad.resetControls();
    super.dispose();
  }

  void resetTimer(Duration? duration) {
    if (duration != null) timer!.reset(duration);
  }

  void cancelTimer(ScreenTimeout? timeout) {
    if (timeout != null) timer!.cancel();
  }

  void startTimer(ScreenTimeout? timeout) {
    if (timeout != null) timer!.start(timeout.onInteraction);
  }
}

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
