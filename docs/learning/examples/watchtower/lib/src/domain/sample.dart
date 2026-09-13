import 'package:equatable/equatable.dart';
import 'package:watchtower/src/domain/server.dart';

/// An enum with a field: each metric declares the smallest deviation worth
/// noticing in its own units. The checker uses it as a floor on sigma so a
/// perfectly flat history cannot divide by zero.
enum Metric {
  latencyMs(sigmaFloor: 5),
  cpuPercent(sigmaFloor: 2);

  new({required this.sigmaFloor});

  final double sigmaFloor;
}

/// One measurement from one server for one metric at one instant.
class Sample extends Equatable {
  const new({
    required this.serverId,
    required this.metric,
    required this.at,
    required this.value,
  });

  final ServerId serverId;
  final Metric metric;
  final DateTime at;
  final double value;

  @override
  List<Object?> get props => [serverId, metric, at, value];
}
