import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game.dart';
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
  late bool _screen;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initTimer();
  }

  void _initTimer() {
    _screen = true;
    _timer = Timer(
      widget.game.screenTimeout,
      () => _switchScreenBrightness(false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _screen ? _setTimer : _resetTimer,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: widget.game.interfaceColor,
        body: StreamBuilder<StatePacket>(
          initialData: widget.initial,
          stream: Connection.service.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return widget.game.buildLayout(snapshot.data!);
            }
            return ErrorWidget.withDetails(
              message: 'stream is null',
            );
          },
        ),
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
    _timer.cancel();
    Connection.service.reset();
    WidgetsBinding.instance.removeObserver(this);
    Connection.gamepad.switchScreenBrightness(true);
    Connection.gamepad.resetControls();
    super.dispose();
  }

  void _setTimer(PointerDownEvent details) {
    _timer.cancel();
    _initTimer();
  }

  void _resetTimer(PointerDownEvent details) {
    _switchScreenBrightness(true);

    _setTimer(details);
  }

  Future<void> _switchScreenBrightness(bool state) async {
    _screen = await Connection.gamepad.switchScreenBrightness(state);
    setState(() {});
  }
}
