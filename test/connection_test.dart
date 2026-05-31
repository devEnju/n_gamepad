import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:n_gamepad/src/models/game.dart';
import 'package:n_gamepad/src/models/protocol.dart';
import 'package:n_gamepad/src/services/sink_service.dart';
import 'package:n_gamepad/src/connection.dart';

import 'game_test.dart';
import 'protocol_test.dart';

class MockConnection extends Connection {
  MockConnection(super.socket, super.stream);

  @override
  Future<void> setPlatformAddress() async {}

  @override
  Future<void> resetPlatformAddress() async {}

  @override
  void broadcastGamepad(List<int> code) {}
}

void main() {
  group('SinkService after game is set', () {
    late StreamController<Datagram?> controller;
    late SinkService service;
    late Game game;

    setUp(() async{
      controller = StreamController<Datagram?>();

      final connection = MockConnection(
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0),
        controller.stream,
      );
      game = MockGame([1, 1, 1]);

      service = SinkService(connection);

      service.startBroadcast(game);
      service.stopBroadcast();
    });

    tearDown(() async {
      await controller.close();
      await service.controller.sink.close();
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

  group('Static instantiation methods of Connection', () {
    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    group('when no connection has been started', () {
      test('Service getter throws a StateError', () {
        expect(() => Connection.service, throwsStateError);
      });

      test('Stop completes as a no-op', () async {
        final first = Connection.stop();

        await expectLater(first, completes);
        expect(() => Connection.service, throwsStateError);
      });

      test('Concurrent stop calls both complete as no-ops', () async {
        final first = Connection.stop();
        final second = Connection.stop();

        await expectLater(Future.wait([first, second]), completes);
        expect(() => Connection.service, throwsStateError);
      });

      test('Concurrent stops during an active bind cleans up', () async {
        final first = Connection.start();
        final second = Connection.stop();
        final third = Connection.stop();

        await Future.wait([first, second, third]);

        expect(() => Connection.service, throwsStateError);
      });
    });

    group('when connection has been started', () {
      setUp(() async {
        await Connection.start();
      });

      test('Service is accessible', () {
        expect(() => Connection.service, returnsNormally);
      });

      test('Calling start again returns the same service instance', () async {
        final before = Connection.service;

        await Connection.start();

        expect(Connection.service, same(before));
      });

      test('Concurrent start calls share the same service instance', () async {
        final before = Connection.service;
        final second = Connection.start();
        final third = Connection.start();

        await Future.wait([second, third]);

        expect(Connection.service, same(before));
      });

      test('Stop makes service throw StateError', () async {
        await Connection.stop();

        expect(() => Connection.service, throwsStateError);
      });

      test('Sequential stop calls reset service once', () async {
        await Connection.stop();

        final second = Connection.stop();

        await expectLater(second, completes);
        expect(() => Connection.service, throwsStateError);
      });

      test('Concurrent stop calls both complete without throwing', () async {
        final second = Connection.stop();
        final third = Connection.stop();

        await expectLater(Future.wait([second, third]), completes);
        expect(() => Connection.service, throwsStateError);
      });
    });

    group('after restart', () {
      late SinkService before;

      setUp(() async {
        await Connection.start();
        before = Connection.service;
        await Connection.stop();
        await Connection.start();
      });

      test('Service is accessible', () {
        expect(() => Connection.service, returnsNormally);
      });

      test('Service is a different instance from before the restart', () {
        expect(Connection.service, isNot(same(before)));
      });
    });
  });
}
