import 'package:test/test.dart';
import 'package:watchtower/watchtower.dart';

void main() {
  group('rankCauses', () {
    test('ranks deploy above traffic spike when errors accompany the load', () {
      final ranked = rankCauses({
        Signal.latencyUp,
        Signal.cpuUp,
        Signal.errorsUp,
      });
      expect(ranked.first.$1, Cause.deploy);
      expect(ranked.first.$2, 1.0);
    });

    test('ranks traffic spike above deploy on latency and cpu alone', () {
      final ranked = rankCauses({Signal.latencyUp, Signal.cpuUp});
      expect(ranked.first.$1, Cause.trafficSpike);
      // deploy explains both but predicted a third that did not happen.
      expect(ranked[1].$1, Cause.deploy);
      expect(ranked[1].$2, closeTo(2 / 3, 0.001));
    });

    test('keeps declaration order on a tie', () {
      final ranked = rankCauses({Signal.latencyUp});
      // Every cause predicts latencyUp plus others; scores tie at 1/3 or 1/2.
      expect(ranked.map((r) => r.$1).toList(), [
        Cause.trafficSpike,
        Cause.memoryLeak,
        Cause.deploy,
      ]);
    });
  });
}
