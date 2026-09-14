## Architecture Review

Branch `docs/plan-learning-guidance` against `origin/main`, Sep 13, 2026. Scope: the eight files named in the request. No Dart source changed, so the architectural surface is the specification itself (the four new teaching blocks) and the CI gate configuration the new Future Considerations paragraph records.

**Method.** Traced data paths rather than prose, per learned rule 4. Three passes:

1. **Snippet verification.** Transcribed every Dart snippet from the four new blocks into a throwaway package at `.context/arch-check/` (Dart 3.13.2, `very_good_analysis` 11.0.0, `bloc` 9.2.1, `equatable` 2.1.0, `bloc_test` 10, `mocktail` 1.0.5) and ran `dart analyze`. All snippets analyze clean; the only diagnostics were artifacts of my transcription (a top-level `const span`, an unreferenced `_admit` in the deliberate skeleton, a `print`). The five lints in Phase 1's table were each confirmed to fire on the form the table says they reject: `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `prefer_initializing_formals`, `always_put_required_named_parameters_first`, `empty_container_bodies`. `prefer_initializing_formals` does fire on the initializer-list spelling, including the VGV `layered-architecture` skill's own `: _userApiClient = userApiClient` example, so the plan's `required this._repository` is the lint-clean form and the skill's snippet is stale under this lint set. `class _Mock... extends Mock implements X;` is valid. Private named initializing formals alongside `super(...)` are valid.
2. **Library claims.** Read `equatable` 2.1.0 and `bloc` 9.2.1 in the pub cache rather than trusting the blocks. `bloc.dart:200` is `if (this.state == state && _emitted) return;`, so the `blocTest` snippet expecting `[ThingLoading(), ThingLoadFailure()]` off an initial `ThingLoading()` is right: the first emit passes. `equatable_utils.dart` `objectsEquals` dispatches `Map` to `mapEquals`, which contradicts one claim in the Phase 4 block (finding below). `bloc_lint` 0.4.2 `avoid_public_fields` only arms inside a class whose superclass name ends in `Bloc` or `Cubit`, so the block's lint claim about repositories is accurate.
3. **Gate configuration.** Read `.github/workflows/main.yaml`, `.github/workflows/license_check.yaml`, `.github/dependabot.yaml` and `app/very_good.yaml` on disk, then fetched the `very_good_workflows` reusable workflows to check the inputs the recorded remediation would have to use.

### Layer Separation

- Violations found: 0 in code (no Dart changed; `app/` is still the scaffold plus `app_bloc_observer.dart`).
- The four blocks describe a shape consistent with CLAUDE.md's four layers on every rule that matters: the Phase 4 repository snippet states "No Flutter import, so the layer stays pure Dart", takes its dependencies through the constructor, holds no second repository, and the spec bullet above it repeats all three. The Bloc snippet takes the repository through the constructor, never touches another Bloc, and puts the one decision (ordering) in the Bloc rather than the widget, which matches decision 7.
- One boundary leak the guidance would invite, at the level of the repository's public surface rather than its imports: see `architecture/repository-dependencies-public` below.
- One Flutter dependency the guidance puts in the domain's test tree, which the slice-two extraction has to undo: see `architecture/domain-tests-depend-on-flutter` below.
- Clean: the Phase 2 and Phase 3 blocks are pure Dart with no Flutter import anywhere, including the cause-ranking snippet. No calendar, season or weather input appears in any block, so learned rule 2 holds. The Phase 4 collapse snippet groups per hive across metrics, so learned rule 3 holds.

### State Management Assessment

- `AlertInboxBloc` (specified, Phase 4 block at plan:748-778): Correct. Sealed `Equatable` events and states, three state variants with no `Empty`, one handler per event, `on Exception` (mandatory under `avoid_catches_without_on_clauses`), `emit` order asserted by `blocTest`. `part`/`part of` for event and state files matches CLAUDE.md.
- Ordering (plan:786-798): Correct placement, one hidden coupling. `_ordered` is `static` and private (so `avoid_public_bloc_methods` and `avoid_public_fields` stay quiet), runs once where the state is built, and the three keys make the order total. It compares `severity.index`, which silently couples decision 7's direction to Phase 2's enum declaration order. See `architecture/severity-sort-couples-to-enum-order`.
- Evaluator (specified, Phase 3 block at plan:546-570): Correct as a stateful fold with one `EvaluationResult` per reading, and the carried state is exactly the three rules that need it. The constructor defaults are the problem: four of seven disagree with the decisions table. See `architecture/evaluator-defaults-diverge-from-policy`.
- Equality: the Phase 2 block's `Equatable` shape is right, and the two empty sealed variants (`Missing`, `Unindexed`) are correctly unequal because `EquatableMixin.==` compares `runtimeType` before `props`. One incidental claim about `Map` props is wrong, see below.
- `AlertDetailCubit` is unchanged by this diff and still justified by decision 8 and the Bloc-versus-Cubit section.

### Dependency Direction

- Direction violations: 0. No `packages/` exist yet; the dependency graph in `app/` is unchanged.
- The specified graph stays one-way: Presentation to `AlertInboxBloc` to `AlertRepository` to the seed generator and the domain. The domain sits below the repository and is shared with the Bloc for `Alert`, which is model transport across a boundary rather than an inverted dependency.
- The already-disclosed deviation is unchanged: `seed_readings.dart` lives under `app/lib/repositories/` doing data-layer work, stated in the plan at "The seed holds readings" and in "The repository has no abstraction yet".

### Package Structure

- No new packages. `app/` carries `pubspec.yaml`, `analysis_options.yaml` (`very_good_analysis` 11 plus `bloc_lint` recommended), `very_good.yaml` and a `test/` tree mirroring `lib/`.
- Phase 1's annotated tree matches disk file for file, including `lib/app_bloc_observer.dart` and `test/app_bloc_observer_test.dart`, which are PR 1's fix for FINDING-03 rather than template output. The block presents them inside "the tree, annotated" under a "Reading the scaffold" heading; a reader scaffolding the template fresh will not find that file. Cosmetic, not filed.
- `packages/hive_domain/` is still slice two. The record of what its arrival costs in CI is where this diff's real gaps are: three findings below.

### README and committed-report claims, verified

The README row and the plan's new paragraph both make checkable claims about PR 1's review. All verified against disk:

- "10 findings, 0 critical, 5 important, 5 suggestions" matches `review.md`.
- "8 applied, 2 deferred" holds. Spot-checked every applied one: the org name is `engineer.jamiebrown.keeper` in both the Android `applicationId` and the iOS `PRODUCT_BUNDLE_IDENTIFIER`; `app/macos`, `app/web` and `app/windows` are gone; `AppBlocObserver` has its own file and test; `app/pubspec.lock` is in both license `paths` lists; the README gate lists `dart format --set-exit-if-changed` and `bloc lint`; the pubspec description is no longer the template placeholder; the spell-check `includes` no longer carries the dead `app/**/*.md` glob.
- "findings 7 and 8" is the right attribution. FINDING-07 is `architecture/single-package-ci-gate` from the architecture agent, FINDING-08 is the spell-check glob whose second half (`packages/**/*.md`) is the deferred part. Calling FINDING-08 wholly deferred is a half-truth, since its "drop `app/**/*.md` now" half shipped in PR 1, but the surviving half is correctly recorded.
- The five committed files under `docs/code-review/keeper-status-bootstrap/` are internally consistent: `review.md` links four raw files and four exist, and its index matches its detail sections. Committing them is right by `docs/repo-standards.md` (the review trail is the verification cost the repo claims) and by the rule against leaving durable artifacts in `.context/`.

### Findings

**Important. The evaluator skeleton's defaults are test-scale, and two of them are not.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:546-558`.
The caption says "a test can shrink the numbers ... while production keeps the plan's values", but the shown defaults are already shrunk: `window = 8` against decision 2's 672, `minimumHistory = 4` against decision 1's 336, `consecutive = 2` against decision 5's 3, and `cadence = const Duration(minutes: 1)` against decision 4's 15 minutes. Two others, `breachSigma = 3` and `clearSigma = 2.5`, are the real policy values. So four of seven defaults contradict the policy document Phase 2 writes first, and nothing in the block marks which are which. Follow the skeleton literally and the evaluator's production behaviour depends on every construction site passing seven arguments: omit one and the app runs a policy `docs/false-positive-policy.md` does not describe, with no test able to see it, because each test passes its own values. That is the plan's own named risk, "the evaluator's numbers get picked to make tests pass", arriving through the guidance rather than through the keyboard. Either make the defaults the decisions-table values and have the tests shrink them by passing arguments, or drop the defaults entirely and label the numbers in the snippet as placeholders in the same sentence that shows them.

**Important. The deferred license-check remediation would trigger the job without widening what it audits.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995`.
The record says `license_check.yaml` needs `packages/*/pubspec.yaml` in both `paths` lists. Two problems on the actual file. First, `license_check.yaml:25` passes `working_directory: app`, and the reusable `license_check.yml@v1` takes `working_directory` as a single string with default `"."`, so adding path filters makes the job run on a `packages/` change and then audit `app/` again. The result is worse than no gate: a green check over dependencies nobody looked at. The extraction needs a second job (or a matrix) with `working_directory: packages/hive_domain`, plus the `flutter_version` input the existing job carries. Second, the record names only `pubspec.yaml`, which is the shape my PR 1 report suggested before FINDING-06 was applied; the file now watches `app/pubspec.lock` too, so copying the record forward reopens for the new package exactly the transitive-dependency gap FINDING-06 closed for `app/`.

**Important. The deferred record omits the coverage configuration, which is the part CLAUDE.md calls not optional.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995`.
The paragraph lists four CI changes and none of them is the gate's settings. Both candidate reusable workflows default `collect_coverage_from` to `imports` (confirmed in `dart_package.yml` and `flutter_package.yml` inputs), which is the default CLAUDE.md says leaves any `lib/` file no test imports out of the denominator. `dart_package.yml` does default `min_coverage` to 100, so the floor survives, but a package measured under `imports` can pass the floor over files it never loaded, and the domain package is where the evaluator lives. There is also no `very_good.yaml` at the repository root, only `app/very_good.yaml`, so a bare `very_good test` inside `packages/hive_domain/` would find no config to inherit and would run the `imports` gate with no floor. Add to the record: `collect_coverage_from: all` and `min_coverage: 100` on the new job, and a `very_good.yaml` in the new package (or one at the root that both packages inherit).

**Important. The Phase 4 block makes public repository fields the default.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:695` and `:706`.
The snippet declares `new({required this.things, required this.checks})` with public `final` fields, and the prose defends it: "`avoid_public_fields` applies to Blocs and not to repositories, so public `final` fields are fine here; make them `required this._things` when no test needs to read them back". The lint claim is correct, verified in `bloc_lint` 0.4.2 where the rule only arms inside a class extending a `Bloc` or `Cubit`. The architecture claim is the problem. VGV's `layered-architecture` standard keeps the injected dependency private (`final UserApiClient _userApiClient`) and exposes only methods, and the same block's own Bloc snippet uses `this._repository`. Applied to `AlertRepository`, whose injected dependency is the generated reading series, a public field puts raw `Reading`s on the repository's public API, so a Bloc or a widget holding the repository can read the readings and skip the evaluator, which is the entire reason the repository exists. The stated escape hatch points the wrong way too: no test needs to read a dependency back off the object it injected it into. Make private the default and say public fields need a caller that justifies them.

**Important. Domain tests are taught to import `package:flutter_test`, which the slice-two package cannot depend on.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:518`.
The Phase 2 block says "Domain tests in `app/` import `package:flutter_test/flutter_test.dart`, which re-exports the same API as `package:test`". True today, and it costs nothing today. It stops being free at the start of slice two: `packages/hive_domain/` is pure Dart with no Flutter imports (CLAUDE.md, Architecture), and `flutter_test` comes from the Flutter SDK, so a pure Dart package cannot depend on it. Every domain test file then needs its import rewritten during the extraction that the plan times and reports as a pain point, which both inflates the number and makes it measure the wrong thing. The alternative costs one line now: add `test` to `app/pubspec.yaml` dev dependencies (`depend_on_referenced_packages` fires without it, confirmed) and import `package:test/test.dart` in `test/domain/`, which is what the archived example package already did. The plan's dependency table at "Dependencies added in this plan" would gain a row, and slice two's extraction becomes a move.

**Important. The Equatable claim about `Map` props is wrong.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:826`.
"A `List` field compares element by element through `props`; a `Map` does not." In `equatable` 2.1.0, `objectsEquals` dispatches `Map` to `mapEquals` and `Set` to `setEquals`, both deep, on the same path that dispatches `Iterable` to `iterableEquals` (`~/.pub-cache/hosted/pub.dev/equatable-2.1.0/lib/src/equatable_utils.dart:58-76`). Maps in `props` compare by content. Slice one's states carry lists, so nothing breaks now, but the block is the document a state-shape decision gets made against, and this sentence would push a reader to flatten a map or hand-write `==` for a reason that does not exist. It is also the one factual error I found in a block whose warrant is that every claim in it was verified, which makes it cheap to fix and expensive to leave.

**Suggestion. The severity sort couples decision 7 to an enum declaration order nothing pins.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:789`.
`_ordered` compares `b.grade.index.compareTo(a.grade.index)`. That produces decision 7's "severity descending" only while `Severity` is declared ascending, low to critical. Phase 2's acceptance criteria pin `Severity`'s behaviour test but not its declaration order, and the severity table reads low in its first cell, so the two agree today by coincidence rather than by rule. Declare the order in Phase 2's spec bullet, or compare through a named accessor rather than `index`, and have `orders by severity then raised-at then id` assert across at least three tiers so an inverted declaration fails a test instead of shipping a backwards inbox.

**Suggestion. Name the reusable workflow for a pure Dart package.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995`.
"A build job or a matrix over `packages/*`" leaves the job type open, and the current `build` job uses `flutter_package.yml`. `packages/hive_domain/` is pure Dart, so `dart_package.yml` is the right reusable workflow (it exists in `very_good_workflows` alongside the Flutter one) and it also makes the pure-Dart claim enforced by CI rather than by review. Name it in the record so slice two does not inherit a Flutter toolchain for a package that must not need one.

**Suggestion. "Every gate in the repository points at `app/` alone" overstates the gap it is recording.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995`.
`spell-check` points at the root `README.md`, and `semantic-pull-request` is repository-wide. The sentence's own list then asks for `packages/**/*.md` in `includes`, which only makes sense once you know `includes` is not `app/`-scoped. Say "the build, license and dependabot gates are scoped to `app/`, and the spell-check job's `includes` names files one by one" so the paragraph reads correctly against the file in two years.

**Suggestion. Phase 3's only example of asserting a sealed result cannot be run against the class above it.**
`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:608-612`.
`final result = check.check(at, 117.5);` returns `RollingCheck`'s `Verdict`, and the next two lines assert `isA<Found>()` and cast `(result as Found).book`, where `Found` and `BookId` are Phase 2's throwaway `Lookup` hierarchy. The cast between unrelated sealed hierarchies analyzes clean (confirmed; no `cast_always_fails` diagnostic exists), so it fails only at run time, and the one worked example of the assertion style Phase 3's seventeen tests all need is the one snippet a reader cannot paste beside the class it appears under. Re-spell it with a `Verdict` variant.

### Not flagged, on purpose

- The prose of the five committed review files, per the scope note. They are a frozen artifact and I only checked their claims against disk.
- Learned rule 8's length and the retraction of the cold-writing claim. A process decision, and it is recorded with its reason in both `CLAUDE.md` and the plan's boundary section.
- `app/lib/repositories/seed_readings.dart` doing data-layer work inside the repository layer. Disclosed twice in the plan with the deferral reason, and unchanged by this diff.
- The domain directory having no `src/` and no barrel. Same: disclosed, with the extraction measurement as the reason, and feature barrels are kept.
- `Verdict`, `Run`, `Breached`, `Quiet` and `Warming` being undefined in the Phase 4 collapse snippet. It is labelled a skeleton over throwaway types, and the three-variant shape maps onto `Anomalous`, `WithinBand` and `InsufficientHistory` correctly, including leaving an open run open across an `InsufficientHistory` reading, which the count window makes unreachable mid-series anyway.
- `break` in the third `switch` case. `unnecessary_breaks` does not fire under `very_good_analysis` 11, confirmed.
- Phase 1's tree listing `app_bloc_observer.dart` as scaffold output. Noted under Package Structure; too small to file.

### Verdict

Fix 6 findings before merging, none of them Critical. The blocks are unusually well verified: every Dart form and every lint claim in them survived re-analysis, and the two library behaviours I checked independently (bloc's first-emit rule and Equatable's `runtimeType` guard) both hold. The defects are in the two places a document like this usually fails: numbers that look like the specification but are not (the evaluator defaults), and a deferral record that names the trigger correctly while under-specifying the fix (the three CI findings, of which the license one would produce a green check over an unaudited package).

Scratch package with every transcribed snippet left at `.context/arch-check/` for re-running `dart analyze`. It is gitignored and does not survive the workspace.
