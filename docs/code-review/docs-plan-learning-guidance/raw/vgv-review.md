# VGV Code Review — `docs/plan-learning-guidance` vs `main`

Scope: the eight files named in the request. No Dart source changed. Verification ran under Dart 3.13.2, Flutter 3.47.2, `very_good_analysis` 11.0.0, `equatable` 2.1.0, `bloc_lint` 0.4.2, in a throwaway package copied from `.context/pr7-archive/learning/examples/watchtower/`.

## Summary

The trade this branch makes is right. Retracting cold writing and carrying the language guidance inside the phase that needs it beats a parallel example package that CI would never have analyzed, and the 865 lines of PR 7 come back as roughly 400 lines of reference that sit next to the spec they serve. The Dart is in good shape: every one of the seven lint claims in the Phase 1 table reproduces under `very_good_analysis` 11, the `new` constructor declaration form analyzes clean, `required this._repository` is legal as a private named initializing formal even alongside a `super` call, and `bloc_lint`'s `avoid_public_fields` does key on a superclass name ending in `Bloc` or `Cubit`, so the repository advice holds. The teaching blocks were checked by analysis and it shows.

What did not get the same treatment is the numbers and the claims around the edges. One snippet ships the shrunken test values as production defaults while its own sentence promises the opposite, which is the only finding here that can put a wrong policy in `app/lib/`. One library-behaviour claim is flatly wrong against the `equatable` source. And the second commit's README row makes two claims that the report it now links does not support: the count of what was applied, and the assertion that `/review` missed nothing the other two reviewers caught. Committing the report is the right call, and it is exactly what makes those two claims checkable.

Verdict: merge after the Critical and the two README items. The rest are cheap edits.

## Verification log

Reproduced under the toolchain named above:

| Claim | Result |
|---|---|
| `unnecessary_type_name_in_constructor` on `const Hive({required this.id})` | Fires |
| `unnecessary_const_in_enum_constructor` on `const new(...)` in an enum | Fires |
| `always_put_required_named_parameters_first` | Fires |
| `empty_container_bodies` on `{}` | Fires, including on the mock form |
| `prefer_initializing_formals` on a named param assigned in the initializer list | Fires |
| `always_use_package_imports`, `avoid_catches_without_on_clauses` in the 11.0.0 rule set | Present |
| `formatter: trailing_commas: automate` in 11.0.0 | Present |
| `const new(...)`, `extension type const`, sealed + `final class`, record `typedef`, collection-for, positional record `.$2`, cascade `..sort` | All analyze clean |
| `required this._repository` as a private named initializing formal, with and without `super` | Legal |
| `bloc_lint` `avoid_public_fields` scoped to Bloc/Cubit superclasses | Confirmed in `avoid_public_fields.dart` |
| Phase 2, 3 and 4 snippets, assembled with filler types | No diagnostics attributable to the plan's own code |
| `equatable` compares a `Map` in `props` | Compares deeply. See Critical/Important 2 |
| Phase 2 snippet 6 survives `dart format` | It does not. See Suggestions |

`dart test` and `flutter test` were not run, per the request.

## 🔴 Critical — Must Fix Before Merge

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:546-557`** — The `RollingCheck` skeleton ships the shrunken test numbers as the constructor defaults, under a sentence that promises the opposite.
  - The sentence: "Each rule is a constructor parameter with a default, so a test can shrink the numbers and keep its fixture on one screen while production keeps the plan's values." The defaults shown: `window = 8`, `minimumHistory = 4`, `consecutive = 2`, `cadence = const Duration(minutes: 1)`.
  - Why: decisions 1, 2, 4 and 5 one screen above fix those at 336 in-band readings, 672, N of 3 and 15 minutes, and Phase 3's own detail line restates them. If the skeleton is typed as shown and the call site in `alert_repository.dart` passes only `floor`, production runs a 2-of-8 policy on a 1-minute cadence. Every Phase 3 test still passes, because each test constructs the object with its own numbers; the first thing that fails is Phase 4's `raises nothing for a hive below the minimum history`, one phase and one commit later. `breachSigma` and `clearSigma` are the only two defaults that match the plan, which makes the mismatch harder to spot rather than easier.
  - Fix: put the plan's values in the defaults (`window = 672`, `minimumHistory = 336`, `consecutive = 3`, `cadence = const Duration(minutes: 15)`) so the sentence is true, and let the tests pass their small numbers explicitly. If the small numbers are wanted in the snippet for width, say in the prose that they are placeholders and the real ones are decisions 1 to 5.

## 🟡 Important — Should Fix

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:826`** — "A `List` field compares element by element through `props`; a `Map` does not" is false for `equatable` 2.x.
  - Why: `equatable-2.1.0/lib/src/equatable_utils.dart` routes `props` entries through `objectsEquals`, which dispatches `Set` to `setEquals`, `Iterable` to `iterableEquals` and `Map` to `mapEquals`, all of which compare by content. Nothing in slice one carries a Map, so nothing breaks today; what breaks is trust in the block, and the note would push the author to restructure a state or hand-roll `==` the first time a Map appears.
  - Fix: "Lists, Sets and Maps in `props` all compare by content. The trap is a field left out of `props`, which is why every `Equatable` class gets an equality test."

- **`README.md:26-28`** — With the report linked, "on the same diff" and "Missed nothing the other two caught in the reviewed scope" no longer hold up.
  - Why: the committed report says the `/review` agents were told the counter feature's existence is not a finding and that `app/lib` was confirmed byte-for-byte scaffold, so the hand-authored surface was the review surface. The `flutter-reviewer` column in the same row credits catches on the counter's icon-only buttons and on the observer logging full state, neither of which appears anywhere in the five committed files. The three reviewers therefore did not see the same file set, and the row's own escape hatch, "in the reviewed scope", is doing work the reader cannot see until they open the link. The repo standard is that a work-sample claim survives a hostile read.
  - Fix: one clause in the `/review` cell, for example "scoped to the hand-authored surface, which is why the two scaffold-widget findings above are absent", and soften the table's opening sentence from "on the same diff" to "on the same pull request".

- **`README.md:28`** — "2 deferred to slice two, both the same gap" does not describe FINDING-08, and the "8 applied" count depends on it.
  - Why: FINDING-08 is a dead `app/**/*.md` spell-check glob. Its "drop it now" half was applied: `.github/workflows/main.yaml` now includes `README.md` only. Only its "add `packages/**/*.md` later" half is deferred. So the deferred pair is not one gap, it is the `packages/` CI gap plus half of a dead-glob finding, and the applied count is eight and a half rather than eight.
  - Fix: "8 applied and one half-applied. Two deferred to slice two: every CI job points at `app/` alone, so the domain package would ship with no gate, and the spell-check glob needs `packages/**/*.md` when it lands."

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:289`** — Phase 1 still records a spell-check configuration the repository deliberately does not have.
  - Why: the bullet says "Keep the root and narrow `includes` to the root `README.md` and `app/**/*.md` instead", while the workflow includes `README.md` only and the report committed in this same branch calls `app/**/*.md` a glob that matches nothing. Phase 1 reads `Done`, so `/build` will not act on it, but the plan is the project's authority document and this line is now a false record of what was built, sitting in the same commit as the finding that contradicts it.
  - Fix: narrow the clause to the root `README.md`, and add "`packages/**/*.md` joins it with the domain package, see Future Considerations".

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:608-612`** — The "Reading a sealed result in a test" snippet asserts Phase 2's variant against Phase 3's return type.
  - Why: `check.check(at, 117.5)` returns the `Verdict` of the skeleton three snippets above, and `Found`, `Book` and `BookId` are the `Lookup` example from Phase 2. `Verdict` is not sealed and is unrelated to `Found`, so `isA<Found>()` can never pass and the cast is unreachable. The analyzer accepts it, which is worse: the snippet passes the block's stated verification while teaching variant assertion on a type that has no variants. The lesson this snippet exists to carry, assert the variant then cast, is the one thing the code does not demonstrate.
  - Fix: give the skeleton a sealed `Verdict` with two or three variants, one carrying a double, and assert against those. `expect(result, isA<Breached>()); final run = (result as Breached).run;` with `closeTo` on the double.

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:349`** — "Both appear in Phase 2" is wrong about the plain `extension`.
  - Why: Phase 2's own Earns line and detail bullets commit to two extension types (`HiveId`, `AlertId`) and a record, and no plain `extension`. The plain form appears in Phase 1's `pump_app.dart` and `l10n.dart`, which the reader has just finished reading. Told that both appear in Phase 2, the author looks for a plain `extension` to write, and manufacturing one is the cut-anything-ahead-of-its-caller rule in reverse.
  - Fix: "`extension type` appears in Phase 2. The plain `extension` you have already read, in `pump_app.dart` and `l10n.dart`."

## 🔵 Suggestions — Nice to Have

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:488`** — `enum Grade { low, medium, high; ... }` is not `dart format` clean. The formatter splits the three values onto their own lines once the enum has a body, verified under Dart 3.13.2. The same block tells the reader to run `dart format` and stop arguing with it, so the snippet should already be in the form the formatter produces. `enum Format { paperback, hardback, audio }` at line 410 is fine, because a bodyless enum stays on one line.
  - Suggestion: split the three values in the snippet.

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:585-588`** — The variance divides by `_inBand.length`, which is the population sigma, while line 671 calls it the evaluator's "sample sigma" and decision 2 names only "the standard deviation". At 672 readings the two differ by 0.07 percent and nothing notices; at the window sizes the Phase 3 tests actually use, they differ by several percent, which is enough to move a hand-built fixture across a tier line and turn a severity-cell test into a puzzle.
  - Suggestion: one clause saying the variance divides by n, and add the convention to the policy document's band-statistic sentence, since that document is what the tests are written against.

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:384-521`** — The Phase 2 block has no collection-in-`props` guidance, and Phase 2 is where `Alert` gets its list of anomalies. The note lives in Phase 4's block at line 826, two phases after the reader needs it, and it is the note that needs correcting anyway.
  - Suggestion: put the corrected one-liner in the Phase 2 block, on the `Equatable` snippet where `props` is introduced.

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:9`** — The directive `/build` reads first still says "no agent touches those files", and line 906 repeats it. The retraction reframed the boundary everywhere else to writing: line 24 ("written into"), line 33 ("wrote into those directories"), line 44 and the three Owner lines ("No agent writes these files"), and CLAUDE.md rule 8 is scoped to writing a file. The loudest line now states a stricter rule than the one that governs, which is how a later session ends up refusing to read a file it is allowed to read.
  - Suggestion: change both to "no agent writes into those files".

- **`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:995`** — The deferred CI list asks for `packages/*/pubspec.yaml` in both `paths` lists but not `packages/*/pubspec.lock`. FINDING-06, applied on this same review pass, added `app/pubspec.lock` precisely because a transitive change lands there with no manifest edit. The new package would ship with the blind spot that was just closed for `app/`.
  - Suggestion: add `packages/*/pubspec.lock` to the license-check item.

## On committing the review report

Committing the five files is right and needs no defence: it is evidence over assertion, it makes the comparison table auditable, and the raw reports carry their own scope notes, which is what let the two README claims above be checked at all. Three practical notes, none of them findings: the files are outside the spell-check `includes`, so their prose is not gated; they are inside CodeRabbit's review paths, so future review turns will read them; and the `keeper-status-bootstrap` directory name does not match the PR number the raw reports cite ("PR 6", "PR 1" in the README), which will be worth a convention before the second report lands.

## Simplicity Assessment

- Lines that could be removed: roughly 15, all of them in the two README claims and the stale Phase 1 clause. The teaching blocks are not padded; each construct maps to a named type or test in the phase that carries it.
- Unnecessary abstractions: none. The collapsed-`<details>` form keeps the spec first and the reference second, and the throwaway types make the guidance unpasteable by construction, which is the one thing PR 7 could not do.
- YAGNI violations: none new. The blocks stop at what Phases 2 to 4 write; nothing teaches an isolate, a stream or a generic repository.
- Complexity verdict: already minimal. The 494 added lines buy a reference the phases were assuming and the author did not have, and they replace 865 lines that CI could not see.

## Testing Assessment

No code changed, so no tests were due. Two notes on the test guidance itself:

- The `blocTest` case at lines 811-819 passes despite emitting `ThingLoading()` when the initial state is already `ThingLoading()`, because `BlocBase.emit` suppresses an equal state only after the first emit. Correct as written, and the reason is invisible; a sentence would stop the author trusting duplicate emits in general.
- Test quality guidance is otherwise sound and specific: `group` on the type, names that read down the hierarchy, `late` plus `setUp` inside the group, private underscore-prefixed mocks one per file, `closeTo` rather than `equals` on doubles, and stubbing in each case's own `setUp:`. All of it matches CLAUDE.md's Testing section.
