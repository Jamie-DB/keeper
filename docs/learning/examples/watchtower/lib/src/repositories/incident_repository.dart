import 'package:watchtower/src/domain/check_result.dart';
import 'package:watchtower/src/domain/incident.dart';
import 'package:watchtower/src/domain/latency_checker.dart';
import 'package:watchtower/src/domain/sample.dart';
import 'package:watchtower/src/domain/server.dart';
import 'package:watchtower/src/domain/spike.dart';

/// One concrete repository. No interface, because there is one
/// implementation and `mocktail` mocks a concrete class.
///
/// Dependencies come in through the constructor and nothing here imports
/// Flutter. This is the one place arithmetic becomes a decision: samples go
/// in, incidents come out.
class IncidentRepository {
  new({required this._servers, required this._samples});

  final List<Server> _servers;
  final List<Sample> _samples;

  Future<List<Incident>> fetchIncidents() async {
    final incidents = <Incident>[];
    for (final server in _servers) {
      for (final metric in Metric.values) {
        final series =
            _samples
                .where((s) => s.serverId == server.id && s.metric == metric)
                .toList()
              ..sort((a, b) => a.at.compareTo(b.at));
        final checker = LatencyChecker(metric: metric);

        // Consecutive Spiked results are one run, and one run is one
        // incident. Keep the furthest reading in the run.
        Spike? open;
        for (final sample in series) {
          switch (checker.check(sample)) {
            case Spiked(:final spike):
              // Duration is the run length; magnitude is the furthest
              // reading in the run, sign kept.
              final previous = open?.extent.magnitude ?? 0;
              final furthest = spike.extent.magnitude.abs() > previous.abs()
                  ? spike.extent.magnitude
                  : previous;
              open = Spike(
                serverId: spike.serverId,
                metric: spike.metric,
                startedAt: spike.startedAt,
                extent: (magnitude: furthest, duration: spike.extent.duration),
              );
            case Normal():
              if (open != null) incidents.add(_incident(server, open));
              open = null;
            case Warming():
              break;
          }
        }
        if (open != null) incidents.add(_incident(server, open));
      }
    }
    return incidents;
  }

  Incident _incident(Server server, Spike spike) => Incident(
    id: IncidentId(
      '${server.id.value}-${spike.metric.name}-'
      '${spike.startedAt.toIso8601String()}',
    ),
    server: server,
    raisedAt: spike.startedAt,
    spikes: [spike],
  );
}
