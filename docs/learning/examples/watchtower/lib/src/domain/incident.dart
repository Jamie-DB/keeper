import 'package:equatable/equatable.dart';
import 'package:watchtower/src/domain/server.dart';
import 'package:watchtower/src/domain/spike.dart';

extension type const IncidentId(String value);

/// One thing happening to one server, carrying every spike that was open at
/// the same time. One spike is the common case; several is a correlated
/// failure.
class Incident extends Equatable {
  const new({
    required this.id,
    required this.server,
    required this.raisedAt,
    required this.spikes,
  });

  final IncidentId id;
  final Server server;
  final DateTime raisedAt;
  final List<Spike> spikes;

  /// Worst spike wins. Stated as a rule so the limitation is visible: a
  /// quiet correlated failure scores as its loudest single signal.
  Severity get severity => spikes
      .map((spike) => spike.severity)
      .reduce((a, b) => a.index >= b.index ? a : b);

  @override
  List<Object?> get props => [id, server, raisedAt, spikes];
}
