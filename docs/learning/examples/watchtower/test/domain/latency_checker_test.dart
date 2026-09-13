import 'package:test/test.dart';
import 'package:watchtower/watchtower.dart';

void main() {
  group(LatencyChecker, () {
    const serverId = ServerId('web-1');
    final start = DateTime.utc(2026, 9, 13, 10);

    /// A flat series: every sample at the mean. Sigma is then exactly the
    /// metric's floor, so a sample at `mean + 3.5 * floor` is exactly 3.5
    /// sigma and each test states its case in the spec's own units.
    Sample sampleAt(int index, double value) => Sample(
      serverId: serverId,
      metric: Metric.latencyMs,
      at: start.add(Duration(minutes: index)),
      value: value,
    );

    late LatencyChecker checker;

    setUp(() {
      checker = LatencyChecker(metric: Metric.latencyMs);
    });

    /// Feeds [minimumHistory] flat samples so the checker starts judging.
    void warmUp() {
      for (var i = 0; i < checker.minimumHistory; i++) {
        checker.check(sampleAt(i, 100));
      }
    }

    test('returns Warming, not Normal, until minimum history is met', () {
      final results = [
        for (var i = 0; i < checker.minimumHistory; i++)
          checker.check(sampleAt(i, 100)),
      ];
      expect(results, everyElement(const Warming()));
      expect(checker.check(sampleAt(4, 100)), const Normal());
    });

    test('raises nothing at N - 1 consecutive breaches', () {
      warmUp();
      // floor is 5, so 100 + 3.5 * 5 is 3.5 sigma: outside the 3.0 band.
      expect(checker.check(sampleAt(4, 117.5)), const Normal());
    });

    test('raises at the Nth consecutive breach with the run length', () {
      warmUp();
      checker.check(sampleAt(4, 117.5));
      final result = checker.check(sampleAt(5, 117.5));
      expect(result, isA<Spiked>());
      final spike = (result as Spiked).spike;
      expect(spike.extent.duration, 2);
      expect(spike.extent.magnitude, closeTo(3.5, 0.001));
      expect(spike.startedAt, start.add(const Duration(minutes: 4)));
    });

    test('does not admit an out-of-band sample to the baseline', () {
      warmUp();
      checker
        ..check(sampleAt(4, 117.5))
        ..check(sampleAt(5, 117.5));
      // If the two spikes had entered the window the mean would have moved
      // and this in-band sample would score differently from zero.
      final result = checker.check(sampleAt(6, 100));
      expect(result, const Normal());
    });

    test('resets the streak after a gap longer than twice the cadence', () {
      warmUp();
      checker.check(sampleAt(4, 117.5));
      // Three minutes later, with a one-minute cadence: a gap.
      final result = checker.check(sampleAt(7, 117.5));
      expect(result, const Normal());
    });

    test('uses the sigma floor when the window sigma is zero', () {
      warmUp();
      // A flat window has sigma 0. Without the floor this divides by zero.
      checker.check(sampleAt(4, 140));
      final result = checker.check(sampleAt(5, 140)) as Spiked;
      expect(result.spike.extent.magnitude, closeTo(8, 0.001));
    });
  });
}
