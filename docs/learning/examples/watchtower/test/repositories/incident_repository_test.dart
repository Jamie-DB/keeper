import 'package:test/test.dart';
import 'package:watchtower/watchtower.dart';

void main() {
  group(IncidentRepository, () {
    const server = Server(id: ServerId('web-1'), name: 'web-1');
    final start = DateTime.utc(2026, 9, 13, 10);

    /// Flat history at 100, then [spikeLength] samples at 140, then flat.
    List<Sample> seriesWithSpike({required int spikeLength}) => [
      for (var i = 0; i < 12 + spikeLength; i++)
        Sample(
          serverId: server.id,
          metric: Metric.latencyMs,
          at: start.add(Duration(minutes: i)),
          value: i >= 6 && i < 6 + spikeLength ? 140 : 100,
        ),
    ];

    test('collapses one excursion into one incident', () async {
      final repository = IncidentRepository(
        servers: const [server],
        samples: seriesWithSpike(spikeLength: 5),
      );

      final incidents = await repository.fetchIncidents();

      expect(incidents, hasLength(1));
      expect(incidents.single.spikes.single.extent.duration, 5);
    });

    test('derives severity from the spike', () async {
      final repository = IncidentRepository(
        servers: const [server],
        samples: seriesWithSpike(spikeLength: 3),
      );

      final incidents = await repository.fetchIncidents();

      // 140 on a flat 100 with floor 5 is 8 sigma: high.
      expect(incidents.single.severity, Severity.high);
    });

    test('raises nothing for a server below minimum history', () async {
      final repository = IncidentRepository(
        servers: const [server],
        samples: [
          for (var i = 0; i < 3; i++)
            Sample(
              serverId: server.id,
              metric: Metric.latencyMs,
              at: start.add(Duration(minutes: i)),
              value: 140,
            ),
        ],
      );

      expect(await repository.fetchIncidents(), isEmpty);
    });
  });
}
