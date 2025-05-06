abstract class PanicAlertState {}

class PanicInitial extends PanicAlertState {}

class PanicLoading extends PanicAlertState {}

class PanicSuccess extends PanicAlertState {
  final Map<String, dynamic> response;
  PanicSuccess(this.response);
}

class PanicError extends PanicAlertState {
  final String message;
  PanicError(this.message);
}
