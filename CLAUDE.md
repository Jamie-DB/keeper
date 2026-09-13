# CLAUDE.md

Hive monitoring app. Sensors on beehives report on a schedule, a backend scores each reading against a per-hive per-metric baseline, and the beekeeper triages the resulting alerts into a planned yard visit. It helps its user identify, locate and fix a problem. It is not a dashboard.

Current plan: `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md`. That is the authority. `docs/original-plan.md` is the superseded original, kept for its domain reasoning and cited by section. Repo standards: `docs/repo-standards.md`. Read the current plan before proposing work.

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
very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart **/l10n/gen/*.dart **/main_*.dart **/bootstrap.dart' --collect-coverage-from all
```

The exclusion is not optional. Drift and GraphQL codegen both emit `.g.dart` and the gate will chase them forever. `--collect-coverage-from all` is not optional either. The default is `imports`, which leaves any `lib/` file no test imports out of the denominator, so a gate can pass over a file it never measured. Under `all` the l10n output and the entry points must be excluded too, or the gate re-adds them at zero and the untouched scaffold fails. `app/very_good.yaml` carries the same settings, so a bare `very_good test` in `app/` is the gate, including through the MCP tool, which has no `--collect-coverage-from` flag.

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

## Learned Rules

1. [SPEC] Where `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md` and `docs/original-plan.md` disagree, the plan wins, because the build plan is a frozen third iteration and the plan records every override with its reason in a deltas table.
2. [DOMAIN] Never reintroduce `YardConditions`, an evaluator weather parameter, or `Season`, because they were cut on Sep 11, 2026 for having no caller. The build plan and the brainstorm both argue to keep the parameter and both are overridden. Cause ranking keys on signals alone, with no calendar anywhere in the domain.
3. [DOMAIN] An alert is a hive incident, never a metric excursion, because correlated signals across metrics are what let a bear outrank a swarm in the candidate causes. Runs open at the same time on one hive collapse into one alert carrying every signal. The build plan's bear scenario asks for four alerts on one hive and is overridden.
4. [REVIEW] Audit a design document by tracing data paths and cross-phase dependencies, not by reading prose, because every defect found in this plan came from following data and none came from reading.
