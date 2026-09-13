# 03. The evaluator (Phase 3)

Phase 3 asks for `evaluator.dart`, `baseline.dart` and `candidate_causes.dart`, with seventeen named test cases. This document walks the example checker in `examples/watchtower/lib/src/domain/latency_checker.dart`, which has every rule the plan names at smaller numbers, then the cause ranking in `candidate_causes.dart`.

## The shape: a fold with state

```dart
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

  final List<double> _inBand = [];
  int _streak = 0;
  bool _open = false;
  DateTime? _previousAt;
  late DateTime _startedAt;

  CheckResult check(Sample sample) { ... }
}
```

**Why an object, not a function.** The verdict on sample `n` decides whether `n` enters the window that sample `n + 1` is judged against. So the window and the loop belong together, and the thing that owns them carries state between calls. Three rules need that state: the consecutive count, whether a run is open, and the previous timestamp for the gap rule. The plan leaves the shape of the carried state to you; the example uses four private fields.

**Every rule is a parameter with a default.** A test can pass `consecutive: 2` and `window: 8` to keep fixtures small. Keeper's defaults are the plan's numbers: 672, 336, 3.0, 2.5, 3, fifteen minutes.

## The body, rule by rule

```dart
CheckResult check(Sample sample) {
  final previousAt = _previousAt;
  _previousAt = sample.at;
  if (previousAt != null && sample.at.difference(previousAt) > cadence * 2) {
    _streak = 0;
    _open = false;
  }
```
Decision 6, the gap rule. A silent sensor resets the counter and raises nothing.

```dart
  if (_inBand.length < minimumHistory) {
    _admit(sample.value);
    return const Warming();
  }
```
Decision 1. Below minimum history, the sample enters the window unjudged and the result is the third outcome, not `Normal`. This is how the window fills.

```dart
  final mean = _inBand.reduce((a, b) => a + b) / _inBand.length;
  final variance = _inBand
      .map((value) => (value - mean) * (value - mean))
      .reduce((a, b) => a + b) / _inBand.length;
  final sigma = max(sqrt(variance), metric.sigmaFloor);
  final magnitude = (sample.value - mean) / sigma;
```
Decision 2 and the floor. The baseline is the trailing window, ending before this sample. `max(..., metric.sigmaFloor)` is the whole sigma-floor rule. Magnitude keeps its sign.

```dart
  final limit = _open ? clearSigma : breachSigma;
  if (magnitude.abs() < limit) {
    _streak = 0;
    _open = false;
    _admit(sample.value);
    return const Normal();
  }
```
Decision 3, hysteresis. The line to cross depends on whether a run is already open. Only an in-band sample is admitted to the window.

```dart
  _streak += 1;
  if (_streak == 1) _startedAt = sample.at;
  if (_streak < consecutive) return const Normal();
  _open = true;
  return Spiked(Spike(..., extent: (magnitude: magnitude, duration: _streak)));
}
```
Decision 5, N consecutive. Out-of-band samples before N return `Normal` but are never admitted, so an excursion cannot contaminate its own baseline.

```dart
void _admit(double value) {
  _inBand.add(value);
  if (_inBand.length > window) _inBand.removeAt(0);
}
```
The window as a count. It never drains, however long a spike runs.

## Testing a policy edge by edge

`latency_checker_test.dart` builds one fixture and reuses it:

```dart
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

void warmUp() {
  for (var i = 0; i < checker.minimumHistory; i++) {
    checker.check(sampleAt(i, 100));
  }
}
```

**The flat-series trick.** Every quiet sample sits exactly on the mean, so the window's sigma is zero and the floor takes over. With a floor of 5, a sample at 117.5 is exactly 3.5 sigma. Each test then states its case in the spec's own units and there is nothing to argue with. The plan's Phase 3 hints say the same for the nine severity cells.

Cases in the example, each one line of intent:

| Plan case | Example test |
|---|---|
| below minimum history is `InsufficientHistory`, not `WithinBand` | `returns Warming, not Normal, until minimum history is met` |
| `N - 1` raises nothing | `raises nothing at N - 1 consecutive breaches` |
| `N` raises | `raises at the Nth consecutive breach with the run length` |
| anomalous reading does not enter the baseline | `does not admit an out-of-band sample to the baseline` |
| gap resets the counter | `resets the streak after a gap longer than twice the cadence` |
| zero-sigma floor | `uses the sigma floor when the window sigma is zero` |

Missing from the example and required by the plan: the band-edge flap (a value oscillating between 2.5 and 3.0 sigma must not toggle), the window drain (a spike longer than the window must not produce `InsufficientHistory`), and the nine severity cells.

**Reading a sealed result in a test.**

```dart
final result = checker.check(sampleAt(5, 117.5));
expect(result, isA<Spiked>());
final spike = (result as Spiked).spike;
expect(spike.extent.magnitude, closeTo(3.5, 0.001));
```

`isA<T>()` checks the variant; `as` casts once you know. `closeTo` for doubles, never `equals`.

## Candidate causes: a set score

```dart
enum Signal { latencyUp, cpuUp, errorsUp, memoryUp }

enum Cause {
  deploy({Signal.latencyUp, Signal.cpuUp, Signal.errorsUp}),
  trafficSpike({Signal.latencyUp, Signal.cpuUp}),
  memoryLeak({Signal.memoryUp, Signal.latencyUp});

  new(this.predicts);
  final Set<Signal> predicts;
}

List<(Cause, double)> rankCauses(Set<Signal> observed) {
  final scored = [
    for (final cause in Cause.values)
      (
        cause,
        cause.predicts.intersection(observed).length /
            cause.predicts.union(observed).length,
      ),
  ];
  return scored..sort((a, b) => b.$2.compareTo(a.$2));
}
```

- A `Set` literal `{...}` on each enum value: the signals that cause predicts.
- `(Cause, double)` is a positional record; `.$1` and `.$2` read its fields.
- Matched over union: a cause loses points for predicting what did not happen. That is what lets a lone weight drop favour swarm over bear in keeper.
- `sort` is stable and in place. `..` is a cascade: call `sort` on the list and return the list.
- The tests are the discrimination cases the plan names, not coverage of the table.

Keeper's signals carry direction: weight down, tilt up, sound up. Model a signal as a metric plus a sign derived from the anomaly's magnitude, and let each cause declare its set.

## Checklist for Phase 3

- [ ] `evaluator.dart` with the plan's defaults as constructor parameters, `EvaluationResult` per reading.
- [ ] `baseline.dart` for the window statistics, called only from the evaluator (the fold owns both).
- [ ] `candidate_causes.dart`: signals, causes with predicted sets, union score, ties by declaration order.
- [ ] Seventeen named test cases minimum, including `ranks bear above swarm when tilt accompanies the weight drop`.
- [ ] `flutter test test/domain` green, `flutter analyze` clean, formatted, committed.

<details>
<summary><strong>Hints for Phase 3. Open if stuck.</strong></summary>

- For the nine cells, build one helper that warms up, then feeds `duration` samples at `mean + magnitude * floor`, and returns the last result. Nine tests become nine one-line calls.
- The band-edge flap test: warm up, then alternate 2.7 sigma and 3.2 sigma. With N of 3 and hysteresis, nothing should ever open. Assert every result is `WithinBand`.
- The window-drain test: warm up, then feed more out-of-band samples than the window holds. The last result must still be `Anomalous`, never `InsufficientHistory`.
- `late DateTime _startedAt` is safe because `_streak == 1` always sets it before `_streak >= N` reads it. If you restructure and the analyzer complains, make it nullable and check.
- `reduce` on an empty list throws. The minimum-history guard runs first, so the list is never empty when `reduce` runs. Keep that order.
- Under the union score, ties happen. The plan's Phase 3 hints say rank ties by declaration order and assert only the position each test names.

</details>
