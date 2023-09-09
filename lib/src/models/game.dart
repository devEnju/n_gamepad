import 'package:flutter/material.dart';

import '../pages/game_page.dart';

import 'layout.dart';
import 'protocol.dart';

abstract class Game {
  Game(
    this.code, {
    this.name,
  });

  final List<int> code;
  final String? name;

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

  LayoutData buildLayout(StatePacket packet);
}

enum GameEffect {
  light,
  rumble,
  sound,
}
