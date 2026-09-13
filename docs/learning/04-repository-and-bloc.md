# 04. Repository and Bloc (Phase 4)

Phase 4 asks for `seed_readings.dart`, `AlertRepository`, and `AlertInboxBloc` with its `blocTest` cases, committed before the first gate runs. This document walks `examples/watchtower/lib/src/repositories/incident_repository.dart` and `examples/watchtower/lib/src/incident_inbox/bloc/`, and their tests.

## The repository: one concrete class, injected

```dart
class IncidentRepository {
  new({required this._servers, required this._samples});

  final List<Server> _servers;
  final List<Sample> _samples;

  Future<List<Incident>> fetchIncidents() async { ... }
}
```

- **No interface.** One implementation exists. `mocktail` mocks a concrete class, so testability is not a reason to add one. The plan's repository-shape section says why.
- **Dependencies through the constructor.** `required this._servers` is an initializing formal onto a private field. Nothing is created inside; a test passes fixtures in.
- **No Flutter import.** The repository layer is pure Dart. `Future` and `async`/`await` are the same as Swift's.
- **`Future<List<Incident>>`, not a stream.** Slice one has no live feed.

## Collapsing readings into incidents

The evaluator returns a result per sample. Consecutive `Spiked` results are one run, and a run is one incident. This is the easiest thing in the plan to get wrong: ten alerts for one bear still looks like a working inbox.

```dart
Spike? open;
for (final sample in series) {
  switch (checker.check(sample)) {
    case Spiked(:final spike):
      final previous = open?.extent.magnitude ?? 0;
      final furthest = spike.extent.magnitude.abs() > previous.abs()
          ? spike.extent.magnitude
          : previous;
      open = Spike(
        serverId: spike.serverId,
        metric: spike.metric,
        startedAt: spike.startedAt,
        extent: (magnitude: furthest, duration: spike.extent.duration),
      );
    case Normal():
      if (open != null) incidents.add(_incident(server, open));
      open = null;
    case Warming():
      break;
  }
}
if (open != null) incidents.add(_incident(server, open));
```

- `Spike? open` is a nullable local: `null` means no run in progress. `open?.extent` is null-aware access; `?? 0` is the fallback.
- The run's duration is its length; its magnitude is the furthest reading, sign kept. A run ends on the first `Normal`, and a run still open at the end of the series is closed after the loop.
- The `switch` is exhaustive over the sealed result, so `Warming` must be listed even to do nothing.

Keeper adds a second stage the example skips: runs open at the same time on the same hive across different metrics become one alert carrying every anomaly. Group by hive, find overlapping run intervals, and merge. `candidate_causes` then scores the whole signal set of that alert.

## The seed generator

The example passes literal samples in from the test. Keeper's `seed_readings.dart` generates them: a function takes excursion specs (hive, metric, start, magnitude in sigma, duration in readings) and produces seven days of quiet history with the excursions placed on top. Nothing is a literal. The Phase 4 hints cover the arithmetic: noise on the quiet series only, excursion readings at exactly mean plus magnitude times sigma, specs in the middle of tiers.

The repository test `derives severity from the spike` is the one that proves the evaluator actually ran: a spec of a known magnitude and duration yields the severity the table predicts.

## The Bloc: events in, states out

```dart
class IncidentInboxBloc extends Bloc<IncidentInboxEvent, IncidentInboxState> {
  new({required this._repository}) : super(const IncidentInboxLoading()) {
    on<IncidentInboxLoadRequested>(_onLoadRequested);
  }

  final IncidentRepository _repository;

  Future<void> _onLoadRequested(
    IncidentInboxLoadRequested event,
    Emitter<IncidentInboxState> emit,
  ) async {
    emit(const IncidentInboxLoading());
    try {
      final incidents = await _repository.fetchIncidents();
      emit(IncidentInboxLoaded(_ordered(incidents)));
    } on Exception {
      emit(const IncidentInboxLoadFailure());
    }
  }
}
```

- `super(const IncidentInboxLoading())` sets the initial state.
- `on<Event>(handler)` registers one handler per event type. The sealed event class means the registrations are the complete list.
- The handler `emit`s states in order. A `blocTest` asserts that exact sequence.
- `on Exception` catches only `Exception` subtypes, not programming errors. A test triggers it by making the mock throw.

**Event and state files** are `part of` the Bloc file, so they share its imports:

```dart
sealed class IncidentInboxState extends Equatable {
  const new();
  @override
  List<Object?> get props => [];
}

final class IncidentInboxLoading extends IncidentInboxState { const new(); }
final class IncidentInboxLoaded extends IncidentInboxState {
  const new(this.incidents);
  final List<Incident> incidents;
  @override
  List<Object?> get props => [incidents];
}
final class IncidentInboxLoadFailure extends IncidentInboxState { const new(); }
```

No `Empty` state. An empty inbox is `Loaded` with an empty list. Events are named as past-tense facts (`LoadRequested`); states as nouns.

## A total order, applied once

```dart
static List<Incident> _ordered(List<Incident> incidents) {
  return [...incidents]..sort((a, b) {
    final bySeverity = b.severity.index.compareTo(a.severity.index);
    if (bySeverity != 0) return bySeverity;
    final byRaisedAt = b.raisedAt.compareTo(a.raisedAt);
    if (byRaisedAt != 0) return byRaisedAt;
    return a.id.value.compareTo(b.id.value);
  });
}
```

- `[...incidents]` copies the list; `sort` is in place, and the input must not be mutated.
- Three keys: severity descending, raised-at descending, id ascending. Any two incidents order the same way every run, so a widget test cannot flake.
- The state carries the ordered list. The widget never sorts.

## Testing with `blocTest` and `mocktail`

```dart
class _MockIncidentRepository extends Mock implements IncidentRepository;

late IncidentRepository repository;

setUp(() {
  repository = _MockIncidentRepository();
});

blocTest<IncidentInboxBloc, IncidentInboxState>(
  'emits failure when the repository throws',
  setUp: () {
    when(() => repository.fetchIncidents()).thenThrow(Exception('down'));
  },
  build: () => IncidentInboxBloc(repository: repository),
  act: (bloc) => bloc.add(const IncidentInboxLoadRequested()),
  expect: () => const [IncidentInboxLoading(), IncidentInboxLoadFailure()],
);
```

- **The mock** is one line: extend `Mock`, implement the concrete class. Private, underscore-prefixed, one per test file.
- **`when(() => ...).thenAnswer((_) async => value)`** stubs an async method. `thenThrow` for the failure path. Stub inside `setUp:` of each `blocTest` so each case states its own world.
- **`build`** creates the Bloc. **`act`** adds the event. **`expect`** is the exact list of states emitted after `act`, in order. The initial state is not in the list.
- **`late` plus `setUp` inside the group**, so every test gets a fresh mock.
- The sort test hands the mock four incidents out of order and expects the ordered list. Two share a severity and time so the id tie-break is exercised. The plan names this test: `orders by severity then raised-at then id`.

## Checklist for Phase 4

- [ ] `seed_readings.dart` generating from specs. Two yards, several hives, two specs with identical magnitude and duration on different hives, one hive with four overlapping specs (the bear), one hive below minimum history.
- [ ] `AlertRepository` with `fetchAlerts()`, constructor injection, no Flutter import, no interface. Runs the evaluator, collapses runs, merges overlapping runs per hive, ranks causes.
- [ ] Repository tests named by the plan: `derives severity from the excursion spec`, `raises nothing for a hive below the minimum history`, `collapses one excursion into one alert`, `collapses a four-metric bear into one alert`.
- [ ] `AlertInboxBloc`, events and states per the plan's state-shape section, ordering applied when `AlertInboxLoaded` is built.
- [ ] `blocTest` cases: load success, empty, failure, and `orders by severity then raised-at then id`.
- [ ] Commit before the gate runs. Phases 2, 3 and 4 read `Done` in the plan in that commit.

<details>
<summary><strong>Hints for Phase 4. Open if stuck.</strong></summary>

- Write the Bloc before the seed. It only needs the repository's signature and a mock, so it can be green while the generator is still being tuned.
- `blocTest` `expect` compares with `==`. Every state and everything inside it must be `Equatable` or the test fails on identical content. `DateTime` and `List` compare fine through `Equatable` props.
- If `expect` shows the right states in the wrong order, the handler is emitting before awaiting. Emit `Loading` first, then `await`, then `Loaded`.
- For the multi-metric merge, an interval overlaps another when `a.start <= b.end && b.start <= a.end`. Sort runs by start, then sweep.
- The four-metric bear needs four specs with the same hive and the same start time. Nothing else is required for the runs to overlap.
- If a repository test fails only by a sigma or two, the fixture's noise is the cause. Specs sit mid-tier for that reason; check the value is 3.75, 5.25 or 7.5 and not on an edge.

</details>
