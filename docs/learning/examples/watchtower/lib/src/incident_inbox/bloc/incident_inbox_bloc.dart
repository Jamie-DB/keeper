import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watchtower/src/domain/incident.dart';
import 'package:watchtower/src/repositories/incident_repository.dart';

part 'incident_inbox_event.dart';
part 'incident_inbox_state.dart';

/// Events in, states out, one handler where the logic lives.
///
/// The repository arrives through the constructor so a test can hand in a
/// mock. The Bloc never sorts in the UI's place: the loaded state carries an
/// already-ordered list, so the widget only renders.
class IncidentInboxBloc extends Bloc<IncidentInboxEvent, IncidentInboxState> {
  new({required this._repository}) : super(const IncidentInboxLoading()) {
    on<IncidentInboxLoadRequested>(_onLoadRequested);
  }

  final IncidentRepository _repository;

  Future<void> _onLoadRequested(
    IncidentInboxLoadRequested event,
    Emitter<IncidentInboxState> emit,
  ) async {
    emit(const IncidentInboxLoading());
    try {
      final incidents = await _repository.fetchIncidents();
      emit(IncidentInboxLoaded(_ordered(incidents)));
    } on Exception {
      emit(const IncidentInboxLoadFailure());
    }
  }

  /// Severity descending, then raised-at descending, then id ascending.
  /// Three keys make the order total, so no two lists can tie.
  static List<Incident> _ordered(List<Incident> incidents) {
    return [...incidents]..sort((a, b) {
      final bySeverity = b.severity.index.compareTo(a.severity.index);
      if (bySeverity != 0) return bySeverity;
      final byRaisedAt = b.raisedAt.compareTo(a.raisedAt);
      if (byRaisedAt != 0) return byRaisedAt;
      return a.id.value.compareTo(b.id.value);
    });
  }
}
