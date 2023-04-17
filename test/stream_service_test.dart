import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:n_gamepad/src/models/game.dart';
import 'package:n_gamepad/src/models/protocol.dart';
import 'package:n_gamepad/src/services/stream_service.dart';
import 'package:n_gamepad/src/connection.dart';

import 'connection_test.dart';
import 'game_test.dart';
import 'protocol_test.dart';

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
    expectLater(service.controller.stream.isEmpty, completion(true));

    await controller.close();
    await service.controller.sink.close();
  });

  group('StreamService after initialization', () {
    test(
      'Receiving null does not yield event to connection stream and does not initialize other streams',
      () {
        controller.add(null);

        expect(service.stream, null);
      },
    );

    test(
      'Receiving empty datagram does not yield event to connection stream',
      () {
        controller.add(connectionDatagram());
      },
    );

    test(
      'Receiving valid connection packets do not yield event to connection stream',
      () {
        controller.add(connectionDatagram(
          message: 0,
          game: false,
        ));

        controller.add(connectionDatagram(
          message: Server.info,
          game: false,
        ));

        controller.add(connectionDatagram(
          message: Server.quit,
          game: false,
        ));

        controller.add(connectionDatagram(
          message: Client.broadcast,
          game: false,
        ));
      },
    );

    test(
      'Receiving valid game packets do not yield event to connection stream',
      () {
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
      },
    );
  });

  group('StreamService after game is set', () {
    setUp(() {
      game = MockGame([1, 1, 1]);

      service.startBroadcast(game);
      service.stopBroadcast();
    });

    test(
      'Receiving valid but unknown connection packet does not yield event to connection stream',
      () {
        controller.add(connectionDatagram(
          message: 0,
          game: true,
        ));
      },
    );

    test(
      'Receiving valid quit connection packet does not yield event to connection stream',
      () {
        controller.add(connectionDatagram(
          message: Server.quit,
          game: true,
        ));
      },
    );

    test(
      'Receiving valid broadcast connection packet does not yield event to connection stream',
      () {
        controller.add(connectionDatagram(
          message: Client.broadcast,
          game: true,
        ));
      },
    );

    test(
      'Receiving valid connection packets but from other game do not yield event to connection stream',
      () {
        controller.add(connectionDatagram(
          message: Server.info,
          game: false,
        ));

        controller.add(connectionDatagram(
          message: Server.quit,
          game: false,
        ));
      },
    );

    group('and successful connection', () {
      setUp(() {
        final address = InternetAddress('192.168.0.2');

        service.addresses.add(address);

        service.select(address);

        controller.add(gameDatagram(
          message: Server.state,
          type: 0,
        ));
      });

      tearDown(() {
        expectLater(service.stream!.isEmpty, completion(true));

        service.reset();
      });

      test(
        'Receiving null does not yield event to any stream',
        () {
          controller.add(null);

          expect(service.stream, isNot(null));
        },
      );

      test(
        'Receiving valid state packets from different address does not yield event to state stream',
        () {
          controller.add(gameDatagram(
            message: Server.state,
            type: 0,
            address: InternetAddress('192.168.0.3'),
          ));

          controller.add(gameDatagram(
            message: Server.state,
            type: 0,
            address: InternetAddress('192.168.0.4'),
          ));

          controller.add(gameDatagram(
            message: Server.state,
            type: 0,
            address: InternetAddress('192.168.0.5'),
          ));
        },
      );

      test(
        'Resetting connection keeps selected address in addresses',
        () {
          final address = InternetAddress('192.168.0.2');

          expect(service.stream, isNot(null));
          expect(service.addresses.contains(address), true);

          service.reset();

          expect(service.stream, null);
          expect(service.addresses.contains(address), true);

          service.select(address);

          controller.add(gameDatagram(
            message: Server.state,
            type: 0,
          ));
        },
      );
    });
  });
}
