abstract class SocketState {}

class SocketInitial extends SocketState {}

class SocketConnected extends SocketState {}

class SocketDisconnected extends SocketState {}

class SocketError extends SocketState {
  final String message;
  SocketError(this.message);
}

class SocketDataState extends SocketState {
  final dynamic data;
  SocketDataState(this.data);
}
