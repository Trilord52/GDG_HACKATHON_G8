import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'panic_alert_event.dart';
import 'panic_alert_state.dart';

class PanicAlertBloc extends Bloc<PanicAlertEvent, PanicAlertState> {
  PanicAlertBloc() : super(PanicInitial()) {
    on<TriggerPanicAlert>(_onTriggerPanicAlert);
  }

  Future<void> _onTriggerPanicAlert(
    TriggerPanicAlert event,
    Emitter<PanicAlertState> emit,
  ) async {
    emit(PanicLoading());

    try {
      // 1. Get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location services are disabled");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied");
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      // 2. Send panic alert using http
      final uri = Uri.parse('https://safe-campus-backend.onrender.com/api/sos/trigger');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "location": {
            "coordinates": [position.longitude, position.latitude],
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        emit(PanicSuccess(jsonResponse));
      } else {
        emit(PanicError("Failed with status code: ${response.statusCode}"));
      }
    } catch (e) {
      emit(PanicError(e.toString()));
    }
  }
}
