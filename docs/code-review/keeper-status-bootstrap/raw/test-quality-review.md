# Test Quality Review

Branch: `keeper-status-bootstrap` vs `origin/main`
Scope: root CI/config files, `app/very_good.yaml`, `app/pubspec.yaml`, the scaffold's own test suite, and the plan doc. Platform directories excluded per instructions.

## Context that shaped this review

`app/` is an untouched `very_good create flutter_app keeper` scaffold (CLI 1.5.0). Its test suite (`app/test/**`) and the counter feature it tests are template defaults, not hand-written for this branch. The hand-edited surface that actually governs testing is: `app/very_good.yaml`, `.github/workflows/main.yaml`, `README.md`'s build/gate section, and `CLAUDE.md`'s Testing section. The review therefore weighs two things separately: (1) does the test-gate configuration hang together and match the plan's stated rationale, and (2) does the scaffold's shipped test suite already conform to the project's testing conventions (since it stays in the tree until a later PR removes the counter feature).

Per task instructions: the counter feature's existence is not a finding, `flutter test`/`very_good test` were not re-run (the gate was already confirmed green at 100% with the stated exclusions), and no destructive commands were used.

## Coverage Summary

- Test run: not re-executed (per instructions); prior run reported as passing at 100% coverage with the `app/very_good.yaml` exclusions.
- Coverage floor: 100%, `collect_coverage_from: all`, exclusions `**/*.g.dart **/l10n/gen/*.dart **/main_*.dart **/bootstrap.dart`.
- Files with tests: 4/4 testable scaffold units have a corresponding test file (`App`, `CounterCubit`, `CounterPage`/`CounterView`, plus the `pumpApp` helper itself).
- Missing test files: none found in scope. `bootstrap.dart` and the three `main_*.dart` entry points have no test file, but they are explicitly excluded from the coverage floor with a stated, sound reason (device wiring; a test that calls `runApp` proves nothing). `lib/l10n/l10n.dart` is a thin generated-l10n accessor, consistent with template convention to leave untested.

## Gate Configuration Consistency

Checked `app/very_good.yaml`, `.github/workflows/main.yaml`'s `build` job inputs, and the README's quoted gate command against each other:

- `min_coverage`: 100 in all three.
- `collect_coverage_from`: `all` in all three.
- `exclude_coverage` / `coverage_excludes`: `**/*.g.dart **/l10n/gen/*.dart **/main_*.dart **/bootstrap.dart`, identical string in all three.

All three agree, which matters here because `very_good.yaml`'s own comment states CI cannot read that file (the reusable workflow pins an older CLI) and so the workflow must repeat the values by hand. That duplication is a known drift risk; it currently has no drift. This also matches the plan's Phase 1 bullet describing the same two-places-must-agree constraint, so the implementation matches the documented decision.

`coverage/` is correctly listed in the newly added `app/.gitignore` and is not tracked in git (verified with `git ls-files` and `git status`), so no coverage artifacts leaked into the commit.

## State Management Test Quality

- `app/test/counter/cubit/counter_cubit_test.dart`: Pass.
  - Initial-state check uses a raw `test()`, but it only reads `.state`, not a manual stream subscription, so it does not trip the CLAUDE.md rule against "raw `test()` with manual stream assertions." This is the standard VGV pattern (state-only assertions stay outside `blocTest`, transition assertions use it).
  - `increment`/`decrement` transitions use `blocTest` correctly, with `build`, `act`, `expect`.
  - Cubit (not Bloc) is appropriate per CLAUDE.md ("Cubit only when the state is simple and UI-driven") — trivial int counter qualifies.
  - No `setUp`/`tearDown` needed; each `blocTest` builds its own instance via `CounterCubit.new`, so there's no shared mutable fixture to hoist.

## UI Component Test Quality

- `app/test/counter/view/counter_page_test.dart`: Pass.
  - Uses `MockCubit<int>` from `bloc_test` (mocktail-backed), private and underscore-prefixed (`_MockCounterCubit`), matching the mocking-library and private-mock-naming rules.
  - Seeds non-default state (`when(() => counterCubit.state).thenReturn(42)`) before asserting the rendered count, rather than relying on the cubit's real default — correct per the "seeded initial states" rule.
  - Goes through the shared `pumpApp` helper for every widget test in this file.
  - Interaction tests (`tap` + `verify`) check one behavior per test, one `verify` call each — not over-verified.
  - Test names read as specifications: "renders CounterView", "renders current count", "calls increment when increment button is tapped".
- `app/test/app/view/app_test.dart`: Pass, with a structural note (see Suggestions). It calls `tester.pumpWidget(App())` directly rather than through `pumpApp`. This is correct here, not a violation in practice: `App` itself instantiates its own root `MaterialApp`, so routing it through `pumpApp` (which also wraps in a `MaterialApp`) would nest `MaterialApp` inside `MaterialApp`. This is the standard shape for a top-of-tree `App` widget test in every VGV scaffold and is distinct from the anti-pattern the CLAUDE.md rule targets (feature-level widget tests bypassing the shared helper).

## Test Helper Quality

- `app/test/helpers/pump_app.dart`: Pass. Wraps `MaterialApp` with the app's real `localizationsDelegates`/`supportedLocales`, so widget tests exercise the same l10n wiring as production. Minimal and correctly scoped as an extension on `WidgetTester`.
- `app/test/helpers/helpers.dart`: Pass. Plain barrel export, matches the project's barrel-export convention.

## Anti-Patterns Found

None found in the files reviewed. Specifically checked for and did not find: tautological assertions, mocking the class under test, hand-written mocks in place of mocktail, missing-assertion tests, hardcoded unexplained magic values, over-verification, or missing `pump`/await after a state-changing interaction (the two tap tests assert on `verify(...)`, not on a post-tap rebuild, so no pump was needed).

## Recommendations

1. None blocking. When the counter feature is removed in the later PR, delete its three test files and the `pumpApp` helper's l10n coupling should be re-verified against whatever the first real feature's l10n needs look like.
2. Keep the `very_good.yaml` / `main.yaml` duplication in view during any future coverage-flag change — nothing forces the two to move together beyond the code comments pointing at each other.
3. No action needed on the `app_test.dart` raw `pumpWidget` call; it is the correct exception to the shared-helper rule for a root-level `App` test, not a deviation from it.

## Verdict

All tests pass the quality bar. No missing test files, no anti-patterns, and the test-gate configuration (`very_good.yaml`, CI workflow, README) is internally consistent and matches the plan's documented rationale.
