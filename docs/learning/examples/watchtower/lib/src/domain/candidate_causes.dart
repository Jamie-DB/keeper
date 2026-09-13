/// A signal is a metric and a direction, nothing more, because that is all
/// the checker can emit.
enum Signal { latencyUp, cpuUp, errorsUp, memoryUp }

/// Each cause declares the signals it predicts. A table, not a model.
enum Cause {
  deploy({Signal.latencyUp, Signal.cpuUp, Signal.errorsUp}),
  trafficSpike({Signal.latencyUp, Signal.cpuUp}),
  memoryLeak({Signal.memoryUp, Signal.latencyUp});

  new(this.predicts);

  final Set<Signal> predicts;
}

/// Matched over the union of predicted and observed, so a cause is penalised
/// for predicting what did not happen as well as rewarded for explaining
/// what did. Ties keep declaration order.
List<(Cause, double)> rankCauses(Set<Signal> observed) {
  final scored = [
    for (final cause in Cause.values)
      (
        cause,
        cause.predicts.intersection(observed).length /
            cause.predicts.union(observed).length,
      ),
  ];
  // `sort` is in place and stable in Dart, so equal scores keep their order.
  return scored..sort((a, b) => b.$2.compareTo(a.$2));
}
