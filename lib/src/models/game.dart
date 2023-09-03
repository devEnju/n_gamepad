import 'package:flutter/material.dart';

import '../pages/game_page.dart';

import 'protocol.dart';

abstract class Game {
  Game(
    this.code, {
    this.name,
    this.interfaceColor,
    Duration? screenTimeout,
  }) : screenTimeout = screenTimeout ?? const Duration(seconds: 10);

  final List<int> code;
  final String? name;
  final Color? interfaceColor;
  final Duration screenTimeout;

  late BuildContext context;

  int get states;
  int get updates;

  Game? compareCode(List<int> other) {
    if (code.length != other.length) {
      return null;
    }
    for (int i = 0; i < code.length; i++) {
      if (code[i] != other[i]) return null;
    }
    return this;
  }

  void openPage(StatePacket packet) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GamePage(this, packet),
        ),
      ),
    );
  }

  void closePage() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => Navigator.of(context).popUntil(
        (route) => route.isFirst,
      ),
    );
  }

  Widget buildLayout(StatePacket packet);
}

enum GameEffect {
  rumble,
  sound,
}
