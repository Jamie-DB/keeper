# 02. Domain types (Phase 2)

Phase 2 asks for the false-positive policy as a document, then the domain value types with their tests: `Yard`, `Hive`, `HiveStatus`, `Metric`, `Reading`, `Anomaly`, `Alert`, `Severity`. This document teaches the five Dart constructs those types use, each with the example from `examples/watchtower/lib/src/domain/`. The plan's Phase 2 section owns the fields; this owns the language.

Files to read alongside: `server.dart`, `sample.dart`, `spike.dart`, `incident.dart`, and their tests.

## 1. A value class with `Equatable`

```dart
class Server extends Equatable {
  const new({
    required this.id,
    required this.name,
    this.status = ServerStatus.healthy,
  });

  final ServerId id;
  final String name;
  final ServerStatus status;

  @override
  List<Object?> get props => [id, name, status];
}
```

**What it is.** A class where every field is `final`, the constructor is `const`, and equality is by content. This is the shape of every domain type in Phase 2.

**Why `Equatable`.** Dart classes compare by identity: two `Server` objects with identical fields are not `==`. A Bloc that emits a new state equal in content to the old one would still rebuild the UI, and a test comparing two states would fail. `Equatable` generates `==` and `hashCode` from the `props` list. Every field goes in `props`; forgetting one is the classic bug.

**From Swift.** A Swift `struct` gets value semantics for free. A Dart class does not, so `Equatable` is the opt-in. There is no `struct` in Dart.

**Named parameters.** `{required this.id, this.status = ...}` are named parameters. `required` makes one mandatory; a default makes it optional. `this.id` is an initializing formal: it assigns the field directly, no body needed.

**Test it.** `server_test.dart` has the three tests every value class gets: equal when fields match, not equal when one differs, and the default holds.

## 2. An `enum`, plain and with a field

```dart
enum ServerStatus { healthy, degraded, maintenance }

enum Metric {
  latencyMs(sigmaFloor: 5),
  cpuPercent(sigmaFloor: 2);

  new({required this.sigmaFloor});

  final double sigmaFloor;
}
```

**What it is.** A closed set of named values. Dart enums are full classes: they can carry fields (`sigmaFloor`), methods, and a constructor, but every value is declared in the enum body. `Metric.values` is the list of all of them.

**Why a field on `Metric`.** The plan's sigma floor is per metric. Putting it on the enum means the evaluator asks `metric.sigmaFloor` rather than looking it up in a map that could miss a key.

**From Swift.** Same as a Swift enum with raw or stored values, minus associated values. For associated values, see sealed classes below.

**Test it.** Only where the enum carries behaviour. `Severity.of` below gets tests; `ServerStatus` does not.

## 3. An `extension type` for ids

```dart
extension type const ServerId(String value);
```

**What it is.** A compile-time wrapper. At runtime a `ServerId` is the `String` it wraps; there is no allocation. At compile time it is a distinct type, so a function that takes `ServerId` will not accept an `IncidentId` or a bare `String`.

**Why.** The plan asks for `HiveId` and `AlertId`. Two ids that are both strings get mixed up; two ids that are different types cannot be.

**Equality.** The wrapped value's. No `Equatable` needed. `server_test.dart` checks it.

## 4. A record for values that travel together

```dart
typedef Extent = ({double magnitude, int duration});

// building one
extent: (magnitude: 3.5, duration: 2)

// reading one
extent.magnitude
```

**What it is.** An anonymous, immutable bundle of named fields with structural equality built in. The `typedef` gives the shape a name so signatures read well.

**Why here.** The plan asks for the anomaly's magnitude-and-duration pair as a record. Two values that always travel together and mean nothing apart are a record; a class would add a name and a file for no gain.

**From Swift.** A named tuple, with equality.

## 5. A sealed class with an exhaustive `switch`

```dart
sealed class CheckResult extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class Spiked extends CheckResult {
  const new(this.spike);
  final Spike spike;

  @override
  List<Object?> get props => [spike];
}

final class Normal extends CheckResult {
  const new();
}

final class Warming extends CheckResult {
  const new();
}
```

**What it is.** A `sealed` class can only be extended in its own file, so the set of subtypes is closed and known to the compiler. A `switch` over a `CheckResult` must cover `Spiked`, `Normal` and `Warming` or the analyzer errors. Add a fourth and every switch that forgot it stops compiling.

```dart
switch (checker.check(sample)) {
  case Spiked(:final spike):
    // `:final spike` pulls the field out. This is pattern matching.
  case Normal():
    // ...
  case Warming():
    // ...
}
```

**Why.** This is the plan's `EvaluationResult` and every Bloc state. Three outcomes instead of "an anomaly or null" because the third one, not judged, must never look like the second, fine.

**From Swift.** An enum with associated values, switched exhaustively. `final class` on each subtype means nothing can extend it further.

## 6. Severity as a table

```dart
enum Severity {
  low, medium, high;

  static Severity of(Extent extent) {
    final distance = extent.magnitude.abs();
    if (distance >= 6) return Severity.high;
    if (distance >= 4.5) return Severity.medium;
    return Severity.low;
  }
}
```

The example uses one dimension. Keeper's table has two, magnitude tier by duration tier, nine cells. Write it as a lookup a person can read, and write nine tests, one per cell. A static method on the enum keeps the rule next to the values it produces.

## 7. A pure Dart test

```dart
void main() {
  group(Server, () {
    test('is equal to another server with the same fields', () {
      const a = Server(id: ServerId('web-1'), name: 'web-1');
      const b = Server(id: ServerId('web-1'), name: 'web-1');
      expect(a, equals(b));
    });
  });
}
```

- `group(Server, ...)` takes the type, not a string, so a rename is caught.
- Test names read as a sentence after the group: "Server is equal to another server with the same fields".
- `expect(actual, matcher)`. Matchers: `equals`, `isNot`, `isA<T>()`, `closeTo(value, delta)`, `isEmpty`, `hasLength(n)`, `everyElement(m)`.
- Domain tests import `package:flutter_test/flutter_test.dart` in `app/` (the example uses `package:test` because it has no Flutter). Same API.
- Run one folder fast: `flutter test test/domain` from `app/`.

## Checklist for Phase 2

- [ ] `docs/false-positive-policy.md` written first, one sentence of reasoning per number, plus what a false negative costs against a false positive.
- [ ] `equatable` added to `app/pubspec.yaml` under `dependencies`.
- [ ] One file per type under `app/lib/domain/`, one test file each under `app/test/domain/`.
- [ ] `HiveId` and `AlertId` as extension types. `Metric` with its sigma floor. `Severity` as a table with nine tests.
- [ ] Every `Equatable` class: `const` constructor, all fields `final`, all fields in `props`, equality tests.
- [ ] `flutter analyze` clean and `dart format lib test` run before the commit.

<details>
<summary><strong>Hints for Phase 2. Open if stuck.</strong></summary>

- Start with `Metric` and `HiveId`. They have no dependencies and everything else imports them.
- If the analyzer says "the constructor being called isn't a const constructor", a field in the class is not `final` or a nested value is not `const`.
- A `DateTime` cannot be `const`. Types that hold one (`Reading`, `Alert`) still get `const` constructors; only the call sites that pass a `DateTime` cannot be `const`. Tests build them with `final` and a fixed `DateTime.utc(...)`.
- `List<Anomaly>` in `props` compares element by element through `Equatable`. A `Set` does too. A `Map` does not, so avoid one in a state.
- Put imports in the form `package:keeper/domain/metric.dart`, never a relative `../`. The lints ask for it and the barrel later depends on it.
- `dart format` is not optional and the formatter has one style. Run it and stop arguing with it.

</details>
