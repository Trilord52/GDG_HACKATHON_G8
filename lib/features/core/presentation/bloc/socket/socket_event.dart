abstract class SocketEvent {}

class ConnectSocket extends SocketEvent {
  final String userId;
  final String token;
  ConnectSocket(this.userId, this.token);
}

class DisconnectSocket extends SocketEvent {}

class SocketDataReceived extends SocketEvent {
  final dynamic data;
  SocketDataReceived(this.data);
}
