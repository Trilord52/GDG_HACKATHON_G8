abstract class PanicAlertEvent {}

class TriggerPanicAlert extends PanicAlertEvent {
  final String token;

  TriggerPanicAlert({required this.token});
}
