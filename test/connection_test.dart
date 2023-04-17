import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:n_gamepad/src/models/game.dart';
import 'package:n_gamepad/src/models/protocol.dart';
import 'package:n_gamepad/src/services/stream_service.dart';
import 'package:n_gamepad/src/connection.dart';

import 'game_test.dart';
import 'protocol_test.dart';

class MockConnection extends Connection {
  MockConnection(super.socket, super.stream);

  @override
  Future<void> setPlatformAddress() async {}

  @override
  Future<void> resetPlatformAddress() async {}
}

void main() {
  late StreamController<Datagram?> controller;
  late StreamService service;
  late Game game;

  setUp(() async {
    controller = StreamController<Datagram?>();

    final connection = MockConnection(
      await RawDatagramSocket.bind(Connection.loopback, 0),
      controller.stream,
    );

    service = StreamService(connection);
  });

  tearDown(() async {
    await controller.close();
    await service.controller.sink.close();
  });

  group('StreamService after game is set', () {
    setUp(() {
      game = MockGame([1, 1, 1]);

      service.startBroadcast(game);
      service.stopBroadcast();
    });

    test(
      'Receiving valid info connection packet yields one event to connection stream',
      () async {
        final address = InternetAddress('192.168.0.2');

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
        ));

        await expectLater(service.controller.stream, emits(address));

        expect(service.addresses.length, 1);
      },
    );

    test(
      'Receiving info connection packets from same address yield one event to connection stream',
      () async {
        final address = InternetAddress('192.168.0.2');

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
        ));

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
        ));

        await expectLater(service.controller.stream, emits(address));

        expect(service.addresses.length, 1);
      },
    );

    test(
      'Receiving info connection packets from unique addresses yield events to connection stream',
      () async {
        final addresses = <InternetAddress>[
          InternetAddress('192.168.0.3'),
          InternetAddress('192.168.0.4'),
          InternetAddress('192.168.0.5'),
        ];

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
          address: InternetAddress('192.168.0.3'),
        ));

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
          address: InternetAddress('192.168.0.4'),
        ));

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
          address: InternetAddress('192.168.0.5'),
        ));

        await expectLater(service.controller.stream, emitsInOrder(addresses));

        expect(service.addresses.length, 3);
      },
    );

    test(
      'Receiving quit after info connection packet from same address yield events to connection stream',
      () async {
        final addresses = <InternetAddress>[
          InternetAddress('192.168.0.2'),
          InternetAddress('192.168.0.2'),
        ];

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
        ));

        controller.add(connectionDatagram(
          message: Server.quit,
          game: true,
        ));

        await expectLater(service.controller.stream, emitsInOrder(addresses));

        expect(service.addresses.length, 0);
      },
    );

    test(
      'Changing game resets addresses',
      () async {
        final addresses = <InternetAddress>[
          InternetAddress('192.168.0.3'),
          InternetAddress('192.168.0.4'),
          InternetAddress('192.168.0.5'),
        ];

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
          address: InternetAddress('192.168.0.3'),
        ));

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
          address: InternetAddress('192.168.0.4'),
        ));

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
          address: InternetAddress('192.168.0.5'),
        ));

        await expectLater(service.controller.stream, emitsInOrder(addresses));

        expect(service.addresses.length, 3);

        final game = MockGame([0, 0, 0]);

        service.startBroadcast(game);
        service.stopBroadcast();

        expect(service.addresses.length, 0);
      },
    );

    group('and successful connection', () {
      setUp(() async {
        final address = InternetAddress('192.168.0.2');

        controller.add(connectionDatagram(
          message: Server.info,
          game: true,
        ));

        service.select(address);

        controller.add(gameDatagram(
          message: Server.state,
          type: 0,
        ));

        await expectLater(service.controller.stream, emits(address));
      });

      tearDown(() {
        service.reset();
      });

      test(
        'Receiving valid game packets do not yield event to connection but state stream',
        () async {
          final packet = StatePacket(GamePacket.buffer(gameDatagram(
            message: Server.state,
            type: 0,
          ).data));

          controller.add(gameDatagram(
            message: Server.state,
            type: 0,
          ));

          controller.add(gameDatagram(
            message: Server.update,
            type: 0,
          ));

          controller.add(gameDatagram(
            message: Server.effect,
            type: 0,
          ));

          controller.add(gameDatagram(
            message: 16,
            type: 0,
          ));

          await expectLater(service.stream, emits(packet));
        },
      );

      test(
        'Receiving valid state packets yield events to state stream',
        () async {
          final packets = <StatePacket>[
            StatePacket(GamePacket.buffer(gameDatagram(
              message: Server.state,
              type: 0,
            ).data)),
            StatePacket(GamePacket.buffer(gameDatagram(
              message: Server.state,
              type: 0,
            ).data)),
            StatePacket(GamePacket.buffer(gameDatagram(
              message: Server.state,
              type: 1,
            ).data)),
            StatePacket(GamePacket.buffer(gameDatagram(
              message: Server.state,
              type: 2,
            ).data)),
          ];

          controller.add(gameDatagram(
            message: Server.state,
            type: 0,
          ));

          controller.add(gameDatagram(
            message: Server.state,
            type: 0,
          ));

          controller.add(gameDatagram(
            message: Server.state,
            type: 1,
          ));

          controller.add(gameDatagram(
            message: Server.state,
            type: 2,
          ));

          await expectLater(service.stream, emitsInOrder(packets));
        },
      );
    });
  });
}
