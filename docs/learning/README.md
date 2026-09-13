# Learning by example

Guided scaffolding for the three phases of the plan that Jamie writes: the domain types, the evaluator, and the inbox Bloc with its repository. One document per phase, plus a walkthrough of what the Phase 1 scaffold already contains.

## Why this exists

The plan first asked for those phases to be written cold: no agent-written code, only reading. That claim was retracted on Sep 13, 2026. Jamie is new to Dart and Flutter and has nine days, and "write the class" is not enough direction for a first file in a new language. What replaced it is guided scaffolding: a complete, tested example in a different domain that has the same shape as what the plan asks for, with the reasoning written next to the code. Jamie reads the example, then writes the keeper version by hand against the plan's spec. The claim the repository now makes is narrower and true: the domain, evaluator and Bloc were written by Jamie, by example, and every agent-written file was read before it was accepted.

## The example domain

The examples watch **servers**, not hives. Same shapes, different nouns, so writing the keeper version is a translation with decisions in it rather than a retype.

| Watchtower (the example) | Keeper (what you write) |
|---|---|
| `Server`, `ServerId`, `ServerStatus` | `Hive`, `HiveId`, `HiveStatus`, plus `Yard` |
| `Metric` (latency, cpu) with a sigma floor | `Metric` (weight, brood temperature, humidity, sound, tilt) with a sigma floor |
| `Sample` | `Reading` |
| `Spike` with an `Extent` record | `Anomaly` with its magnitude-and-duration record |
| `Incident` carrying a list of spikes | `Alert` carrying a list of anomalies |
| `CheckResult`: `Spiked`, `Normal`, `Warming` | `EvaluationResult`: `Anomalous`, `WithinBand`, `InsufficientHistory` |
| `LatencyChecker` | the evaluator |
| `Signal`, `Cause`, `rankCauses` | `candidate_causes.dart` |
| `IncidentRepository` | `AlertRepository` with `seed_readings.dart` |
| `IncidentInboxBloc` | `AlertInboxBloc` |

The example's numbers are small on purpose (window 8, minimum history 4, N of 2) so a test fits on a screen. The plan's numbers are the specification for keeper: 672, 336, N of 3, and the nine-cell severity table.

## How to use it

1. Read the phase document. Each one explains a handful of Dart constructs, shows the example that uses them, and ends with a checklist and a folded hints block.
2. Run the example package and break it. It is a real Dart package under `examples/watchtower/`:
   ```sh
   cd docs/learning/examples/watchtower
   dart pub get
   dart test
   ```
   Change a threshold, watch a test fail, read why.
3. Write the keeper version in `app/` against the plan's spec. The plan's phase sections name every type, field and test. This folder explains the language; the plan owns the domain.
4. Ask questions in the agent chat. Prose answers and pointers into these examples are fine. What you should not do is have a keeper file written for you, because the point is that you can explain every line in `app/lib/domain/` on demand.

## Documents

- [01, the scaffold](01-the-scaffold.md): what `very_good create` gave you, file by file.
- [02, domain types](02-domain-types.md): Phase 2. Equatable, enums, extension types, records, sealed classes, and pure Dart tests.
- [03, the evaluator](03-the-evaluator.md): Phase 3. A stateful fold, exhaustive `switch`, and testing a policy edge by edge.
- [04, repository and Bloc](04-repository-and-bloc.md): Phase 4. Constructor injection, `blocTest`, `mocktail`, and a total sort order.

## A note on constructor syntax

You will see two constructor spellings. Older Dart, and most tutorials:

```dart
class Server {
  const Server({required this.id});
  final String id;
}
```

Dart 3.13, which this repository's lints prefer:

```dart
class Server {
  const new({required this.id});
  final String id;
}
```

They mean the same thing. `new` stands in for the class name so a rename touches one line. The examples use the second form because `flutter analyze` in `app/` will ask for it.
