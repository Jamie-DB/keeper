part of 'incident_inbox_bloc.dart';

/// Sealed and `Equatable`. The UI switches over it exhaustively, so a new
/// variant fails to compile everywhere it is not handled.
///
/// There is no `Empty` state: an empty inbox is `Loaded` with an empty list.
sealed class IncidentInboxState extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class IncidentInboxLoading extends IncidentInboxState {
  const new();
}

final class IncidentInboxLoaded extends IncidentInboxState {
  const new(this.incidents);

  /// Already ordered. The widget never sorts.
  final List<Incident> incidents;

  @override
  List<Object?> get props => [incidents];
}

final class IncidentInboxLoadFailure extends IncidentInboxState {
  const new();
}
