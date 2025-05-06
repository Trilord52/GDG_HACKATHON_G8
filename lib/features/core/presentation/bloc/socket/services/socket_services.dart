import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as developer;
class SocketService {
  late IO.Socket _socket;

  IO.Socket get socket => _socket;

  void connect(String userId, String token) {
    _socket = IO.io(
      'https://safe-campus-backend.onrender.com',
      IO.OptionBuilder()
        .setTransports(
          
          ['websocket'])
        .disableAutoConnect()
        .setAuth(
          
       {
          'token': token,
        }
        
        
        
        ) // assuming socketAuth middleware uses `token`
        .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      developer.log('Connected to /routes namespace');
      _socket.emit('register_online', userId);
    });

    _socket.onDisconnect((_) {
      developer.log('Disconnected');
    });

    _socket.on('some_event', (data) {
      developer.log('Real-time update: $data');
    });

    _socket.onConnectError((err) {
      developer.log('Connect Error: $err');
    });

    _socket.onError((err) {
      developer.log('General Error: $err');
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
