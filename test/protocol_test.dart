import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:n_gamepad/src/models/game.dart';
import 'package:n_gamepad/src/models/protocol.dart';
import 'package:n_gamepad/src/connection.dart';

import 'game_test.dart';

Datagram connectionDatagram({
  int? message,
  bool? game,
  String? text,
  InternetAddress? address,
}) {
  final data = <int>[];

  if (message != null) data.add(message);

  if (game != null) {
    game ? data.addAll([1, 1, 1]) : data.addAll([0, 0, 0]);
  }

  if (text != null) {
    data.addAll(text.codeUnits);
  }

  return Datagram(
    Uint8List.fromList(data),
    address ?? InternetAddress('192.168.0.2'),
    Connection.port,
  );
}

Datagram gameDatagram({
  int? message,
  int? type,
  InternetAddress? address,
}) {
  final data = <int>[];

  if (message != null) data.add(message);

  if (type != null) data.add(type);

  return Datagram(
    Uint8List.fromList(data),
    address ?? InternetAddress('192.168.0.2'),
    Connection.port,
  );
}

void main() {
  late Game game;

  group('ConnectionPacket data needs to at least have 4 entries', () {
    test(
      'Validating empty packet results into error',
      () {
        final datagram = Datagram(
          Uint8List.fromList([]),
          Connection.loopback,
          Connection.port,
        );

        expect(() => ConnectionPacket.validate(datagram), throwsStateError);
      },
    );

    test(
      'Validating invalid packet results into error',
      () {
        final datagram = Datagram(
          Uint8List.fromList([0, 0, 0]),
          Connection.loopback,
          Connection.port,
        );

        expect(() => ConnectionPacket.validate(datagram), throwsAssertionError);
      },
    );

    test(
      'Validating valid packet returns true',
      () {
        final datagram = Datagram(
          Uint8List.fromList([0, 0, 0, 0]),
          Connection.loopback,
          Connection.port,
        );

        expect(ConnectionPacket.validate(datagram), true);
      },
    );

    test(
      'Initializing invalid packet results into error',
      () {
        final datagram = Datagram(
          Uint8List.fromList([0]),
          Connection.loopback,
          Connection.port,
        );

        expect(() => ConnectionPacket.buffer(datagram), throwsRangeError);
      },
    );

    test(
      'Initializing valid but unknown packet',
      () {
        final packet = ConnectionPacket.buffer(Datagram(
          Uint8List.fromList([0, 0, 0, 0, ...'Hello World'.codeUnits]),
          Connection.loopback,
          Connection.port,
        ));

        expect(packet.address, Connection.loopback);
        expect(packet.message, 0);
        expect(packet.code, [0, 0, 0]);
        expect(packet.data, 'Hello World');
      },
    );

    test(
      'Initializing valid info packet',
      () {
        final packet = ConnectionPacket.buffer(Datagram(
          Uint8List.fromList([Server.info, 0, 0, 0]),
          Connection.loopback,
          Connection.port,
        ));

        expect(packet.address, Connection.loopback);
        expect(packet.message, Server.info);
        expect(packet.code, [0, 0, 0]);
        expect(packet.data, '');
      },
    );

    test(
      'Initializing valid quit packet',
      () {
        final packet = ConnectionPacket.buffer(Datagram(
          Uint8List.fromList([Server.quit, 0, 0, 0]),
          Connection.loopback,
          Connection.port,
        ));

        expect(packet.address, Connection.loopback);
        expect(packet.message, Server.quit);
        expect(packet.code, [0, 0, 0]);
        expect(packet.data, '');
      },
    );

    test(
      'Initializing valid broadcast packet',
      () {
        final packet = ConnectionPacket.buffer(Datagram(
          Uint8List.fromList([Client.broadcast, 0, 0, 0]),
          Connection.loopback,
          Connection.port,
        ));

        expect(packet.address, Connection.loopback);
        expect(packet.message, Client.broadcast);
        expect(packet.code, [0, 0, 0]);
        expect(packet.data, '');
      },
    );

    test(
      'Checking that packet buffer is same instance',
      () {
        final packet = ConnectionPacket.buffer(Datagram(
          Uint8List.fromList([0, 0, 0, 0, ...'Hello World'.codeUnits]),
          Connection.loopback,
          Connection.port,
        ));

        final other = ConnectionPacket.buffer(Datagram(
          Uint8List.fromList([0, 1, 1, 1, ...'Hello World'.codeUnits]),
          Connection.loopback,
          Connection.port,
        ));

        expect(other, packet);
      },
    );
  });

  group('GamePacket data needs to at least have 2 entries', () {
    test(
      'Validating empty packet results into error',
      () {
        final datagram = Datagram(
          Uint8List.fromList([]),
          Connection.loopback,
          Connection.port,
        );

        expect(() => GamePacket.validate(datagram), throwsStateError);
      },
    );

    test(
      'Validating invalid packet results into error',
      () {
        final datagram = Datagram(
          Uint8List.fromList([0]),
          Connection.loopback,
          Connection.port,
        );

        expect(() => GamePacket.validate(datagram), throwsAssertionError);
      },
    );

    test(
      'Validating valid packet returns true',
      () {
        final datagram = Datagram(
          Uint8List.fromList([0, 0]),
          Connection.loopback,
          Connection.port,
        );

        expect(GamePacket.validate(datagram), true);
      },
    );

    test(
      'Initializing invalid packet results into error',
      () {
        final data = [16];

        expect(() => GamePacket.buffer(data), throwsRangeError);
      },
    );

    test(
      'Initializing valid but unknown packet',
      () {
        final packet = GamePacket.buffer([16, 0, 1, 2, 3]);

        expect(packet.message, 16);
        expect(packet.type, 0);
      },
    );

    test(
      'Initializing valid state packet',
      () {
        final packet = GamePacket.buffer([Server.state, 0]);

        expect(packet.message, Server.state);
        expect(packet.type, 0);
      },
    );

    test(
      'Initializing valid update packet',
      () {
        final packet = GamePacket.buffer([Server.update, 0]);

        expect(packet.message, Server.update);
        expect(packet.type, 0);
      },
    );

    test(
      'Initializing valid effect packet',
      () {
        final packet = GamePacket.buffer([Server.effect, 0]);

        expect(packet.message, Server.effect);
        expect(packet.type, 0);
      },
    );

    test(
      'Checking that packet buffer is same instance',
      () {
        final packet = GamePacket.buffer([16, 0, 1, 2, 3]);

        final other = GamePacket.buffer([16, 1, 1, 2, 3]);

        expect(other, packet);
      },
    );
  });

  group('GamePacket derivatives need to have known states', () {
    setUp(() {
      game = MockGame([0, 0, 0]);
    });

    test(
      'Validating unknown state from packet results into error',
      () {
        final packet = GamePacket.buffer([Server.state, 4]);

        expect(() => StatePacket.validate(packet, game), throwsAssertionError);
      },
    );

    test(
      'Validating unknown update from packet results into error',
      () {
        final packet = GamePacket.buffer([Server.update, 2]);

        expect(() => UpdatePacket.validate(packet, game), throwsAssertionError);
      },
    );

    test(
      'Validating unknown effect from packet results into error',
      () {
        final packet = GamePacket.buffer([Server.effect, 8]);

        expect(() => EffectPacket.validate(packet), throwsAssertionError);
      },
    );

    test(
      'Validating known state from packet returns true',
      () {
        final packet = GamePacket.buffer([Server.state, 0]);

        expect(StatePacket.validate(packet, game), true);
      },
    );

    test(
      'Validating known update from packet returns true',
      () {
        final packet = GamePacket.buffer([Server.update, 0]);

        expect(UpdatePacket.validate(packet, game), true);
      },
    );

    test(
      'Validating known effect from packet returns true',
      () {
        final packet = GamePacket.buffer([Server.effect, 0]);

        expect(EffectPacket.validate(packet), true);
      },
    );
  });
}
