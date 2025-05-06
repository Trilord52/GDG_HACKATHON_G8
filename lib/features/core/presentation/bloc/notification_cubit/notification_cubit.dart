import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/core/data/models/notification_model.dart';
import 'package:safe_campus/features/core/presentation/bloc/notification_cubit/notification_state.dart';

import 'dart:developer' as developer;
class PanicNotificationCubit extends Cubit<PanicNotificationState> {
  PanicNotificationCubit() : super(PanicNotificationInitial());

  void receiveNotification(Map<String, dynamic> data) {
    try {
      final notification = PanicNotification.fromJson(data);
      emit(PanicNotificationReceived(notification));
    } catch (e) {
      developer.log("Notification parsing error: $e");
    }
  }
}
