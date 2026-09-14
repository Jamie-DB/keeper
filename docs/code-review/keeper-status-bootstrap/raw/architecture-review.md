## Architecture Review

> _Report as delivered Sep 13, 2026. Not maintained against later code; dispositions are in the README comparison row. See the caveat in [`../review.md`](../review.md)._

Branch `keeper-status-bootstrap` against `origin/main`, Sep 13, 2026. Scope: the Dart under `app/lib` and `app/test`, the app config, the root CI files, README, CLAUDE.md and the plan. Platform directories excluded by instruction.

**Method.** Scaffolded a throwaway `very_good create flutter_app keeper` (CLI 1.5.0) into `/tmp` and diffed it against `app/`. `lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, `.vscode/`, `.idea/` and `.metadata` are byte-identical to the template. `app/very_good.yaml` is new. The root `.github/` files differ from the template only where the plan says they should (`working_directory: app`, dependabot `/app`, license paths, coverage inputs, spell-check includes, the "Read before accept" PR section). The scaffold's own `LICENSE` and `README.md` were deleted as the plan asked; one `LICENSE` sits at the root. Throwaway removed afterwards.

So the architectural surface of this PR is the gate configuration and the repo wiring. The Dart is the template, reviewed here only for whether it already complies with the project's rules so later slices inherit a clean base.

### Layer Separation
- Violations found: 0
- No `packages/` exist yet, so there is no data or repository layer to cross. Every cross-feature import goes through a barrel (`keeper/app/app.dart`, `keeper/counter/counter.dart`, `keeper/l10n/l10n.dart`); no `src/` import anywhere.
- Clean files: all checked files clean.

### State Management Assessment
- `CounterCubit` (`app/lib/counter/cubit/counter_cubit.dart`): Correct for what it is. Cubit with an `int` state is the "simple and UI-driven" case CLAUDE.md allows. Page provides via `BlocProvider`, View consumes; `context.select` in `CounterText`, `context.read` in the callbacks. No business logic in widgets. Template code, existence not flagged per instruction.
- `AppBlocObserver` (`app/lib/bootstrap.dart:7`): Correct wiring, `Bloc.observer` set in `bootstrap()`. See the coverage note below; it is the one piece of measurable Dart the gate no longer sees.
- Tests: `counter_cubit_test.dart` uses `blocTest`; `counter_page_test.dart` uses a private `_MockCounterCubit`, `late` in `setUp`, `pumpApp`. `app_test.dart` pumps `App()` directly, which is right because `App` is itself the `MaterialApp`; wrapping it in `pumpApp` would nest two.

### Dependency Direction
- Direction violations: 0
- Graph: `main_*` -> `bootstrap`, `app`; `app` -> `counter`, `l10n`; `counter/view` -> `counter/cubit`, `l10n`. No cycles. `bootstrap.dart` imports `package:bloc` and `package:flutter/widgets.dart` only.
- Clean dependencies: all.

### Package Structure
- `app` (Flutter app, single package): Complete.
  - `pubspec.yaml`, `analysis_options.yaml` (very_good_analysis + bloc_lint recommended), `test/` mirroring `lib/`, `very_good.yaml` present.
  - Coverage settings agree across the three places that carry them: `app/very_good.yaml:11`, `.github/workflows/main.yaml:30`, `README.md:37-38`, and CLAUDE.md line 32 on this branch. Same four globs, same order.
  - No `packages/` yet; `hive_domain` is scheduled for slice two.

### Findings

**Important. The `**/bootstrap.dart` exclusion is broader than its stated reason.**
`app/very_good.yaml:11`, `.github/workflows/main.yaml:30`, `README.md:40`.
The README justifies excluding the entry points because "a test that called `runApp` inside the test binding would prove nothing". That covers `bootstrap()` and the three `main_*.dart`. It does not cover `AppBlocObserver` (`app/lib/bootstrap.dart:7-21`), whose `onChange` and `onError` are plain Dart a unit test measures in ten lines. Under `all`, that class is now the only hand-visible logic in `lib/` the gate never sees, and the hard rule is that nothing leaves the denominator without its reason written down. Two honest fixes: move the observer to its own file (`lib/app/app_bloc_observer.dart` or similar) with a test, so the glob excludes `bootstrap()` alone; or add one sentence to the README saying the observer is deliberately unmeasured and why. The first is small and leaves the template's shape intact for the counter-removal PR.

**Suggestion. The CI gate, license check and dependabot are single-package, and slice two adds a package.**
`.github/workflows/main.yaml:22`, `.github/workflows/license_check.yaml:12`, `.github/dependabot.yaml:8`.
All three point at `app/`. The plan (line 527) extracts `packages/hive_domain/` in slice two with no CI change listed, so the evaluator the simulator shares would ship untested by CI, unlicensed-checked and unbumped. Not this PR's job to build, but it belongs on slice two's checklist now: a second `build` job (or matrix) over `packages/*`, `packages/*/pubspec.yaml` in the license paths, and a dependabot entry per package.

**Suggestion. The README's "gate" omits two steps CI runs.**
`README.md:32-39`.
The reusable `flutter_package.yml` runs `dart format --set-exit-if-changed`, `flutter analyze`, `bloc lint` (because `run_bloc_lint: true`) and then the test, in that order. The README lists analyze and test. A local run of the README's commands can pass while CI fails on format or a bloc lint. Either add the two lines or label the block as the coverage gate rather than the full CI gate.

**Suggestion. `app/.gitignore` has an uncommitted diff.**
`app/.gitignore:8`, `app/.gitignore:12`.
`.build/` and `.swiftpm/` are in the working tree but not on the branch, alongside untracked macOS project edits from a local run. In-scope file, so the state reviewed here differs from what would be pushed. Commit the two lines (they are the current Flutter template's SwiftPM entries) or discard them before the PR opens.

### Not flagged, on purpose
- The counter feature, per instruction.
- `Theme.of(context)` inside `App.build` above the `MaterialApp`: template idiom, replaced when Phase 6 does the theme.
- `counter_page.dart` importing its own feature barrel: template quirk, harmless.
- `.github/cspell.json` carries template words (`Hola`, `Mundo`, `Saludo`) that appear nowhere; spell-check `includes: app/**/*.md` currently matches only an iOS asset README. Neither affects architecture.
- `main_development.dart` and `main_staging.dart` are identical. The plan's fake-versus-simulator split arrives with the data layer.

### Verdict
Architecture is clean. Fix 1 Important before merging: narrow the `bootstrap.dart` exclusion to what the README's reason covers, or write the reason for the observer down.
