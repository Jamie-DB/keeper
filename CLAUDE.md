# CLAUDE.md

Hive monitoring app. Sensors on beehives report on a schedule, a backend scores each reading against a per-hive per-metric baseline, and the beekeeper triages the resulting alerts into a planned yard visit. It helps its user identify, locate and fix a problem. It is not a dashboard.

Full spec: `docs/build-plan.md`. Repo standards: `docs/repo-standards.md`. Read the spec before proposing work.

## Hard rules

- **Never weaken a gate to pass it.** No deleting a failing assertion, no `// coverage:ignore` on reachable code, no lowering the coverage floor without an issue explaining why.
- **Read every agent-written file before accepting it, and write one paragraph on what it did and why.** Not a diff summary. An account of the decision the code makes and whether it was right. If a file cannot be explained on demand it gets rewritten by hand rather than patched.
- **No fabricated claims in the README or the build log.** Shortcomings are stated plainly. Where something is not done, it is an open issue, not a silence.
- **Never lead with generation time.** A wall-clock number only appears alongside its verification cost.
- No em dashes. No hype adjectives.

## Architecture

Four layers, dependencies in one direction only: Presentation to Business Logic to Repository to Data. Never skip or invert a layer. Data and Repository hold no Flutter imports. Repositories never import other repositories, one per domain, dependencies through the constructor. Barrel exports at every package boundary, so `src/` is never imported directly.

`packages/hive_domain/` is pure Dart with no Flutter imports, because the simulator scores readings with the same evaluator the app uses.

## State management

Bloc, not Cubit, wherever the event-to-state trail is worth having. Cubit only when the state is simple and UI-driven. Sealed classes for events and multi-state types, Equatable on every state and event, exhaustive `switch` in the UI. Page provides the Bloc, View consumes it. No business logic in a widget. No Bloc talks to another Bloc directly.

`bloc_concurrency` transformers where they earn it: `sequential` on the outbox, `restartable` on inbox search.

## Testing

`mocktail`, never `mockito`. `blocTest()` for every Bloc, never raw `test()` with manual stream assertions. Private mocks per file, underscore-prefixed. Test names read as sentences down the group hierarchy. `setUp` and `tearDown` live inside a group. Mutable objects are `late` and assigned in `setUp`. Widget tests go through the shared `pumpApp` helper, never an inline `pumpWidget(MaterialApp(...))`.

```
very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart'
```

The exclusion is not optional. Drift and GraphQL codegen both emit `.g.dart` and the gate will chase them forever.

## Commands and flavors

Scaffolded by Very Good CLI, so an iOS build needs the flavor flag:

```
flutter run --flavor development --target lib/main_development.dart
```

Development points at the in-process fake, staging at the local simulator.

## Workflow

One issue per slice with a checklist, evidence in comments. Every slice merges through a pull request reviewed three ways: CodeRabbit, the `flutter-reviewer` subagent, and `/review`. Keep the comparison table in the README current.

`/create-pr` and `/rebase` cannot be model-invoked. Jamie types those.

## Sequencing rules that are easy to get wrong

- The sync contract is written before the first `TriageAction`, not before the outbox.
- The domain package is extracted at the start of slice two, deliberately late, and the cost is timed and written up.
- Hand-written tests are committed before the first green gate runs, so the gate's additions stay visible as a diff.
