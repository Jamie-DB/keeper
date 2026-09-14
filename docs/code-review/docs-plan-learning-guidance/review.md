# Code Review — docs-plan-learning-guidance

**Branch**: `docs/plan-learning-guidance` against `main` · **Date**: Sep 13, 2026
**Scope**: 8 changed files, documentation and configuration only. No Dart source changed.
**Agents**: `vgv-review-agent`, `architecture-review-agent`, `test-quality-review-agent`, `code-simplicity-review-agent`. All four completed.

**Critical**: 2 | **Important**: 11 | **Suggestion**: 9 · 22 findings from 27 agent reports after deduplication.
**Applied Sep 13, 2026**: 16 of 22, in three passes of 4, 8 and 4. First the two Criticals (FINDING-01 and 02) with the Phase 3 assertion snippet (FINDING-09) and the `Equatable` claim (FINDING-11); then the eight false or self-contradicting statements this branch had introduced (FINDING-04, 05, 06, 07, 12, 13, 18 and 21); then the four design calls (FINDING-03, 08, 10 and 20), each decided by Jamie rather than absorbed into a cleanup.

**Deferred, 6**: FINDING-14, 15, 16, 17, 19 and 22. Duplication and precision items with no correctness cost, left for the next plan pass. They are open, not silently dropped.

## Review timing, and why it matters here

The plan requires all three reviewers to report on one commit, or the comparison table compares three different diffs. That did not happen on this branch and the record should say so plainly.

`/review` ran on the branch's second commit, the one that committed PR 1's report. Twelve of its findings were then fixed across the next two commits, four in the first (the two Criticals, the Phase 3 assertion snippet and the `Equatable` claim) and eight in the second (the false or self-contradicting statements this branch had introduced). `flutter-reviewer` and CodeRabbit therefore see a later commit than `/review` did, with twelve findings already closed.

Two consequences for any comparison row written from this branch. First, silence from the other two reviewers on anything in this list is not agreement, it is a diff that no longer contains the defect. Second, `/review` had the advantage of going first on unreviewed text, which is the likeliest explanation for the count, and a row that reports 22 against their totals without saying so would be misleading. The order is worth keeping for future pull requests: reviewing before fixing is what makes the columns comparable, and this branch is the counter-example.

The diff retracts the plan's cold-writing requirement and replaces it with four collapsed teaching blocks, one under each of Phases 1 to 4, and commits PR 1's review report as evidence. Every Critical and Important finding below was reproduced against the file before it was recorded here. The one exception is stated in FINDING-11.

Three agents independently reported the same defect at `plan:826` and two reported the same defect at `plan:546`, which is the strongest signal in this set.

## Findings

| ID | Severity | Rule | Location | Finding |
|----|----------|------|----------|---------|
| FINDING-01 | 🔴 Critical | `vgv/spec-contradicted-by-example-defaults` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:546` | Give the RollingCheck skeleton the plan's policy numbers as defaults |
| FINDING-02 | 🔴 Critical | `tests/setup-outside-group` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:805` | Wrap the Phase 4 blocTest snippet in a group |
| FINDING-03 | 🟡 Important | `simplicity/rule-bundles-procedure-and-decision` | `CLAUDE.md:68` | Trim learned rule 8 to the boundary and one reason |
| FINDING-04 | 🟡 Important | `vgv/readme-claim-unsupported-by-linked-evidence` | `README.md:24` | Qualify "same diff" and "missed nothing" now that the report is linked |
| FINDING-05 | 🟡 Important | `vgv/deferred-finding-mischaracterized` | `README.md:28` | Describe FINDING-08 as the dead glob it is |
| FINDING-06 | 🟡 Important | `vgv/plan-instruction-stale-after-fix` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:289` | Drop `app/**/*.md` from the Phase 1 spell-check record |
| FINDING-07 | 🟡 Important | `vgv/phase-content-claim-unsupported` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:349` | Fix the claim that a plain extension appears in Phase 2 |
| FINDING-08 | 🟡 Important | `architecture/domain-tests-depend-on-flutter` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:518` | Point domain tests at `package:test`, not `package:flutter_test` |
| FINDING-09 | 🟡 Important | `vgv/teaching-snippet-type-mismatch` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:608` | Rewrite the sealed-result assertion against Phase 3's own return type |
| FINDING-10 | 🟡 Important | `architecture/repository-dependencies-public` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:706` | Default repository dependency fields to private, not public |
| FINDING-11 | 🟡 Important | `vgv/equatable-map-claim-wrong` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:826` | Correct the claim that Map props skip deep equality |
| FINDING-12 | 🟡 Important | `architecture/deferred-gate-omits-coverage-config` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995` | Add the coverage settings to the extraction's CI checklist |
| FINDING-13 | 🟡 Important | `architecture/deferred-license-gate-incomplete` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995` | Record the license check's working directory and lockfiles, not just its paths |
| FINDING-14 | 🔵 Suggestion | `vgv/boundary-verb-inconsistent` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:9` | Align the "touches" wording with the writes-only boundary |
| FINDING-15 | 🔵 Suggestion | `simplicity/fact-restated-across-sections` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:132` | Cross-reference the Phase 1 lint table instead of restating three of its rows |
| FINDING-16 | 🔵 Suggestion | `simplicity/fact-restated-across-sections` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:282` | Cross-reference the "Read the tree" bullet instead of re-describing the counter |
| FINDING-17 | 🔵 Suggestion | `vgv/props-collection-note-in-wrong-phase` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:384` | Put the corrected props collection note in the Phase 2 block |
| FINDING-18 | 🔵 Suggestion | `vgv/snippet-not-formatter-clean` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:488` | Pre-split the enum values in the Grade snippet |
| FINDING-19 | 🔵 Suggestion | `vgv/sigma-convention-unstated` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:585` | Name the sigma convention the variance snippet picks |
| FINDING-20 | 🔵 Suggestion | `architecture/severity-sort-couples-to-enum-order` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:789` | Pin the Severity declaration order the inbox sort depends on |
| FINDING-21 | 🔵 Suggestion | `architecture/overstated-gate-scope` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995` | Correct "every gate points at `app/` alone" |
| FINDING-22 | 🔵 Suggestion | `architecture/package-gate-workflow-type` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995` | Name `dart_package.yml` for the pure Dart domain package |

## Detail

### FINDING-01 · `vgv/spec-contradicted-by-example-defaults` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:546`
Give the RollingCheck skeleton the plan's policy numbers as defaults.
- **Why**: The block's prose promises "production keeps the plan's values" while four of the seven defaults contradict decisions 1, 2, 4 and 5 (`window = 8` against 672, `minimumHistory = 4` against 336, `consecutive = 2` against 3, `cadence` one minute against fifteen), and `breachSigma`/`clearSigma` are the real values, so the snippet mixes policy with fixture scale and a call site passing only `floor` runs a 2-of-8 policy on a one-minute cadence with every Phase 3 test still passing.
- **Fix**: Write 672, 336, 3 and `Duration(minutes: 15)` as the defaults and let the tests pass their own shrunken numbers, or drop the defaults entirely and label the numbers as placeholders in the same sentence.
- **Reported by**: vgv-review-agent (Critical) · architecture-review-agent (Important, `evaluator-defaults-diverge-from-policy`) · [details](raw/vgv-review.md), [details](raw/architecture-review.md)
- **Verified**: reproduced at `plan:546-558`. The prose and the defaults contradict each other in adjacent lines.
- **Status**: **Fixed.** The defaults are now 672, 336, 3 and `Duration(minutes: 15)`, and the prose states that a fixture-scale default would let a call site run a policy the false-positive document does not describe while every test still passed.

### FINDING-02 · `tests/setup-outside-group` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:805`
Wrap the Phase 4 blocTest snippet in a group.
- **Why**: The snippet declares `late ThingRepository repository;` and `setUp(...)` at top level with no enclosing `group`, which is the exact anti-pattern `CLAUDE.md`'s Testing section forbids and the one the phase's own "Read first" bullet says the VGV reference gets wrong, taught on the single hand-written Bloc test file no agent may correct later.
- **Fix**: Wrap the snippet in `group(ThingBloc, () { ... })`.
- **Reported by**: test-quality-review-agent · [details](raw/test-quality-review.md)
- **Verified**: reproduced at `plan:805-812`. No `group` wrapper is present.
- **Status**: **Fixed.** The snippet is now wrapped in `void main() { group(ThingBloc, () { ... }); }` with `late` and `setUp` inside the group.

### FINDING-03 · `simplicity/rule-bundles-procedure-and-decision` · `CLAUDE.md:68`
Trim learned rule 8 to the boundary and one reason.
- **Why**: At 109 words it is the longest rule in the file, it restates the plan's own boundary paragraph as a second home for one fact, and it folds in a "how to teach" procedure that the rules-engine guidance in the global `CLAUDE.md` says belongs in a skill rather than a rules list.
- **Fix**: Keep the boundary and one reason; drop the procedural "teach through constructs blocks, put material in-phase" clause, which the plan already states.
- **Reported by**: code-simplicity-review-agent · [details](raw/code-simplicity-review.md)
- **Verified**: reproduced. Rule 8 is one sentence carrying a prohibition, a procedure and three justifications.

### FINDING-04 · `vgv/readme-claim-unsupported-by-linked-evidence` · `README.md:24`
Qualify "same diff" and "missed nothing" now that the report is linked.
- **Why**: The now-committed report scopes the four agents to the hand-authored surface, calling `app/lib` and `app/test` byte-for-byte scaffold and the counter's existence out of scope, so `flutter-reviewer`'s tooltip and production-logging catches were never in `/review`'s file set, and the table's "on the same diff" claim is not what the linked file shows.
- **Fix**: Change the table's opening claim from "on the same diff" to "on the same pull request", and name the scope difference in the `/review` cell.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)
- **Verified**: reproduced. `README.md:24` reads "reviewed three ways on the same diff"; the raw reports state narrower scopes.

### FINDING-05 · `vgv/deferred-finding-mischaracterized` · `README.md:28`
Describe FINDING-08 as the dead glob it is.
- **Why**: "2 deferred to slice two, both the same gap" is wrong for PR 1's FINDING-08, whose dead `app/**/*.md` glob was actually removed from `main.yaml`, so only its `packages/` half was deferred and the accompanying "8 applied" count is off by that half.
- **Fix**: State the two deferred items separately and record the spell-check glob as half applied, half deferred.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)
- **Verified**: reproduced. `main.yaml` `includes` is `README.md` only, so the glob was removed rather than deferred.

### FINDING-06 · `vgv/plan-instruction-stale-after-fix` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:289`
Drop `app/**/*.md` from the Phase 1 spell-check record.
- **Why**: The bullet still instructs the reader to narrow `includes` to the root `README.md` and `app/**/*.md`, which the shipped workflow does not have and which the review report committed in this same branch calls a glob that matches nothing, so one branch now contradicts itself.
- **Fix**: Narrow the clause to the root `README.md` and point at the Future Considerations note for `packages/**/*.md`.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)
- **Verified**: reproduced. `plan:289` contains the glob; `.github/workflows/main.yaml` does not.

### FINDING-07 · `vgv/phase-content-claim-unsupported` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:349`
Fix the claim that a plain extension appears in Phase 2.
- **Why**: The line says of `extension` and `extension type` that "both appear in Phase 2", but Phase 2 commits to two extension types and a record and no plain `extension`; the plain form is in Phase 1's `pump_app.dart` and `l10n.dart`, so the claim invites a manufactured rep that the project's cut-anything-ahead-of-its-caller rule rejects.
- **Fix**: Say the `extension type` appears in Phase 2 and the plain `extension` was already read in `pump_app.dart`.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)
- **Verified**: reproduced at `plan:349` against the Phase 2 spec bullet.

### FINDING-08 · `architecture/domain-tests-depend-on-flutter` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:518`
Point domain tests at `package:test`, not `package:flutter_test`.
- **Why**: `packages/hive_domain/` is pure Dart by `CLAUDE.md`'s architecture rule and cannot depend on the Flutter SDK's `flutter_test`, so every domain test written in Phase 2 needs its import rewritten during the slice-two extraction whose cost the plan commits to timing and writing up.
- **Fix**: Add `test` to `app/pubspec.yaml` dev dependencies and to the plan's dependency table, and import `package:test/test.dart` in `app/test/domain/`.
- **Reported by**: architecture-review-agent · [details](raw/architecture-review.md)
- **Verified**: reproduced at `plan:518`. This is a plan decision rather than a transcription slip, so it is a judgment call rather than a defect.

### FINDING-09 · `vgv/teaching-snippet-type-mismatch` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:608`
Rewrite the sealed-result assertion against Phase 3's own return type.
- **Why**: `check.check(at, 117.5)` returns the `Verdict` of the skeleton directly above, while the assertions use Phase 2's `Found`, `book` and `BookId`, so `isA<Found>()` can never pass and the one worked example of the assertion style all seventeen Phase 3 tests need cannot run as shown.
- **Fix**: Make `Verdict` sealed with a variant carrying a double and assert against that with `isA` plus `closeTo`.
- **Reported by**: vgv-review-agent (Important) · architecture-review-agent (Suggestion, `mixed-throwaway-domains-in-one-block`) · [details](raw/vgv-review.md), [details](raw/architecture-review.md)
- **Verified**: reproduced at `plan:604-612`. The skeleton returns `Verdict`; the assertion names `Found`.
- **Status**: **Fixed.** `Verdict` is now declared sealed with `Breached`, `Quiet` and `Warming`, the breached variant carrying a `double magnitude`, and the assertion reads `isA<Breached>()` then `closeTo(3.75, 0.001)`. Fixing it surfaced a second defect the agents did not report: Phase 4's block switches the same three variant names one stage later with the breached variant carrying a run, so the cross-reference now names that difference instead of claiming the variants are identical.

### FINDING-10 · `architecture/repository-dependencies-public` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:706`
Default repository dependency fields to private, not public.
- **Why**: Teaching public `final` fields as fine puts the injected reading series on `AlertRepository`'s public API, so a Bloc or a widget can read raw readings and skip the evaluator, which is the layer inversion `CLAUDE.md`'s architecture section forbids, and it contradicts the same block's own `this._repository` on the Bloc.
- **Fix**: Teach `required this._things` as the default and say a public field needs a caller that justifies it; drop "when no test needs to read them back".
- **Reported by**: architecture-review-agent · [details](raw/architecture-review.md)
- **Verified**: reproduced at `plan:706`.

### FINDING-11 · `vgv/equatable-map-claim-wrong` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:826`
Correct the claim that Map props skip deep equality.
- **Why**: The line asserts "a `List` field compares element by element through `props`; a `Map` does not", which three agents independently report is false for the pinned `equatable` 2.1.0, where Map dispatches through `mapEquals` and Set through `setEquals`; left standing it would push a Phase 4 state-shape decision to flatten a map or hand-roll `==` for a reason that does not exist, on a file no agent may later correct.
- **Fix**: State that `List`, `Set` and `Map` props all compare by content, and that the real trap is a field left out of `props` or a nested non-Equatable object.
- **Reported by**: vgv-review-agent · architecture-review-agent · test-quality-review-agent, all Important · [details](raw/vgv-review.md), [details](raw/architecture-review.md), [details](raw/test-quality-review.md)
- **Verified**: confirmed against `equatable` 2.1.0's `equatable_utils.dart` on Sep 13, 2026, with the author's approval to read outside the repository for this one check. `objectsEquals` dispatches `Set` to `setEquals`, `Iterable` to `iterableEquals` and `Map` to `mapEquals`, and `mapEquals` walks the keys and recurses on the values, so every collection compares by content. The source also shows the real trap, which the original line missed: a nested plain class matches neither the `Equatable` branch nor any collection branch, falls through to `a != b`, and so compares by identity.
- **Status**: **Fixed.** The line now states that `List`, `Set` and `Map` props all compare by content, and names the two real traps, a field left out of `props` and a nested plain class.

### FINDING-12 · `architecture/deferred-gate-omits-coverage-config` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995`
Add the coverage settings to the extraction's CI checklist.
- **Why**: Both candidate reusable workflows default `collect_coverage_from` to `imports` and no root `very_good.yaml` exists, so the extracted domain package would be gated over files it never measured, which `CLAUDE.md` calls the non-optional case.
- **Fix**: Add `collect_coverage_from: all` and `min_coverage: 100` to the new job, plus a `very_good.yaml` for the package, to the recorded list of changes.
- **Reported by**: architecture-review-agent · [details](raw/architecture-review.md)
- **Verified**: reproduced. The new paragraph names four changes and coverage configuration is not among them.

### FINDING-13 · `architecture/deferred-license-gate-incomplete` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995`
Record the license check's working directory and lockfiles, not just its paths.
- **Why**: `license_check.yaml` passes a single `working_directory: app`, so adding `packages/*/pubspec.yaml` to the paths filters makes the job trigger on a package change and then audit `app/` again, and omitting `packages/*/pubspec.lock` reopens for the new package the transitive-dependency gap PR 1's FINDING-06 closed for `app/`.
- **Fix**: Record a second job or matrix with `working_directory: packages/hive_domain` and a `flutter_version`, and name `packages/*/pubspec.lock` in both paths lists.
- **Reported by**: architecture-review-agent · vgv-review-agent (Suggestion, `deferred-ci-list-omits-lockfile`, merged here) · [details](raw/architecture-review.md), [details](raw/vgv-review.md)
- **Verified**: reproduced against `.github/workflows/license_check.yaml`.

### Suggestions

FINDING-14 through FINDING-22 are style, duplication and precision items. Read the linked raw reports for detail.

- **FINDING-14** `plan:9` — the first directive `/build` reads still says "no agent touches those files", and `plan:906` repeats it, while the Owner lines and the boundary section were all reframed to writing, so the loudest line states a stricter rule than learned rule 8. `vgv-review-agent`.
- **FINDING-15** `plan:132,134,136,752,822` — `prefer_initializing_formals`, `empty_container_bodies` and `avoid_catches_without_on_clauses` are each explained twice, so a correction has two homes. `code-simplicity-review-agent`.
- **FINDING-16** `plan:282,337,339` — the counter's Page, View, `context.read` and `context.select` facts appear in both the pre-existing "Read the tree" bullet and the new "Page, View, barrel" section. `code-simplicity-review-agent`.
- **FINDING-17** `plan:384` — `Alert` gets its list of anomalies in Phase 2, but the only guidance on collections inside `props` sits in Phase 4's block, two phases after the reader meets the problem. `vgv-review-agent`.
- **FINDING-18** `plan:488` — `dart format` rewrites `low, medium, high;` onto three lines, so the snippet changes under a reader the block just told to trust the formatter. `vgv-review-agent`.
- **FINDING-19** `plan:585` — dividing the variance by `_inBand.length` is the population sigma while `plan:671` calls it "sample sigma", and at small windows the two differ by enough to move a hand-built fixture across a tier line. `vgv-review-agent`.
- **FINDING-20** `plan:789` — `_ordered` compares `severity.index`, so "severity descending" holds only while `Severity` is declared low to critical, an order no Phase 2 acceptance criterion states. `architecture-review-agent`.
- **FINDING-21** `plan:995` — "every gate points at `app/` alone" is overstated: `spell-check` points at the root `README.md` and `semantic-pull-request` is repository-wide. `architecture-review-agent`.
- **FINDING-22** `plan:995` — "a build job or a matrix over `packages/*`" leaves the job type open, and the current job uses `flutter_package.yml`, so slice two could gate a pure-Dart package with a Flutter toolchain. `architecture-review-agent`.

## Outcomes on the applied findings

- **FINDING-04** Fixed. The table's opening claim is now that each pull request is reviewed three ways, with the row recording where the three did not see the same commit or file set, and the `/review` cell names the byte-for-byte scaffold exclusion that kept the counter's widgets out of its scope.
- **FINDING-05** Fixed. The two deferrals are stated separately, with the spell-check glob recorded as removed immediately and only its `packages/` replacement deferred.
- **FINDING-06** Fixed. The bullet narrows `includes` to the root `README.md` alone and records that `app/**/*.md` was an earlier draft's error caught by PR 1's review.
- **FINDING-07** Fixed. The line now says the plain `extension` was already read in `pump_app.dart` and `l10n.dart`, and the `extension type` arrives in Phase 2 as `HiveId` and `AlertId`.
- **FINDING-12** Fixed. The deferred list carries `collect_coverage_from: all`, `min_coverage: 100` and a `very_good.yaml` for the package.
- **FINDING-13** Fixed. The deferred list records a second license-check job with its own `working_directory` and `flutter_version`, because the reusable workflow's input takes one string, plus `packages/*/pubspec.lock` in both paths lists.
- **FINDING-18** Fixed. The three enum values sit on their own lines, which is what `dart format` produces.
- **FINDING-21** Fixed. The paragraph now says the build job, license check and dependabot are `app/`-scoped, and that spell-check names files one by one while `semantic-pull-request` is repository-wide.

- **FINDING-03** Fixed. Rule 8 is 65 words rather than 109: the boundary, one reason, and a pointer to the plan for the guidance. The procedural clause and the pull request 7 history are gone, the plan already carrying both.
- **FINDING-08** Fixed. Domain tests import `package:test/test.dart`, `test` is added to `app/pubspec.yaml` under `dev_dependencies` in Phase 2's files-touched list and to the dependency table with its reason, and the pubspec-edit count is corrected from two packages to three. The stated reason is the one that matters: choosing `test` now is the difference between moving these files at the slice-two extraction and rewriting every import in them.
- **FINDING-10** Fixed. The repository snippet takes `required this._things` onto private fields, and the prose states that private is the default and a public field needs a caller that justifies it, because public would put the raw reading series on `AlertRepository`'s API and let a Bloc or widget skip the evaluator.
- **FINDING-20** Fixed. Phase 2's acceptance criteria now require `Severity` declared least severe first, state that this makes decision 7's "severity descending" `b.severity.index.compareTo(a.severity.index)`, and require a test asserting that ordering across three tiers.

FINDING-01, 02, 09 and 11 carry their own **Status** lines in the detail above.

## `flutter-reviewer`, dispatched after the fixes

The `vgv-ai-flutter-plugin:flutter-reviewer` subagent ran on the fifth commit, after the sixteen fixes above. It was expected to have nothing in scope, since no `.dart` file changed on this branch. Instead it was pointed at the Dart snippets inside the four teaching blocks, on the grounds that those become `app/lib/domain/`, `app/lib/repositories/` and `app/lib/alert_inbox/` by hand and no agent may correct the result. It found four items the four wingspan agents missed, two of them real defects in the same class as the Criticals.

Its own scope statement: no compiled surface, no analyzer run, every claim reasoned from reading. Accessibility had no surface at all, stated plainly rather than reached for.

- **FR-01, testing. The equality test could not fail.** `const a` and `const b` built from identical arguments are canonicalized to one instance and `Equatable`'s `==` short-circuits on `identical`, so `expect(a, equals(b))` asserted that an object equals itself and passed even if `props` returned an empty list. The block's own prose calls a field missing from `props` the classic bug and Phase 2's acceptance criteria require one equality test per class, so the worked example propagated a test that could not catch the bug it existed for, into eight files. **Fixed**: one operand is now `final`, and an `isNot` inequality case was added, with a paragraph naming the canonicalization trap.
- **FR-02, bloc. `Verdict` carried no `Equatable`.** State shape declares `EvaluationResult` sealed and `Equatable` and Phase 2 says every class carries it, while Phase 2's own `Lookup` example does. The Phase 3 skeleton did not. This defect was introduced by the fix for FINDING-09 earlier the same day, and it walks into the nested-plain-class trap that FINDING-11's fix documents four blocks later. **Fixed**: `Verdict` extends `Equatable` with `props` on the variant that carries a value, plus a paragraph on why `isA` assertions hide the problem rather than removing it.
- **FR-03, testing. `emit` deduplication was unstated.** `emit` drops a state equal to the current one except on the very first emit, which is the only reason the example's `expect` list opens with a `Loading` equal to the initial state. The bullet described `expect` as the exact ordered list with no mention of it. **Fixed**: one clause added, including that a case dispatching the event twice will not see the second `Loading`.
- **FR-04, security. Release logging of alert payloads is undecided.** Extends PR 1's recorded observer finding rather than repeating it: Phase 4 is where the logged payload stops being an `int`. **Resolved as accepted, Sep 13, 2026.** Four options were put to Jamie: leave it and state it, gate the `log` calls on `kDebugMode`, pin `EquatableConfig.stringify = kDebugMode` in `bootstrap()`, or log the state type only. He took the first, on the grounds that this is a mock app. Recorded in Phase 4's detail where the payload becomes real, with the reason, the options rejected, and slice three as the point the decision is made again rather than inherited. Added to the README shortcomings list the documentation plan specifies. No code change.

Two things it affirmatively cleared, recorded so a later reviewer does not "fix" them: the fixed-seed generator behind `seed_readings.dart` is reproducibility and must not become `Random.secure()`, and the Phase 4 handler's `on Exception` into a generic failure state is the sanitization pattern the standard asks for.

One item out of diff, offered for the next plan pass rather than as a finding: Phase 6 specifies a single WCAG criterion, the colour-alone cue, for screens that also engage semantic labels on the severity icons, target size on the list rows, and text scaling on the severity and recovering-until lines.

## Reviewer's assessment

The two Criticals and FINDING-09 are the same class of defect and they are mine: teaching snippets whose prose and code disagree, in the one part of the repository where no agent may later fix the code the snippet produces. FINDING-11 is the most consequential of the Importants, because it is a false statement about a library the author will trust.

FINDING-04, FINDING-05 and FINDING-06 are honesty items against the project's no-fabricated-claims rule, and they are cheap.

FINDING-08 and FINDING-10 are genuine design calls rather than slips, and FINDING-03 asks to shorten a rule that was written this session. Those three deserve a decision rather than a reflex fix.
