import 'package:equatable/equatable.dart';
import 'package:watchtower/src/domain/sample.dart';
import 'package:watchtower/src/domain/server.dart';

/// A record: an anonymous, immutable bundle of named fields with structural
/// equality built in. Use one where two values always travel together and
/// naming a class for them would add nothing.
typedef Extent = ({double magnitude, int duration});

/// Severity as a lookup, not a float. A person can read and argue with a
/// table; nobody argues with `0.73`.
enum Severity {
  low,
  medium,
  high;

  /// Magnitude is in sigma, signed. The table reads its absolute value.
  static Severity of(Extent extent) {
    final distance = extent.magnitude.abs();
    if (distance >= 6) return Severity.high;
    if (distance >= 4.5) return Severity.medium;
    return Severity.low;
  }
}

/// One departure from baseline on one metric of one server.
class Spike extends Equatable {
  const new({
    required this.serverId,
    required this.metric,
    required this.startedAt,
    required this.extent,
  });

  final ServerId serverId;
  final Metric metric;
  final DateTime startedAt;
  final Extent extent;

  Severity get severity => Severity.of(extent);

  @override
  List<Object?> get props => [serverId, metric, startedAt, extent];
}
