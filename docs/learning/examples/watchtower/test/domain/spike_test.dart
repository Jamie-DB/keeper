import 'package:test/test.dart';
import 'package:watchtower/watchtower.dart';

void main() {
  group(Severity, () {
    test('reads the absolute magnitude, so a drop and a rise score alike', () {
      expect(Severity.of((magnitude: -7, duration: 1)), Severity.high);
      expect(Severity.of((magnitude: 7, duration: 1)), Severity.high);
    });

    test('is low from the band edge up to 4.5 sigma', () {
      expect(Severity.of((magnitude: 3, duration: 1)), Severity.low);
      expect(Severity.of((magnitude: 4.49, duration: 1)), Severity.low);
    });

    test('is medium from 4.5 sigma', () {
      expect(Severity.of((magnitude: 4.5, duration: 1)), Severity.medium);
    });
  });

  group(Spike, () {
    final startedAt = DateTime.utc(2026, 9, 13, 10);

    test('compares its record field structurally', () {
      final a = Spike(
        serverId: const ServerId('web-1'),
        metric: Metric.latencyMs,
        startedAt: startedAt,
        extent: (magnitude: 5, duration: 3),
      );
      final b = Spike(
        serverId: const ServerId('web-1'),
        metric: Metric.latencyMs,
        startedAt: startedAt,
        extent: (magnitude: 5, duration: 3),
      );
      expect(a, equals(b));
    });

    test('derives severity from its extent', () {
      final spike = Spike(
        serverId: const ServerId('web-1'),
        metric: Metric.latencyMs,
        startedAt: startedAt,
        extent: (magnitude: 5, duration: 3),
      );
      expect(spike.severity, Severity.medium);
    });
  });
}
