import 'dart:math';

import 'package:watchtower/src/domain/check_result.dart';
import 'package:watchtower/src/domain/sample.dart';
import 'package:watchtower/src/domain/spike.dart';

/// A fold over one server's samples for one metric.
///
/// Feed it samples in time order and it returns a [CheckResult] per sample.
/// It is not a pure function of one sample: the verdict on sample `n` decides
/// whether `n` enters the baseline that sample `n + 1` is judged against, so
/// one object owns both the window and the loop. Every rule below is a
/// constructor parameter with a default, so a test can shrink the numbers.
class LatencyChecker {
  new({
    required this.metric,
    this.window = 8,
    this.minimumHistory = 4,
    this.breachSigma = 3,
    this.clearSigma = 2.5,
    this.consecutive = 2,
    this.cadence = const Duration(minutes: 1),
  });

  final Metric metric;

  /// How many in-band samples the baseline is computed over. A count, not a
  /// span of time, so a long spike cannot drain it.
  final int window;

  /// Below this many in-band samples nothing is judged.
  final int minimumHistory;

  /// Leave the band at this many sigma.
  final double breachSigma;

  /// Once out, come back only under this many sigma. Strictly lower than
  /// [breachSigma], so a value on the line cannot flap.
  final double clearSigma;

  /// Breaches in a row before the first [Spiked].
  final int consecutive;

  final Duration cadence;

  final List<double> _inBand = [];
  int _streak = 0;
  bool _open = false;
  DateTime? _previousAt;
  late DateTime _startedAt;

  CheckResult check(Sample sample) {
    final previousAt = _previousAt;
    _previousAt = sample.at;
    if (previousAt != null && sample.at.difference(previousAt) > cadence * 2) {
      // A silent sensor is neither inside the band nor outside it.
      _streak = 0;
      _open = false;
    }

    if (_inBand.length < minimumHistory) {
      _admit(sample.value);
      return const Warming();
    }

    final mean = _inBand.reduce((a, b) => a + b) / _inBand.length;
    final variance =
        _inBand
            .map((value) => (value - mean) * (value - mean))
            .reduce((a, b) => a + b) /
        _inBand.length;
    final sigma = max(sqrt(variance), metric.sigmaFloor);
    final magnitude = (sample.value - mean) / sigma;
    final limit = _open ? clearSigma : breachSigma;

    if (magnitude.abs() < limit) {
      _streak = 0;
      _open = false;
      _admit(sample.value);
      return const Normal();
    }

    // Outside the band. Never admitted to the window, judged or not.
    _streak += 1;
    if (_streak == 1) _startedAt = sample.at;
    if (_streak < consecutive) return const Normal();
    _open = true;
    return Spiked(
      Spike(
        serverId: sample.serverId,
        metric: sample.metric,
        startedAt: _startedAt,
        extent: (magnitude: magnitude, duration: _streak),
      ),
    );
  }

  void _admit(double value) {
    _inBand.add(value);
    if (_inBand.length > window) _inBand.removeAt(0);
  }
}
