part of 'incident_inbox_bloc.dart';

/// Sealed, so the Bloc's `on<...>` registrations are the full list of what
/// can happen. Named as past-tense facts: something was requested.
sealed class IncidentInboxEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class IncidentInboxLoadRequested extends IncidentInboxEvent {
  const new();
}
