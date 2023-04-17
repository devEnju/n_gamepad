import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../connection.dart';

import '../models/game.dart';
import '../models/protocol.dart';

/// The [StreamService] class manages communication between the application and
/// a compatible game server. This class is responsible for listening to
/// incoming data from the server, processing various types of packets, and
/// allows to alter the state of an actively connected game.
///
/// In addition, the [StreamService] class provides functionality for starting
/// and stopping device broadcasting, selecting and resetting connections, and
/// quitting from connected games.
///
/// The class maintains its own internal state, including discovered valid
/// addresses, the current game, timers for periodic broadcasts and request
/// timeouts, and various streams for handling incoming packets. Getter methods
/// are available for accessing these streams, allowing other parts of the
/// application to react to changes in the game and connections.
class StreamService {
  /// Constructs a new [StreamService] instance with the given [_connection].
  ///
  /// Listens to the incoming data from the provided [_connection].
  StreamService(this._connection) {
    _connection.stream.listen(_onData);
  }

  /// The underlying [Connection] object used by this [StreamService].
  final Connection _connection;

  /// A [StreamController] for emitting changes to the [addresses] set.
  final controller = StreamController<InternetAddress>();

  /// A set of unique [InternetAddress] objects representing valid connections.
  final Set<InternetAddress> addresses = {};

  /// The current [Game] object associated with this [StreamService], if any.
  Game? _game;

  /// A [Timer] object used for periodically broadcasting the device's presence.
  Timer? _periodic;

  /// A [Timer] object used for timing out connection attempts.
  Timer? _timeout;

  /// A callback function to be executed when the broadcast stops.
  void Function()? _onBroadcastStop;

  /// A callback function to be executed when the connection selection changes.
  void Function()? _onSelectionChange;

  /// A [StreamController] to listen to incoming [StatePacket] objects.
  StreamController<StatePacket>? _state;

  /// A list of [StreamController] to listen to different incoming
  /// [UpdatePacket] objects.
  List<StreamController<UpdatePacket>?>? _update;

  /// Provides the [_state] stream if it exists, or `null` if there is no active
  /// game session.
  Stream<StatePacket>? get stream => _state?.stream;

  /// Provides a stream from the [_update] list for the given index, or `null`
  /// if no stream exists at that index.
  Stream<UpdatePacket>? operator [](int i) => _update?[i]?.stream;

  /// Receives and handles incoming datagrams.
  ///
  /// If the received [event] is not null and its contents are not empty, this
  /// method processes the datagram based on the message type from its first
  /// byte of data and dispatches the contents to the appropriate packet
  /// handler. If the message type is less than 4, it requires the data to
  /// contain at least 4 bytes to pass a valid [ConnectionPacket] to the
  /// [_processConnectionPacket] method. Otherwise, if there is already an
  /// established connection to a game, it only requires the data to at least
  /// contain 2 bytes to pass a valid [GamePacket] to the [_processGamePacket]
  /// method.
  ///
  /// Throws an assertion error if the datagram data has an invalid size for the
  /// given message type. In the release version of the app, invalid data is
  /// ignored by dropping the received datagram before handling a packet object.
  void _onData(Datagram? event) {
    final Datagram? datagram = event;

    if (datagram != null && datagram.data.isNotEmpty) {
      if (datagram.data.first < 4) {
        // assert(message != 0)
        if (ConnectionPacket.validate(datagram)) {
          _processConnectionPacket(ConnectionPacket.buffer(datagram));
        }
      } else if (_connection.address == datagram.address) {
        // assert(message == (Server.state || Server.update || Server.effect))
        if (GamePacket.validate(datagram)) {
          _processGamePacket(GamePacket.buffer(datagram.data));
        }
      }
    }
  }

  /// Processes a received [packet] of type [ConnectionPacket].
  ///
  /// If the [packet] contains the info message type and its code matches the
  /// chosen game's code, it adds the packet's address to the set of valid
  /// connections and emits an event to the stream controller. If the [packet]
  /// contains the quit message type and its code matches the chosen game's
  /// code, it removes the packet's address from the set of valid connections
  /// and emits an event to the stream controller. Non-matching packets are
  /// ignored.
  void _processConnectionPacket(ConnectionPacket packet) {
    if (_game?.compareCode(packet.code) != null) {
      if (packet.message == Server.info) {
        _addAddress(packet.address);
      } else if (packet.message == Server.quit) {
        _removeAddress(packet.address);
      }
    }
  }

  /// Adds an [address] to the set of discovered [addresses] and emits an event
  /// to the stream controller if the address is newly added.
  void _addAddress(InternetAddress address) {
    if (addresses.add(address)) controller.add(address);
  }

  /// Removes an [address] from the set of discovered [addresses] and emits an
  /// event to the stream controller if the [address] was present. If the
  /// [address] is the current connection's address, it resets the application
  /// by calling [quit].
  void _removeAddress(InternetAddress address) {
    if (_connection.address == address) quit();

    if (addresses.remove(address)) controller.add(address);
  }

  /// Processes a received [packet] of type [GamePacket].
  ///
  /// If the app is not connected to a game and the [packet] contains the state
  /// message type, it stops the ongoing broadcast for valid connections,
  /// cancels the response timeout timer started upon selecting a connection,
  /// initializes the necessary streams, and sets up the platform to open the
  /// chosen [Game] page. If the app is in a game session and the [packet]
  /// contains the state message type, it adds the [packet] to the stream of
  /// state packets. If the [packet] contains the update message type, it adds
  /// the [packet] to the specific stream for the corresponding update packet
  /// type. If the [packet] contains an effect message type, it performs actions
  /// like rumble effects on the device (not currently implemented in this
  /// version).
  void _processGamePacket(GamePacket packet) {
    if (_state == null) {
      if (packet.message == Server.state) {
        stopBroadcast();
        _timeout!.cancel();
        _initializeStreams();
        _initializePlatform(StatePacket(packet));
      }
    } else if (packet.message == Server.state) {
      _handleStatePacket(packet);
    } else if (packet.message == Server.update) {
      _handleUpdatePacket(packet);
    } else if (packet.message == Server.effect) {
      _handleEffectPacket(packet);
    }
  }

  /// Initializes the stream controllers for [_state] and [_update] packets.
  ///
  /// Sets up the [_state] stream controller for [StatePacket] instances and
  /// creates a list of stream controllers for [UpdatePacket] instances based on
  /// the number of updates expected in the current [_game].
  void _initializeStreams() {
    _state = StreamController<StatePacket>();
    _update = List<StreamController<UpdatePacket>?>.filled(
      _game!.updates,
      null,
    );
  }

  /// Sets the platform address and opens the game page using the provided
  /// [packet].
  ///
  /// Sets the address on the platform of the device with the help of the
  /// [Connection] instance, and then opens a page for the current [Game] with
  /// the most recent state provided by the [packet].
  Future<void> _initializePlatform(StatePacket packet) async {
    await _connection.setPlatformAddress();

    _game!.openPage(packet);
  }

  /// Adds a [StatePacket] to the [_state] stream.
  ///
  /// Validates the [packet]'s type against the number of states in the current
  /// [_game]. If the value is valid, it creates a [StatePacket] from the
  /// [GamePacket] and adds it to the [_state] stream controller.
  ///
  /// Throws an assertion error in debug mode if the value is invalid.
  void _handleStatePacket(GamePacket packet) {
    if (StatePacket.validate(packet, _game!)) {
      _state!.add(StatePacket(packet));
    }
  }

  /// Adds an [UpdatePacket] to the appropriate stream in the [_update] list.
  ///
  /// Validates the [packet]'s type against the number of updates in the current
  /// [_game]. If the value is valid, it retrieves the corresponding
  /// [StreamController] from the [_update] list and in case of its availability
  /// adds the [UpdatePacket] created from the [GamePacket] to it.
  ///
  /// Throws an assertion error in debug mode if the value is invalid.
  void _handleUpdatePacket(GamePacket packet) {
    if (UpdatePacket.validate(packet, _game!)) {
      final StreamSink<UpdatePacket>? sink = _update![packet.type];

      if (sink != null) {
        sink.add(UpdatePacket(packet));
      }
    }
  }

  /// Handles an [EffectPacket] to perform an effect.
  ///
  /// Validates the [packet]'s type against the total amount of [GameEffect]s.
  /// If the value is valid, it creates an [EffectPacket] from the
  /// [GamePacket] and performs the effect on the gamepad.
  ///
  /// Throws an assertion error in debug mode if the value is invalid.
  void _handleEffectPacket(GamePacket packet) {
    if (EffectPacket.validate(packet)) {
      // Connection.gamepad.performEffect(EffectPacket(packet));
    }
  }

  /// Starts broadcasting the chosen [game] and executes [onStop] when the
  /// broadcast is stopped.
  ///
  /// If there is no active connection, clears the set of connections if the
  /// current game is not the same as the provided [game], and sets [_game] to
  /// the provided [game]. Stops any ongoing broadcasts and starts a new one
  /// with the corresponding game's code. Calls [onStop] whenever the broadcast
  /// is stopped.
  void startBroadcast(Game game, [void Function()? onStop]) {
    if (_connection.address == null) {
      if (_game != game) {
        addresses.clear();
      }
      _game = game;

      stopBroadcast();

      _connection.broadcastGamepad(game.code);
      _periodic = Timer.periodic(
        const Duration(seconds: 3),
        (timer) => _connection.broadcastGamepad(game.code),
      );
      _onBroadcastStop = onStop;
    }
  }

  /// Stops the ongoing broadcast while calling the [_onBroadcastStop] function.
  ///
  /// Cancels the periodic timer for the broadcast and invokes the
  /// [_onBroadcastStop] function if it is set.
  void stopBroadcast() {
    _periodic?.cancel();
    _onBroadcastStop?.call();
    _onBroadcastStop = null;
  }

  /// Selects a connection with the given [address] and executes [onChange] when
  /// the connection changes.
  ///
  /// If the current connection's address is different from the provided
  /// [address], sets the connection's address to [address] and initializes the
  /// host. Starts a timer for 5 seconds to reset the connection if there is no
  /// response, and calls [onChange] when the selection changes.
  void select(InternetAddress address, [void Function()? onChange]) {
    if (_connection.address != address) {
      _connection.address = address;

      _timeout?.cancel();
      _onSelectionChange?.call();

      _connection.initializeHost();

      _timeout = Timer(
        const Duration(seconds: 5),
        () => reset(reason: 'no response'),
      );
      _onSelectionChange = onChange;
    }
  }

  /// Resets the current connection with an optional [reason].
  ///
  /// If a [reason] is provided, removes the current connection's address from
  /// the set of addresses and adds an error to the stream controller. Cancels
  /// the response timeout timer, resets the platform address, and clears the
  /// connection's address. Closes the [_state] stream controller and sets it to
  /// null. Closes all update stream controllers in [_update] and sets their
  /// values to null.
  void reset({String? reason}) {
    if (reason != null) {
      addresses.remove(_connection.address);

      controller.addError(FlutterError(reason));
    }

    _timeout?.cancel();

    _connection.resetPlatformAddress();
    _connection.address = null;

    _state?.close();
    _state = null;

    for (int i = 0; i < (_update?.length ?? 0); i++) {
      _update![i]?.close();
      _update![i] = null;
    }
    _update = null;
  }

  /// Quits the current game session or resets the connection if not in a game.
  ///
  /// If there is an active game session (indicated by a non-null [_state]),
  /// closes the [Game] page which also resets this service. Otherwise, just
  /// resets the service.
  void quit() {
    _state != null ? _game!.closePage() : reset();
  }

  /// Sends a request to the server to perform the specified [action] with the
  /// given [data] using the [Connection] instance.
  ///
  /// The [action] parameter should be an enumeration representing the desired
  /// action to be performed on the server. The [data] parameter is a list of
  /// integers containing any additional data required for the action.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// streamService.requestAction(GameAction.swapItem, [4, 7]);
  /// ```
  ///
  /// In this example, the `GameAction.swapItem` action is requested with the
  /// additional information `[4, 7]` to swap an item from position `4` to `7`
  /// of the inventory. The server should check if the action can be performed
  /// and send the updated state with a valid [StatePacket] back to the
  /// application.
  void requestAction(Enum action, List<int> data) {
    _connection.sendRequest(<int>[
      Client.action,
      action.index,
      ...data,
    ]);
  }

  /// Sends a request to the server to explicitly change the game state to the
  /// specified [state] using the [Connection] instance.
  ///
  /// The [state] parameter should be an enumeration representing the desired
  /// state to be set on the server.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// streamService.requestState(GameState.paused);
  /// ```
  ///
  /// In this example, the `GameState.paused` state is requested, which would
  /// pause the game on the server and only send a confirmation in form of a
  /// [StatePacket] if this state change was possible.
  void requestState(Enum state) {
    _connection.sendRequest(<int>[
      Client.state,
      state.index,
    ]);
  }

  /// Sends a request to the server to retrieve the specified [update] using the
  /// [Connection] instance.
  ///
  /// The [update] parameter should be an enumeration representing the desired
  /// continuous update to be received from the server until it was deactivated.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// streamService.requestUpdate(GameUpdate.position);
  /// ```
  /// 
  /// In this example, the `GameUpdate.position` update is requested, which
  /// would activate constant updates to be received about a player's position
  /// in form of a valid [UpdatePacket].
  void requestUpdate(Enum update) {
    _connection.sendRequest(<int>[
      Client.update,
      update.index,
    ]);
  }
}
