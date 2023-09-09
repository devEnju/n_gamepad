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
  late Stopwatch watch;
  late Duration limit;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    previous = widget.initial;
    watch = Stopwatch();
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
              stopTimer();
              timer = null;
            } else if (timer == null) {
              startTimer(layout.screenTimeout!.onInteraction);
            } else if (previous != current) {
              resetTimer(layout.screenTimeout?.onStateChange);
            } else {
              resetTimer(layout.screenTimeout?.onStateUpdate);
            }
            previous = current;

            return Listener(
              onPointerDown: (event) => cancelTimer(layout.screenTimeout),
              onPointerUp: (event) => setTimer(layout.screenTimeout),
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
    if (duration != null && duration > limit - watch.elapsed) {
      stopTimer();
      startTimer(duration);
    }
  }

  void cancelTimer(ScreenTimeout? timeout) {
    if (timeout != null) stopTimer();
  }

  void setTimer(ScreenTimeout? timeout) {
    if (timeout != null) startTimer(timeout.onInteraction);
  }

  void stopTimer() {
    timer?.cancel();
    watch.stop();
    watch.reset();

    if (timer?.isActive == false) {
      Connection.gamepad.switchScreenBrightness(true);
    }
  }

  void startTimer(Duration duration) {
    watch.start();
    limit = duration;
    timer = Timer(
      duration,
      () => Connection.gamepad.switchScreenBrightness(false),
    );
  }
}
