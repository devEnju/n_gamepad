import 'dart:io';

import '../connection.dart';

import 'game.dart';

/// The [ConnectionPacket] class is used to temporarily store incoming data from
/// a game server into its buffer, or detect and skip the data if it is invalid.
/// Therefore, the accessible [_buffer] always contains the most recent address,
/// message, code, and data after its parsing.
///
/// This information is used to establish connections between the application
/// and a game server.
class ConnectionPacket {
  /// A private constructor that creates an empty [ConnectionPacket].
  ConnectionPacket._internal()
      : _address = Connection.loopback,
        _message = 0,
        _code = List.empty(),
        _data = '';

  /// A `factory` constructor that creates a [ConnectionPacket] from a given
  /// [Datagram].
  ///
  /// The constructor expects the data of the [datagram] to have a [_minSize].
  /// If the datagram data is shorter than that, a [RangeError] will be thrown.
  /// Use the [validate] function before calling this constructor.
  factory ConnectionPacket.buffer(Datagram datagram) => _buffer
    .._address = datagram.address
    .._message = datagram.data[0]
    .._code = datagram.data.sublist(1, _minSize)
    .._data = String.fromCharCodes(datagram.data.sublist(_minSize));

  static const int _minSize = 4;

  /// A static instance of a [ConnectionPacket], used for buffering the most
  /// recent data provided over the `factory` constructor.
  static final _buffer = ConnectionPacket._internal();

  static bool validate(Datagram datagram) {
    final valid = datagram.data.length >= _minSize;
    assert(valid, 'received invalid packet for message ${datagram.data.first}');
    return valid;
  }

  /// The [InternetAddress] of the received [Datagram].
  InternetAddress _address;

  /// The message type of the received [Datagram].
  int _message;

  /// The received code from a game server of the [Datagram].
  List<int> _code;

  /// The remaining data of the received [Datagram].
  String _data;

  /// Returns the [InternetAddress] of the received [Datagram].
  InternetAddress get address => _address;

  /// Returns the message type of the received [Datagram]
  ///
  /// This message can be compared to one of the known [Server] message types in
  /// order to perform the right action.
  int get message => _message;

  /// Returns the received code from a game server of the [Datagram]
  ///
  /// The code is used to identify a specific [Game].
  List<int> get code => _code;

  /// Returns the remaining data of the received [Datagram] parsed as a string.
  ///
  /// This may contain information about the server.
  String get data => _data;
}

/// The [GamePacket] class is used to temporarily store incoming data from a
/// game server into its buffer, or detect and skip the data if it is invalid.
/// Therefore, the accessible [_buffer] always contains the most recent message,
/// value, and additional data after its parsing.
///
/// This information is used to further process the packet into either a
/// [StatePacket], [UpdatePacket], or [EffectPacket] in order to perform the
/// appropriate task on the application.
class GamePacket {
  /// A private constructor that creates an empty [GamePacket].
  GamePacket._internal()
      : _message = 0,
        _type = 0,
        _data = List.empty();

  /// A `factory` constructor that creates a [GamePacket] from a given list of
  /// bytes.
  ///
  /// The constructor expects the [data] to have a [_minSize]. If the data is
  /// shorter than that, a [RangeError] will be thrown. Use the [validate]
  /// function before calling this constructor.
  factory GamePacket.buffer(List<int> data) => _buffer
    .._message = data[0]
    .._type = data[1]
    .._data = data.sublist(_minSize);

  static const int _minSize = 2;

  /// A static instance of a [GamePacket], used for buffering the most recent
  /// data provided over the `factory` constructor.
  static final _buffer = GamePacket._internal();

  static bool validate(Datagram datagram) {
    final valid = datagram.data.length >= _minSize;
    assert(valid, 'received invalid packet for message ${datagram.data.first}');
    return valid;
  }

  /// The message type of the received data.
  int _message;

  /// The type of the received data.
  int _type;

  /// The remaining data, which provides additional information on the game
  /// state, update or effect.
  List<int> _data;

  /// Returns the message type of the received data.
  ///
  /// This message can be compared to one of the known [Server] message types in
  /// order to filter what specific game packet it is.
  int get message => _message;

  /// Returns the parsed type of the received data.
  ///
  /// The type may represent a specific game state, update or effect.
  int get type => _type;
}

class StatePacket {
  StatePacket(GamePacket packet)
      : state = packet._type,
        data = packet._data;

  final int state;
  final List<int> data;

  static bool validate(GamePacket packet, Game game) {
    final valid = packet.type < game.states;
    assert(valid, 'received unknown state ${packet.type}');
    return valid;
  }

  @override
  bool operator ==(other) => other is StatePacket && state == other.state;

  @override
  int get hashCode => state;
}

class UpdatePacket {
  UpdatePacket(GamePacket packet) : data = packet._data;

  static bool validate(GamePacket packet, Game game) {
    final valid = packet.type < game.updates;
    assert(valid, 'received unknown update ${packet.type}');
    return valid;
  }

  final List<int> data;
}

class EffectPacket {
  EffectPacket(GamePacket packet)
      : effect = packet._type < GameEffect.values.length
            ? GameEffect.values[packet._type]
            : null,
        data = packet._data;

  static bool validate(GamePacket packet) {
    final valid = packet.type < GameEffect.values.length;
    assert(valid, 'received unknown effect ${packet.type}');
    return valid;
  }

  final GameEffect? effect;
  final List<int> data;
}

// action packet via touch
// |       1byte | nbytes |
// | 0b0000_0001 |  data  |

// input packet via sensor (Gyroscope)
// |       1byte |  4bytes |  4bytes |  4bytes |
// | 0b0000_0010 | float x | float y | float z |

// input packet via key (Gyroscope)
// |       1byte |   1byte |
// | 0b0000_0100 |  char a |

// input packet via motion (right Trigger)
// |       1byte |  4bytes |
// | 0b1000_0000 | float z |

// input packet via motion (right Joystick and Trigger)
// |       1byte |  4bytes |  4bytes |  4bytes |
// | 0b1010_0000 | float x | float y | float z |

class Client {
  static const int action = 1;
  static const int broadcast = 3;
  static const int state = 5;
  static const int update = 9;
}

// state packet from server
// |       1byte | nbytes |
// | 0b0000_0100 |  data  |

// update packet from server
// |       1byte | nbytes |
// | 0b0000_1000 |  data  |

// effect packet from server
// |       1byte |  1byte |
// | 0b0000_1100 |  data  |

class Server {
  static const int info = 1;
  static const int quit = 2;
  static const int state = 4;
  static const int update = 8;
  static const int effect = 12;
}
