import 'package:equatable/equatable.dart';
import 'package:watchtower/src/domain/spike.dart';

/// A sealed class is a closed set of subtypes, all declared in this file.
///
/// It is the closest Dart has to a Swift enum with associated values. Because
/// the set is closed, a `switch` over a `CheckResult` must handle every case
/// or the analyzer reports an error, and adding a fourth outcome later fails
/// every switch that forgot it. That is the whole point of three outcomes
/// rather than "a spike or null": a warming-up server must never read as a
/// healthy one.
sealed class CheckResult extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// Judged, and outside the band for long enough to count.
final class Spiked extends CheckResult {
  const new(this.spike);

  final Spike spike;

  @override
  List<Object?> get props => [spike];
}

/// Judged, and fine.
final class Normal extends CheckResult {
  const new();
}

/// Not judged at all: too little history to say anything.
final class Warming extends CheckResult {
  const new();
}
