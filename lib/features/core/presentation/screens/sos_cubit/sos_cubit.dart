import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as developer;
part 'sos_state.dart';

class SosCubit extends Cubit<SosState> {
  SosCubit() : super(SosState(isEmergencyMode: false));


  void onEmergencyMode() {
    emit(SosState(isEmergencyMode: true));
  }

  void offEmergencyMode() {
    emit(SosState(isEmergencyMode: false));
  } 
}
