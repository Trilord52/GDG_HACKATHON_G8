import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/socket/services/socket_services.dart';
import 'socket_event.dart';
import 'socket_state.dart';
import 'dart:developer' as developer;

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketService   socketService = SocketService(); // Initialize the socket service

  SocketBloc() : super(SocketInitial()) {
    on<ConnectSocket>((event, emit) {
      try {
        socketService.connect(event.userId, event.token);
        socketService.socket.on('register_online', (data) {
          add(SocketDataReceived(data));
        });
        emit(SocketConnected());
        developer.log('Socket connected and event listener added token: ${event.token} userId: ${event.userId}');
      } catch (e) {
        developer.log('Socket connection error: $e');
        emit(SocketError(e.toString()));
      }
    });

    on<DisconnectSocket>((event, emit) {
      socketService.disconnect();
      emit(SocketDisconnected());
      developer.log('Socket disconnected');
    });

    on<SocketDataReceived>((event, emit) {
      emit(SocketDataState(event.data));
      developer.log('Socket data received: ${event.data}');
    });
    cacth(e){
    
      developer.log('Socket error: $e');
    }
  }
}
