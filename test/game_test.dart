import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:n_gamepad/src/models/game.dart';
import 'package:n_gamepad/src/models/layout.dart';
import 'package:n_gamepad/src/models/protocol.dart';

class MockGame extends Game {
  MockGame(super.code);

  @override
  int get states => 4;

  @override
  int get updates => 2;

  @override
  void openPage(StatePacket packet) {}

  @override
  void closePage() {}

  @override
  Layout buildLayout(StatePacket packet) => const Layout(widget: Placeholder());
}

void main() {
  late MockGame game;

  setUp(() {
    game = MockGame([1, 1, 1]);
  });

  test(
    'Comparing smaller sized code array with compare Code',
    () {
      final value = game.compareCode([1, 1]);

      expect(value, null);
    },
  );

  test(
    'Comparing greater sized code array with compare Code',
    () {
      final value = game.compareCode([1, 1, 1, 1]);

      expect(value, null);
    },
  );

  test(
    'Comparing different code array with compare Code',
    () {
      final value = game.compareCode([0, 0, 0]);

      expect(value, null);
    },
  );

  test(
    'Comparing same code array with compare Code',
    () {
      final value = game.compareCode([1, 1, 1]);

      expect(value, game);
    },
  );
}
