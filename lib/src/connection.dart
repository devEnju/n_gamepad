import 'dart:io';

import '../n_gamepad_platform_interface.dart';

import 'models/protocol.dart';

import 'services/stream_service.dart';

import 'gamepad.dart';

/// The [Connection] class is responsible for managing basic network
/// capabilities to interact with a separate game server. It provides methods to
/// create, manage, and interact with a network connection to send data from the
/// device in order to be able to function like a gamepad.
///
/// Please do not use the raw methods of a [Connection] object. Instead, use the
/// better suited methods from the [StreamService] instance to broadcast and
/// send specific requests to a game server. To create a new [Connection]
/// object, wait for the [instantiate] method to finish.
///
/// Example usage:
///
/// ```dart
/// await Connection.instantiate();
/// ```
class Connection {
  /// Constructs a new [Connection] instance with the provided [socket] and
  /// [stream].
  /// 
  /// Refrain from instantiating objects via the constructor. The [instantiate]
  /// method should be used instead since it also creates an associated
  /// [StreamService] instance.
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

  /// A constant representing the loopback IP address (127.0.0.1).
  static final loopback = InternetAddress('127.0.0.1');

  /// A constant representing the broadcast IP address (255.255.255.255).
  static final broadcast = InternetAddress('255.255.255.255');

  /// A constant representing standard port to be used on a game server.
  static const int port = 44700;

  /// The most recent instance of the [Connection] class.
  static Connection? _instance;

  /// The [StreamService] instance associated with the [Connection] class.
  static StreamService? _service;

  /// Returns the currently active instance of [StreamService].
  ///
  /// This getter asserts that [_service] is not null before returning it,
  /// ensuring that the [Connection] instance has already been instantiated.
  static StreamService get service {
    assert(_service != null, "Connection needs to be instantiated first.");
    return _service!;
  }

  /// Asynchronously instantiates a [Connection] object and its related service.
  ///
  /// If an instance of [Connection] already exists, the [destroy] method is
  /// called to clean up resources. The method then binds a new
  /// [RawDatagramSocket] to the local IP address of the device in a network and
  /// creates a stream which is used to process incoming network events in the
  /// service.
  ///
  /// Returns a [Connection] object after the Future has been resolved.
  /// 
  /// Errors of the [RawDatagramSocket] are uncaught.
  static Future<Connection> instantiate() async {
    if (_instance != null) destroy();
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final stream = socket.map<Datagram?>(
      (event) => (event == RawSocketEvent.read) ? socket.receive() : null,
    );
    _instance = Connection(socket, stream);
    _service = StreamService(_instance!);
    return _instance!;
  }

  /// Cleans up the [Connection] instance and its related services.
  ///
  /// This method terminates the service associated with the [Connection]
  /// instance by resetting the [StreamService]. It then closes the
  /// [RawDatagramSocket] associated with the [Connection] instance.
  static void destroy() {
    service.quit();
    service.stopBroadcast();
    _instance!.socket.close();
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
