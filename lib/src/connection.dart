import 'dart:async';
import 'dart:io';

import '../n_gamepad_platform_interface.dart';

import 'models/protocol.dart';

import 'services/sink_service.dart';

import 'gamepad.dart';

/// The [Connection] class is responsible for managing basic network
/// capabilities to interact with a separate game server. It provides methods to
/// create, manage, and interact with a network connection to send data from the
/// device in order to be able to function like a gamepad.
///
/// Please do not use the raw methods of a [Connection] object. Instead, use the
/// better suited methods from the [SinkService] instance to broadcast and
/// send specific requests to a game server. To create a new [Connection]
/// object, wait for the [start] method to finish.
///
/// Example usage:
///
/// ```dart
/// await Connection.start();
/// ```
class Connection {
  /// Constructs a new [Connection] instance with the provided [socket] and
  /// [stream].
  ///
  /// Refrain from instantiating objects via the constructor. The [start] method
  /// should be used instead since it also creates an associated [SinkService]
  /// instance.
  Connection(this.socket, this.stream);

  /// The [RawDatagramSocket] used for sending and receiving datagrams.
  final RawDatagramSocket socket;

  /// A [Stream] of [Datagram] objects, representing the incoming network
  /// events.
  final Stream<Datagram?> stream;

  /// The [InternetAddress] of a connected game server, or `null` if not
  /// connected.
  InternetAddress? address;

  /// A reference to the singleton instance of [NetworkGamepad] in order to
  /// utilize platform-specific code.
  static final gamepad = NetworkGamepad.instance;

  /// A constant representing the broadcast IP address (255.255.255.255).
  static final broadcast = InternetAddress('255.255.255.255');

  /// A constant representing the standard port to be used on a game server.
  static const int port = 44700;

  /// The most recent completer of the [Connection] class.
  static Completer<Connection>? _completer;

  /// The [SinkService] instance associated with the [Connection] class.
  static SinkService? _service;

  /// Returns the currently active instance of [SinkService].
  ///
  /// Throws a [StateError] if [start] has not been called yet or has not
  /// completed, ensuring the [Connection] has been fully instantiated.
  static SinkService get service => _completer?.isCompleted != true
      ? throw StateError('Connection needs to be started first.')
      : _service!;

  /// Asynchronously starts a new [Connection] instance and its related service.
  ///
  /// If a connection is already being started or fully instantiated, returns a
  /// future that completes when that connection is ready. Otherwise, binds a
  /// new [RawDatagramSocket] to the local IP address of the device in a network
  /// and creates a stream which is used to process incoming network events in
  /// the [SinkService].
  ///
  /// Errors of binding the [RawDatagramSocket] propagate through the returned
  /// [Future].
  static Future<void> start() {
    final completer = _completer ?? Completer();

    if (_completer == null) {
      _completer = completer;

      RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
        final stream = socket.map<Datagram?>(
          (event) => (event == RawSocketEvent.read) ? socket.receive() : null,
        );
        final connection = Connection(socket, stream);

        _service = SinkService(connection);
        completer.complete(connection);
      }).catchError((error, stackTrace) {
        _completer = null;
        completer.completeError(error, stackTrace);
      });
    }
    return completer.future.then((_) {});
  }

  /// Cleans up the [Connection] instance and its related services.
  ///
  /// This method waits for the in-progress [_completer] to be finished before
  /// terminating services associated with the [Connection] instance. After
  /// shutting down all resources of the [SinkService], it also closes the
  /// [RawDatagramSocket] while resetting the static state of this class.
  static Future<void> stop() async {
    final instance = await _completer?.future
        .then<Connection?>((value) => value)
        .catchError((_) => null);

    _service?.quit();
    _service?.stopBroadcast();
    _service = null;

    if (_completer != null) {
      instance?.socket.close();
    }
    _completer = null;
  }

  /// Sets the connection [address] of the platform by delegating this request
  /// to platform-specific code with the [GamepadPlatform].
  Future<void> setPlatformAddress() {
    return GamepadPlatform.instance.setAddress(address!);
  }

  /// Resets the connection [address] of the platform by delegating this request
  /// to platform-specific code with the [GamepadPlatform].
  Future<void> resetPlatformAddress() {
    return GamepadPlatform.instance.resetAddress();
  }

  /// Broadcasts a [code] to all devices in the network to search for eligible
  /// game servers to connect to.
  ///
  /// Enables the broadcast feature of the [socket], sends a packet containing
  /// the broadcast message type and the provided [code] to the broadcast
  /// address on the predefined [port], and then disables the broadcast feature
  /// after sending the packet.
  void broadcastGamepad(List<int> code) {
    socket.broadcastEnabled = true;
    socket.send(
      <int>[Client.broadcast, ...code],
      broadcast,
      port,
    );
    socket.broadcastEnabled = false;
  }

  /// Initializes the game server by sending the default action (0) to a
  /// previously selected [address] on the predefined [port].
  void initializeHost() {
    socket.send(
      <int>[Client.action, 0],
      address!,
      port,
    );
  }

  /// Sends a request with the given [data] to the connected [address] on the
  /// predefined [port].
  void sendRequest(List<int> data) {
    if (address != null) {
      socket.send(data, address!, port);
    }
  }
}
