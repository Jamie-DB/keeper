---
title: "feat: foundation and alert inbox"
type: feat
date: 2026-09-11
---

## feat: foundation and alert inbox - Extensive

> **Read this before `/build` runs anything.** Phases 2, 3 and 4 are written by Jamie by hand, and no agent touches those files until they are committed. `/build` must stop at the end of Phase 1 and wait. This is an ordering rule, not a permanent claim on the files. See [Human and agent boundary](#human-and-agent-boundary).

*Reviewed Sep 11, 2026 by the simplicity, VGV-conventions and scope-splitting agents. Their findings are applied inline rather than listed. Where two disagreed, the disagreement and its resolution are recorded in [Alternative approaches considered](#alternative-approaches-considered).*

## Overview

This plan covers the foundation and the first shippable slice of Keeper: scaffold the Flutter app, hand-write the domain and the baseline evaluator cold, hand-write `AlertInboxBloc` cold with its tests, run the first green gate and capture its additions as the evidence, then ship the alert inbox screen against seeded local data.

It corresponds to steps 1 through 6 of the build order in `docs/original-plan.md` section 8, plus the day-one setup list above it. It stops before the domain package extraction, before the simulator, and before any network call.

Scope was chosen against the stopping rule: the repository must be showable by Sun Sep 20, 2026. Nine days. This plan is the part that cannot be cut.

## Problem Statement

The repository is public, named, and contains three documents and no code. Nothing runs. Two planning documents disagree with each other in six places, and neither settles the concrete numbers the evaluator needs to exist.

Three things make this foundation load-bearing rather than boilerplate:

1. **The evaluator is the most showable artifact in the project** and it had no specification. "N consecutive readings, hysteresis at the edge, severity scales with magnitude and duration" is a policy sketch, not a function. Somebody had to pick N. This plan does.
2. **The hand-written core is evidence and it expires.** Once an agent has touched the domain, the claim "I wrote this cold" cannot be made about it. The order is one-way.
3. **The green gate diff is the answer to "how do you work with AI"** and it only exists if the hand-written tests are committed first. Run the gate before that commit and the evidence is gone permanently.

## Deltas from `docs/original-plan.md`

`docs/original-plan.md` stays the frozen third iteration. Where the Sep 11 brainstorm or this plan's review pass overrides it, this plan is the authority.

| Topic | original-plan.md says | This plan does | Source |
|---|---|---|---|
| Repository and package name | Unnamed, "`Hum` is a candidate" | `keeper`, scaffolded as `keeper` then the directory renamed to `app/` | Brainstorm |
| Repo layout | Three packages in a pub workspace | `app/` is a plain directory. No root `pubspec.yaml`, no workspace, no path dependencies until slice two | Brainstorm |
| Inbox search | Slice one | Slice four, where a real asynchronous Drift query gives `restartable` something to cancel | Brainstorm |
| Peer comparison in the baseline | Stretch goal in the first build | Out. The hive's own rolling window only. Becomes issue 9 | Brainstorm |
| GraphQL server | Sixty-minute timer on `angel3_graphql` | Hand-rolled `shelf` handler from the start | Brainstorm, slice two |
| Cut order | Other scenario scripts cut before the rain demo | Rain demo cut first | Brainstorm, slice three |
| Repository shape | "Two implementations of one interface from day one is dependency injection demonstrated" | One concrete `AlertRepository` evaluating generated readings. No interface until a second implementation exists in slice two | This plan, see [Repository shape](#the-repository-has-no-abstraction-yet-and-that-is-deferral-not-omission) |
| `YardConditions` on the evaluator | "The evaluator's signature should accept it from day one even if the first build passes nothing." The brainstorm reaffirmed this and accepted the unpaid cost in writing | Cut. No `YardConditions`, no weather parameter, no `Season`. Weather is issue 1 and cause ranking scores signal sets with no calendar anywhere | Jamie, Sep 11, reversing both documents. See [Weather and season are out entirely](#weather-and-season-are-out-entirely) |

## Proposed Solution

### Human and agent boundary

| Phase | Owner | Why |
|---|---|---|
| 1. Scaffold and repo setup | Agent-assisted, read before accept | Mechanical. The scaffold is Very Good CLI output either way |
| 2. False-positive policy and domain types | **Jamie writes these first** | Rule 2 of `docs/original-plan.md` section 7 |
| 3. Baseline evaluator | **Jamie writes this first** | Rule 2. This is the artifact the project is shown on |
| 4. `AlertInboxBloc` and its `bloc_test` cases | **Jamie writes this first** | Rule 2. Committed before any gate runs |
| 5. First green gate and its additions | Agent runs the gate, Jamie reads the diff | The gate's additions are the evidence, so they must be distinguishable |
| 6. Inbox screen and slice one | Agent-assisted, read before accept | The tooling writes the rest, per rule 2 |

If `/build` is invoked on this plan, it executes Phase 1, then stops and hands back. It resumes at Phase 5 once Jamie marks Phases 2 through 4 done.

**What the boundary actually protects, and what it does not.** Two claims rest on it: that the domain, the evaluator and the inbox Bloc were written cold before an agent touched the repository, and that the green gate's additions are readable as a diff against what Jamie wrote. Both are protected by commit order. Once Phase 4 is committed, the cold version is in git permanently and nothing later can make that commit agent-written.

So the rule is about sequence, not ownership. Two things are one-way doors:

- No agent writes any part of Phases 2 to 4 before Jamie has.
- The gate does not run before Phase 4 is committed.

After PR 1 merges, those files are ordinary code. Phase 6 may extend `Alert`, add a repository method, or reshape anything else it needs, under the same read-before-accept rule that governs the rest of the agent-assisted work. Requiring Phase 4 to anticipate everything Phase 6 might want would force speculative completeness into the one place in this plan that should be minimal.

### Three pull requests

| PR | Phases | Why it is its own diff |
|---|---|---|
| 1. Scaffold and the hand-written core | 1 to 4 | The scaffold is CLI output a reviewer skims in seconds, so a separate cycle for it buys little. The interesting content is the evaluator |
| 2. The green gate's additions | 5 | Isolating the gate makes its additions literally the diff. A reviewer reads the hand-written-versus-generated distinction straight off the PR view rather than reconstructing it from commit history inside a large diff |
| 3. The inbox screen | 6 | One layer, one feature, agent-assisted under the read-before-accept rule |

All three get all three reviewers, so the README comparison table gets three rows on three diffs of genuinely different character: dense pure-Dart logic, generated test additions, and Flutter UI. `/create-pr` cannot be model-invoked. Jamie types it, on all three.

### Eight decisions neither document settled, now settled

Flow analysis over the inbox and the evaluator found eight decisions with no answer in either document. All eight were decided by Jamie on Sep 11, 2026. The numbers below are the specification. `docs/false-positive-policy.md` restates them with their reasoning in Phase 2, before the evaluator is written.

**The scope call behind all six evaluator decisions.** The evaluator is on the never-cut list because it is the most testable thing in the project, not because its statistics are novel. Nobody reviewing a Flutter repository will audit a scale constant. So every decision below picks the simplest option that stays defensible in one sentence, and the saved effort goes to slice four.

| # | Decision | Value | Why this and not the alternative |
|---|---|---|---|
| 1 | Minimum history before the baseline judges | Half the window, about 3.5 days or 336 readings | Enough samples for a stable mean and sigma, and a restarted hive rejoins monitoring in days rather than a week. Below it the evaluator returns `InsufficientHistory`, so a **learning** hive is never mistaken for a healthy one |
| 2 | Band statistic | Rolling mean plus or minus `k` times the standard deviation over the window | The rolling window is the mechanism behind "drifts with the season" and it is about 20 lines. Median and MAD was rejected, see the alternatives section |
| 3 | Hysteresis | Leave the band at `k = 3.0`, clear only at `k = 2.5` | Clearing is strictly harder than breaching, so a value sitting on the line cannot oscillate |
| 4 | Reading cadence | 15 minutes. 96 readings per hive per metric per day | BroodMinder's supported fast mode, so the choice defends by citation. Hourly is its default but the bear scenario is a weight drop "over minutes", invisible at hourly |
| 5 | N consecutive breaches | 3, so 45 minutes to alert | Fast enough to catch a bear while it is still happening, slow enough to ignore a single spike |
| 6 | Missing readings | A gap longer than twice the cadence resets the consecutive counter and raises nothing | A silent sensor is neither inside the band nor outside it. Sensor health is its own alert class and it is issue 10 |
| 7 | Inbox sort | Severity descending, then raised-at descending, then alert id ascending, **applied when the loaded state is constructed** | Total and deterministic, so the widget test cannot go flaky. Severity alone is not a total order. The state carries an ordered list and the widget never sorts |
| 8 | Tapping an alert | The `alert/:id` route, backed by `AlertDetailCubit` | Slice two adds the chart and the GraphQL fetch to a screen that already exists. An unknown id resolves to a not-found state in the Cubit, not in the widget, because a deep link can arrive stale |

**Severity.** A lookup table keyed by magnitude tier and duration tier, not a float. A table is something a person can read and argue with.

**Magnitude is the reading's distance from the rolling mean, in sigma**, not its distance beyond the band edge. The band edge sits at 3.0 sigma, so the lowest tier starts exactly where an anomaly becomes possible and nothing can fall off the bottom of the table. Duration is consecutive readings outside the band.

**The window holds only readings that were within the band.** An anomalous reading never enters the baseline it was judged against. Without this an excursion contaminates its own baseline: a six-sigma drop inflates sigma as it runs, each later reading scores lower than the one before, and a worsening situation reads as improving. It is also what makes the reading generator tractable, because a spec asking for six sigma then evaluates at six sigma. One sentence in the policy document, and it is the same idea as a recovering hive relearning rather than judging.

**The baseline is the trailing window, ending before the reading under test.** A reading is never part of the statistics it is compared against.

| | brief, 3 to 5 readings | sustained, 6 to 11 | prolonged, 12 or more |
|---|---|---|---|
| **near, 3.0 to 4.5 sigma** | low | low | medium |
| **far, 4.5 to 6.0 sigma** | medium | medium | high |
| **extreme, over 6.0 sigma** | high | critical | critical |

Nine cells, nine tests, one per cell.

**Sigma has a floor, per metric.** A near-binary metric breaks the arithmetic otherwise: tilt on a hive that has never tilted has a window standard deviation of zero, so any excursion divides by zero and the severity lookup gets infinity rather than a tier. Each metric declares a minimum sigma representing the smallest departure worth noticing in its own units, and the evaluator uses the larger of that floor and the computed value. This is why a tilt lands in the extreme row: the floor is small, so a real tilt is many floors out. It is a rule in the policy document, not an implementation detail.

**One incident is one alert, across readings and across metrics.** This collapses in two stages.

First, within a metric. The evaluator returns a result per reading, so a twelve-reading excursion past N produces ten anomalous results. Those are one run, not ten. A run ends when a reading clears the inner hysteresis threshold or a gap resets the counter, and its duration is the run length, its magnitude the furthest reading in it.

Second, across metrics. **Runs open at the same time on the same hive are one alert.** A bear produces a tilt, a weight drop, a brood temperature fall and a sound spike, and that is one thing happening, not four. The alert opens when the first run opens and closes when the last one clears.

The second stage is not about tidiness. `docs/original-plan.md` says correlated signals arriving in the right order are what make bear outrank swarm in the candidate causes. That is only possible if one alert can see every signal. Per-metric alerts leave the tilt alert unable to know about the weight drop, and cause ranking degrades to "a tilt means tipped, bear or theft," which is a lookup with no correlation in it. Beat one stops being able to do the thing it exists for.

The per-yard budgeting demo survives. The bear scenario picks a hive or two neighbours, so two hives still produce two alerts, and issue 7 is about thirty hives on a bad day rather than one hive's four metrics.

**Severity is the worst signal in the incident.** The nine-cell table is unchanged and so are its nine tests.

Worst-wins has one real failure and it is worth stating. A quiet correlated failure like queen loss shows as brood temperature losing stability and sound variability rising, neither of them a large departure, so it scores medium when it needs the lid off. The seriousness lives in the combination and worst-wins cannot see combinations.

Raising severity when three or more metrics are involved would fix that and break something worse. Heat drives sound, brood temperature and humidity together, so a hot afternoon would climb toward critical. Telling "three signals because something is wrong" from "three signals because it is hot" needs the neighbouring hives, which is peer comparison, which is issue 9. Until that exists there is no safe version of the rule. Worst-wins fails toward a false negative, the breadth bump fails toward a false positive, and the false-positive policy exists because a wrong alert costs a hive opening. The queen-loss under-ranking goes in the README's shortcomings, pointing at issue 9.

**Severity is computed from the excursion as evaluated and does not drift afterwards.** In slice one the whole generated series exists at once, so the severity an alert carries is its final one. Re-evaluating an open alert as its excursion lengthens needs a live feed and belongs with the simulator, not here.

### The seed holds readings, so the evaluator has a production caller

The obvious shortcut is to seed `Alert` objects directly. It is also a trap: the evaluator, candidate-cause ranking and the whole severity table would then be a tested library that nothing calls until the simulator arrives in slice two. A reviewer opening the repository after PR 3 sees a centrepiece with no caller, which is the same reason weather and season were cut rather than stubbed.

So the seed holds readings and the repository runs the evaluator over them.

- **`seed_readings.dart` generates rather than stores.** A function takes explicit excursion specs, each naming a hive, a metric, a start time, a magnitude in sigma and a duration in readings, and produces the reading series around them. Nothing is a literal, so a 3.5-day history at 15-minute cadence costs a loop rather than tens of thousands of lines.
- **Excursion specs keep the fixtures controllable.** Two specs with the same magnitude and duration on different hives produce the same severity at different raised-at times, which is the sort tie-break's test case.
- **This is the in-process fake `docs/original-plan.md` already calls for.** The development flavor points at it and the staging flavor points at the simulator, so it persists as the test double rather than being scaffolding that slice two deletes.

Slice one therefore demonstrates the whole chain the app is about: readings, evaluator, alerts, inbox. The unpaid cost is that the generator sits inside the repository layer doing data-layer work, which is the same deferral the repository shape section covers.

### State shape, named now because Phases 2 to 4 have no agent to infer it

The plan is the only specification the hand-written phases get, so the names are here rather than left to the keyboard.

```
AlertInboxEvent   sealed
  AlertInboxLoadRequested

AlertInboxState   sealed, Equatable
  AlertInboxLoading        initial state
  AlertInboxLoaded         carries an ordered List<Alert>
  AlertInboxLoadFailure

AlertDetailState  sealed, Equatable
  AlertDetailLoading
  AlertDetailLoaded        carries the Alert
  AlertDetailNotFound
```

`Alert` carries `id`, `severity` and `raisedAt`, because those three are the sort keys and Phase 4 cannot order a list without them. It also carries the hive and the yard, and **the list of anomalies in the incident rather than a single metric**, because an alert spans every signal that was open at the same time on that hive. One anomaly is the common case and four is a bear.

Ranked causes and the hive's recovering-until date are needed by the detail view in Phase 6. Phase 4 may add them or Phase 6 may, whichever turns out to read better once the view exists. That is not a gap in the specification, it is a decision that does not have to be made this far ahead.

**The evaluator returns three outcomes, not two.**

```
EvaluationResult    sealed, Equatable
  Anomalous           carries the Anomaly
  WithinBand          judged, and fine
  InsufficientHistory below the minimum sample count, not judged at all
```

"An anomaly or nothing" is two outcomes for three states, and it would make a learning hive indistinguishable from a healthy one. Decision 1 exists precisely to prevent that. The `Dart on purpose` record rep moves to the anomaly's magnitude-and-duration pair, which is a more natural record than a nullable return was.

There is no `AlertInboxEmpty`. An empty inbox is `AlertInboxLoaded` with an empty list, and the view renders the empty message from `alerts.isEmpty`. A separate variant would duplicate the success path in every exhaustive `switch` to save one check.

**`AlertInboxLoadFailure` has no production path in slice one** and that is stated rather than hidden. A generated seed cannot fail. The state exists because slice two's network can, and retrofitting a variant later touches every exhaustive `switch`. It is tested through a repository mock that throws, so it is covered honestly rather than by a coverage exemption, and the README's shortcomings section says so.

This is the one place the plan keeps something ahead of its caller, and the reason it survives where weather did not is that a sealed state variant is load-bearing for every exhaustive `switch` in the UI, while an unread parameter is load-bearing for nothing.

`AlertRepository.fetchAlerts()` returns `Future<List<Alert>>`, not a stream. Slice one has no live feed, so there is no subscription to cancel in `close()`. The `Stream` rep that `docs/original-plan.md` section 2 calls for belongs to the readings feed, which arrives with the simulator.

### Bloc for the inbox, Cubit for the detail, with the reason

`docs/original-plan.md` section 5 lists "the Bloc versus Cubit opinion with a reason from this repo rather than a blog" as something slice one earns. The plan has to record the reason or the deliverable does not exist.

**`AlertInboxBloc` is a Bloc** because slice four puts a debounced, `restartable` search on the inbox, and `bloc_concurrency` transformers operate on an event stream. A Cubit has no events to transform. Converting later would touch every call site and every test.

**`AlertDetailCubit` is a Cubit** because it loads one alert by id and emits one of three states. There is no event-to-state trail worth having and nothing will ever transform it.

The honest caveat, and it goes in the README: judged on slice one alone, the inbox is a load-and-render list and Cubit would be the right call. Bloc is chosen against a known slice four requirement, not against slice one's needs. That is a different thing from choosing a transformer in order to have chosen one, which the brainstorm rejected, because here the future caller is named and the conversion cost is real.

### The repository has no abstraction yet, and that is deferral not omission

`AlertRepository` is one concrete class. It runs the evaluator over generated readings from `seed_readings.dart`. No interface, no data source, no second implementation.

`docs/original-plan.md` says two implementations of one interface on day one is dependency injection demonstrated. At slice one the second implementation does not exist, so what would actually ship is an abstraction with a single implementor, which is the premature-packaging case VGV names in their own pain points. The usual counter-argument, testability, does not apply: `mocktail` mocks a concrete class without an abstract parent, and the VGV testing standard says widget tests mock the Bloc rather than the repository anyway.

So the data layer arrives in slice two, when the GraphQL client gives it a second implementation and a reason. That introduction is timed and written up the same way the domain package extraction is, which turns a deferred layer into a second measured pain point rather than a gap.

**State this in PR 1's description.** It is an acceptance criterion of Phase 4, not a sentence in this plan, because the pull request is the one place a reviewer meets the shape without the reasoning attached.

### The domain directory is deliberately not shaped like a package

`app/lib/domain/` holds plain files. No `src/` subdirectory, no barrel export, despite the repository standard requiring both at a package boundary.

The domain is not a package boundary on day one. Slice two extracts it and times the extraction, and that number goes in the README as a pain point with evidence. Pre-shaping the directory now would move most of the extraction cost into this plan and leave slice two measuring a rename.

**The measurement needs a denominator.** Phase 2 records what the extraction will have to move: the domain file count and the number of import sites referencing it. Without that, slice two's number is a bare figure with nothing to read it against.

**State this in PR 1's description too**, for the same reason as the repository shape. A reviewer who meets both omissions without the reasoning will read the second in light of the first.

Feature barrels are a different case and they are not deferred. `alert_inbox/alert_inbox.dart` and `app/app.dart` are the VGV feature-folder convention, they cost nothing now, and no measurement depends on their absence.

### Weather and season are out entirely

`YardConditions`, the evaluator's weather parameter and the `Season` type are all cut. Not deferred inside the signature, cut.

`docs/original-plan.md` argued for keeping the parameter on day one because adding it later means touching every call site and every test. That is true and it is not worth paying, because the parameter would be accepted and never read. Weather context is issue 1, the rain demo is first on the cut list, and a parameter with no behaviour, no caller and nothing to assert is not a design hook. It is a comment with a type annotation.

**The cost, stated rather than hidden.** Candidate cause ranking loses its season key, so it ranks on metric and pattern alone. A weight drop over hours still suggests swarm and over days still suggests robbing, which is most of the value. What is lost is the refinement that the same drop ranks differently in May than in October. That becomes an open issue alongside the ten already in `docs/original-plan.md` section 1.

Adding the parameter back in slice two costs one signature change and a test update, against a repository that will be about a thousand lines. The build plan's estimate of that cost was made when the domain was imagined as much larger.

### Dependencies added in this plan

Only what slice one uses. `drift`, `fl_chart`, `graphql_flutter` and `bloc_concurrency` are not added here, because a dependency with no caller is noise in a work sample and `pubspec.yaml` is one of the first files a reviewer opens.

| Package | Why, in this slice |
|---|---|
| `very_good_analysis` | From the first commit. Scaffolded in |
| `flutter_bloc` | `AlertInboxBloc`, `AlertDetailCubit`, `BlocProvider` in each Page |
| `equatable` | Value equality on every domain type and every Bloc state |
| `go_router` | The `alert/:id` route, so the deep-link shape exists before notifications would need it |
| `mocktail` | The repository fake in the Page test. Never `mockito` |
| `bloc_test` | `blocTest()` for the Bloc, `MockBloc` and `MockCubit` for the View tests |

Check each against pub.dev on the day. The versions in `docs/original-plan.md` section 3 are a Sep 11 snapshot, not a pin.

`go_router` without `go_router_builder` leaves `alert/:id` stringly typed. That is consistent with keeping codegen out of slice one, and the cost is a route that fails at runtime rather than at compile time if a path is mistyped. Stated here rather than discovered.

### Environment and the MCP failure

Prerequisites are in `docs/original-plan.md` section 3 and are not restated here, because two copies of a dated table drift the moment either is touched. Verify against that section on the day.

One plan-specific fact: both the `dart` and `very-good-cli` MCP servers were confirmed still failing to connect on Sep 11, 2026. That blocks **Phase 5 only**. The fix order is in section 3 of the build plan. Ten minutes, then run the gate by hand in a terminal and say so. The gate's additions are the deliverable and they do not care which process produced them.

## Implementation Phases

### Phase 1: Scaffold and repo setup

- **Status:** Not started
- **Owner:** Agent-assisted, read before accept
- **Scope:** Scaffold the Flutter app with Very Good CLI, rename the directory to `app/`, verify the generated tree, set the coverage exclusion in CI, add the LICENSE, install CodeRabbit.
- **Files touched:** `app/**` (generated), `.github/workflows/main.yaml` at the repository root, `LICENSE`, `README.md`
- **Detail:**
  - `very_good create flutter_app keeper` run in a terminal by hand so the output is watched, then `git mv keeper app`. The one argument sets both the directory and the Dart package name, so scaffolding directly as `app` would make every import read `package:app/...`, which says nothing in a public work sample. This way imports read `package:keeper/domain/evaluator.dart`.
  - The rename lands in the same commit as the scaffold, so history shows the intended shape rather than a move.
  - **Verify rather than trust**, and record what is actually there: three flavors with their own entry points, `bootstrap.dart` with a `BlocObserver`, localization wired with `context.l10n`, a mirrored `test/` tree, **`test/helpers/pump_app.dart` and `test/helpers/helpers.dart`**, `very_good_analysis` present, and a GitHub Actions workflow with coverage enforced. Anything missing is added by hand and noted.
  - **Move the workflow to the repository root.** The scaffold writes `.github/workflows/main.yaml` inside the package it generates, so after `git mv keeper app` it lands at `app/.github/workflows/`. GitHub Actions only reads `.github/` at the repository root and will silently run nothing. Move it to the root and set the job's `working-directory` to `app`. Confirm a run appears on the first push rather than assuming.
  - **The coverage exclusion goes in CI, not in a config file.** `very_good test` takes `--exclude-coverage` as a command flag and has no config file to hold it. The generated workflow calls the `very_good_workflows` reusable Flutter workflow, which exposes a coverage-excludes input. Set it there, and confirm the exact input name on the day. Put the full command in the README's build instructions as well, so a fresh clone runs the same gate.
  - MIT LICENSE. Confirm `git config user.email` is the personal address before committing, because fixing it later means a history rewrite.
  - Install CodeRabbit. Free tier, and the repository is already public.
  - **Issues are not filed here.** The ten domain issues already have a paragraph each in `docs/original-plan.md` section 1, so redrafting them into a second document is copying rather than deciding. Four slice issues need one line each. Filing more than two issues for a single effort needs Jamie's approval before any are created, so this happens when he says go and it does not gate this phase.
- **Acceptance criteria:** `flutter run --flavor development --target lib/main_development.dart` launches the counter app on a simulator. The generated test suite passes. **The workflow sits at the repository root and a run appears on the first push.** **The `.g.dart` exclusion is present in that workflow**, which is the version that gates merges.
- **Validation:** `test -d .github/workflows && ! test -d app/.github && grep -rq 'g.dart' .github/workflows/` proves the workflow move and the exclusion. Then `cd app && flutter analyze` and the unscoped coverage command. Then `manual` 1. Push the branch 2. Confirm a GitHub Actions run appears, since a workflow in the wrong place fails silently 3. Confirm `flutter run --flavor development --target lib/main_development.dart` launches on a simulator

### Phase 2: False-positive policy and domain types

- **Status:** Not started
- **Owner:** **Jamie, by hand. No agent touches these files.**
- **Scope:** Write the false-positive policy as a document first, then the domain value classes with their unit tests.
- **Files touched:** `docs/false-positive-policy.md`, `app/lib/domain/*.dart`, `app/test/domain/*_test.dart`
- **Detail:**
  - The policy is written before the evaluator and restates all eight decisions with the reasoning for each, **plus the per-metric sigma floor**, which is a ninth rule the decisions implied but did not name. It must also state what a false negative costs against a false positive, because that is the first question the design invites.
  - Domain types: `Yard`, `Hive`, `HiveStatus`, `Metric`, `Reading`, `Baseline`, `Anomaly`, `Alert`, `AlertStatus`, `Severity`, `CandidateCause`. Every one carries `Equatable`. Sealed classes or enums with exhaustive `switch` at the use site. `EvaluationResult` and its three variants are the exception and are written in Phase 3, because they only make sense beside the evaluator that returns them.
  - Dart on purpose, deliberately and pointably: a record for the anomaly's magnitude-and-duration pair, an extension type for `HiveId` and `AlertId`, sealed classes for `AlertStatus`, pattern matching in the triage switch. No isolate. There is no honest use for one in this app and manufacturing one is worse than not having one.
  - **Record the extraction denominator**: the domain file count and the number of import sites referencing it. Slice two's timed extraction number is meaningless without it.
- **Acceptance criteria:** Every domain type has a test file asserting value equality and its own behaviour. The policy document names all eight decided values plus the per-metric sigma floor, each with a reason, and states what a false negative costs against a false positive. The extraction denominator is recorded.
- **Validation:** `cd app && very_good test test/domain`. Fast loop, not the gate. See Phase 5.

### Phase 3: The baseline evaluator

- **Status:** Not started
- **Owner:** **Jamie, by hand. No agent touches these files.**
- **Scope:** The evaluator: a reading and its baseline in, an `EvaluationResult` out.
- **Files touched:** `app/lib/domain/evaluator.dart`, `app/lib/domain/baseline.dart`, `app/lib/domain/candidate_causes.dart`, `app/test/domain/evaluator_test.dart`, `app/test/domain/baseline_test.dart`, `app/test/domain/candidate_causes_test.dart`
- **Detail:**
  - The rolling window computes mean and standard deviation over the hive's own readings for that metric. Per hive, per metric. No peers, no calendar. Band at `k = 3.0` out and `k = 2.5` back, N of 3, cadence 15 minutes, minimum history half the window. Severity from the nine-cell table.
  - Candidate cause ranking lives in `candidate_causes.dart` and **scores a set of signals, not one metric**. Each cause declares the signals it predicts, a bear predicting tilt plus a weight drop plus falling brood temperature, a swarm predicting a weight drop with brood temperature holding. Rank by how much of the incident's signal set each cause accounts for. No season, no calendar, no date arithmetic anywhere in the domain.
  - This is what lets a bear outrank a swarm, and it is the whole reason incidents group across metrics. It is still a table and a comparison, not a model, and the code should not imply otherwise. The repository calls it when it promotes an incident, so it needs a file and a test of its own rather than hiding inside the evaluator.
  - **Its tests are the discrimination cases**, not coverage of the table: a tilt plus a weight drop ranks bear above swarm, a weight drop with brood temperature holding ranks swarm above bear, and brood temperature instability with rising sound variability ranks queen loss first.
  - Tests cover the policy edges explicitly and by name: a value hovering at the band edge does not flap, `N - 1` consecutive breaches raise nothing, the Nth raises, a gap longer than twice the cadence resets the counter, a hive below the minimum sample count returns `InsufficientHistory` rather than `WithinBand`, **a metric whose window sigma is zero uses the floor rather than dividing by it**, **an anomalous reading does not enter the baseline the next reading is judged against**, and severity for each of the nine cells.
- **Acceptance criteria:** Each named case in the detail list above exists as a test: band-edge flap, `N - 1` raises nothing, `N` raises, the gap reset, below minimum history, the zero-sigma floor, the contaminated-baseline case, and all nine severity cells. Sixteen cases minimum.
- **Validation:** `cd app && very_good test test/domain`. Fast loop, not the gate.

### Phase 4: `AlertInboxBloc`, hand-written

- **Status:** Not started
- **Owner:** **Jamie, by hand. No agent touches these files.**
- **Scope:** The reading generator, the repository that evaluates it, and `AlertInboxBloc` with its `blocTest` cases. Committed before any gate runs. Ends PR 1.
- **Files touched:** `app/lib/repositories/seed_readings.dart`, `app/lib/repositories/alert_repository.dart`, `app/lib/alert_inbox/bloc/*.dart`, `app/lib/alert_inbox/alert_inbox.dart`, `app/test/repositories/seed_readings_test.dart`, `app/test/repositories/alert_repository_test.dart`, `app/test/alert_inbox/bloc/alert_inbox_bloc_test.dart`
- **Detail:**
  - `seed_readings.dart` takes excursion specs, each naming a hive, a metric, a start time, a magnitude in sigma and a duration in readings, and generates the reading series around them. No literals.
  - One concrete `AlertRepository` exposing `Future<List<Alert>> fetchAlerts()`. Phase 6 adds `Future<Alert?> fetchAlert(AlertId)` when `AlertDetailCubit` needs it, returning nullable so not-found travels as null rather than an exception. Writing it here instead is fine too. It is one method and the choice does not need making now.
  - The repository runs the evaluator from Phase 3 over the generated readings, **collapses consecutive anomalous readings into runs, then groups runs that are open at the same time on one hive into a single alert**, and ranks candidate causes against that alert's whole signal set. That is the one place the arithmetic-to-decision boundary is crossed, and it stands in for what the backend does in the real system. No interface. See the repository shape section for why, and state it in the PR description.
  - **Two repository tests pin the collapse**, because this is the easiest thing in the plan to get wrong and the hardest to notice. Ten alerts for one bear still looks like a working inbox, and so do four. One asserts a single metric's excursion yields one alert rather than one per reading. The other asserts a four-metric bear on one hive yields one alert carrying four signals, not four alerts.
  - Repositories hold no Flutter imports, take dependencies through the constructor, and never import another repository.
  - The seed: at least two yards, enough hives to make the yard layout meaningful later, **two excursion specs with identical magnitude and duration on different hives**, which produce a severity tie at different raised-at times and give the tie-break its test case, and **one hive with four overlapping specs across tilt, weight, brood temperature and sound**, which is the bear and the multi-metric collapse test.
  - **`HiveStatus.recovering` is seeded display state in slice one, not behaviour.** Suppressing evaluation for a recovering hive needs a recovery start date, and that date comes from a finding, and findings arrive in slice four. So the recovering hive here has an ordinary excursion in its readings, produces an ordinary alert, and the status rides along on that alert so the inbox has something to render. The relearning behaviour lands with the feedback edge that produces it, not before.
  - **The below-minimum-history hive renders nothing, by construction.** It has no baseline, so it raises no alerts and never appears in an alert list. It stays in the seed because it exercises the evaluator's suppression path end to end, and the assertion that it stays silent lives in the repository test, not in a widget test.
  - **A repository test asserts the evaluator actually ran**, meaning an alert's severity matches what the nine-cell table predicts for its excursion spec. Otherwise the chain is assumed rather than proven.
  - States and events per the state shape section. Sealed, `Equatable`, no `empty` variant.
  - **Ordering is applied when `AlertInboxLoaded` is constructed.** The state carries an ordered list. No widget sorts anything.
  - `blocTest()` for every transition. Never raw `test()` with manual stream assertions. Private mocks per file, underscore-prefixed. `setUp` and `tearDown` inside a group. Mutable objects are `late` and assigned in `setUp`. Test names read as sentences down the group hierarchy.
  - **Commit this phase before Phase 5 runs.** The commit boundary is the evidence.
- **Acceptance criteria:** `blocTest` cases cover load success, empty result, failure and the full three-key sort including the tie-break. **Three tests carry exact names, because success criteria call them by name:** `orders by severity then raised-at then id`, `derives severity from the excursion spec`, `raises nothing for a hive below the minimum history`, `collapses one excursion into one alert`, and `collapses a four-metric bear into one alert`. The commit exists before the first gate run. **PR 1's description states the repository-shape and domain-directory deviations with their reasons.**
- **Validation:** `cd app && very_good test test/alert_inbox test/repositories`. Fast loop, not the gate.

### Phase 5: First green gate, and its additions

- **Status:** Not started
- **Owner:** Agent runs the gate. Jamie reads the diff. This is PR 2.
- **Scope:** Run the unscoped gate over the app package. This PR's diff is the gate's additions.
- **Files touched:** `app/test/**`, `app/lib/**` (formatting only), `README.md`
- **Detail:**
  - **This is the gate on hand-written code.** Phase 1 runs the same unscoped command against the generated scaffold, which is why it passes there. The scoped runs in Phases 2 to 4 are a fast loop and are not a gate at all: `very_good test test/domain --min-coverage 100` only measures libraries those tests import, so an untested file elsewhere in `lib/` is absent from the denominator rather than failing it. Three phases can report green at 100% before the package has ever been measured.
  - Blocked on the MCP connection failure. Ten-minute timebox, then run by hand and say so.
  - The gate will extend and reshape the hand-written tests to close coverage. Because Phase 4 is already committed and merged, its additions are this PR's entire diff.
  - The write-up is three parts: what was written by hand, what the gate added, which additions were kept and why the rest were not. That is a better answer to "how do you work with AI" than any sentence about it.
  - Never weaken a gate to pass it. No deleted assertions, no `// coverage:ignore` on reachable code, no lowered floor without an issue explaining why.
- **Acceptance criteria:** The gate passes at 100% with generated code excluded. The write-up names at least one gate addition that was rejected, with the reason. PR 2 merged with all three reviewers run and its row added to the README comparison table.
- **Validation:** `cd app && very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart'`

### Phase 6: The inbox screen, and slice one

- **Status:** Not started
- **Owner:** Agent-assisted, read before accept. This is PR 3.
- **Scope:** The inbox list, the detail Cubit and view, the router, localization, widget tests, and the removal of the generated counter feature.
- **Files touched:** `app/lib/alert_inbox/view/*.dart`, `app/lib/alert_detail/cubit/*.dart`, `app/lib/alert_detail/view/*.dart`, `app/lib/alert_detail/alert_detail.dart`, `app/lib/app/view/*.dart`, `app/lib/app/router.dart`, `app/lib/app/app.dart`, `app/lib/l10n/arb/app_en.arb`, `app/test/alert_inbox/view/*_test.dart`, `app/test/alert_detail/**/*_test.dart`, `app/test/helpers/pump_app.dart` (extend), **deletions:** `app/lib/counter/**`, `app/test/counter/**` and the counter's ARB entries
- **Detail:**
  - Page provides the Bloc or Cubit, View consumes it. No business logic in a widget. Exhaustive `switch` over the sealed state, so a new variant fails to compile rather than rendering nothing.
  - The view **renders the list in the order the state carries**. No sorting in the widget. No search field. Search is slice four.
  - `AlertDetailCubit` calls `fetchAlert(id)` and maps a null return to `AlertDetailNotFound`. The widget never decides that. If Phase 4 did not write that method, write it here. The hand-written commit is already merged, so extending the repository now costs nothing that matters.
  - **Widget tests mock the Bloc, not the repository.** `class _MockAlertInboxBloc extends MockBloc<AlertInboxEvent, AlertInboxState> implements AlertInboxBloc {}`, stub `state` per case, pump the View under `BlocProvider.value`. The repository fake with `mocktail` is reserved for the one Page test asserting the Page builds the Bloc and dispatches its first event.
  - Extend the template's existing `pump_app.dart` with the repository provider, the router and Bloc provision. Import through the `helpers.dart` barrel. Do not create a second helper.
  - **Every new user-facing string goes through `context.l10n`.** The inbox title, the empty message, the failure message, the not-found message, the severity labels and the recovering-until line. No literals in widgets. Verifying localization in Phase 1 and then hardcoding here would be the worse of the two options, because a reviewer sees both.
  - **Severity is not conveyed by colour alone.** Colour alone fails WCAG 1.4.1. One text or icon cue per severity, and severity colours live in `ThemeData` or a `ThemeExtension`, not inline in the list item.
  - **Delete the generated counter feature.** Nothing half-finished ships in a public work sample, and its ARB key would outlive its only caller. It survives through PR 1 and PR 2 as the temporary home screen, which is fine and worth one line in PR 3's description.
  - `const` is a contract here, not a style choice. A missing `const` is invisible and it is the most common defect in agent-written Flutter.
  - Every generated file is read before it is accepted, with one paragraph written on the decision it makes and whether that decision was right. Not a diff summary. If a file cannot be explained on demand it is rewritten by hand rather than patched.
  - The README gains its slice one line, naming one Bloc and one Cubit in this repo with the reason for each.
- **Acceptance criteria:** The app runs on the iOS Simulator, shows a sorted inbox from seeded data, and opens an alert. No template scaffolding remains. No user-facing string literal remains in a widget. The README comparison table has three rows. PR 3 merged.
- **Validation:** `manual` 1. `cd app && flutter run --flavor development --target lib/main_development.dart` 2. Confirm the inbox lists seeded alerts, most severe first 3. Confirm the two same-severity alerts order by raised-at, newest first 4. Tap an alert and confirm the detail view renders its candidate causes 5. Navigate to `alert/does-not-exist` and confirm the not-found view 6. Confirm the alert on the recovering hive shows its recovering-until line 7. Confirm severity carries a non-colour cue

## Alternative Approaches Considered

**One pull request, or four.** The three review agents disagreed. The simplicity agent argued for one, on the grounds that the build plan says one pull request per slice. That rule is about slices, and the foundation is not one, so its premise does not reach this plan. The scope agent argued for four, separating the scaffold from the hand-written core. Three is the resolution: the scaffold is CLI output a reviewer skims in seconds, so giving it a full review cycle costs three reviewer runs on a diff nobody reads closely. The scope agent's stronger point, isolating the gate so its additions become the diff, is adopted.

**Keeping `YardConditions` as an unread evaluator parameter.** Rejected. `docs/original-plan.md` argued for it on the grounds that adding it later touches every call site and every test, which is true and is not worth paying for a parameter with no behaviour, no caller and nothing assertable. A design hook that does nothing is a comment with a type annotation. `Season` went with it, since its only consumer was cause ranking, and cause ranking on metric and pattern alone keeps most of the value. The lost refinement, that the same weight drop ranks differently in May than October, becomes an open issue.

**Seeding `Alert` objects directly instead of readings.** Rejected on the refinement pass. It is cheaper and it gives exact control over every fixture, but it leaves the evaluator, cause ranking and the severity table with no production caller until slice two. The project's centrepiece would ship as a library nothing calls, which is a worse artifact than a fiddlier sort fixture. Generating readings from excursion specs recovers most of the control anyway.

**Time estimates per phase.** Rejected. The stopping rule and the ordered cut list already handle overrun. An estimate on hand-written work that has not started is a guess, and a wrong one becomes pressure rather than information.

**Median and MAD for the baseline band.** Rejected. It is robust to exactly the excursions the evaluator catches, which sounds decisive until you check whether the failure it prevents is visible. It is not: an anomaly is arithmetic and an alert is a decision waiting to happen, so an alert outlives the anomaly that raised it and a post-event band widening never reaches the UI. The cost was a scale constant to explain in a repository nobody will audit for statistics.

**Hourly cadence.** Rejected, though it is BroodMinder's default and therefore the more honest general claim. The bear scenario is a weight drop "over minutes" preceded by a tilt, and at hourly the whole event falls between two readings. 15 minutes is a supported setting on the same product, so the choice still defends by citation.

**An `AlertRepository` interface with the in-memory fake implementing it.** Rejected. At slice one it is an abstraction with one implementor. `mocktail` mocks concrete classes, so testability does not require it, and the VGV standard mocks the Bloc in widget tests anyway. The data layer arrives in slice two with a second implementation and a reason, timed and written up.

**Scaffold directly as `app`.** Rejected. The single CLI argument sets both the directory and the package name, so every import would read `package:app/...`.

**Set up the pub workspace on day one, or pre-shape `app/lib/domain/` as a package.** Rejected, and this is the load-bearing one. The domain package extraction in slice two is timed and the number goes in the README as a pain point. Either change would move most of that cost into this plan and leave slice two measuring a rename.

**Add `drift` and `fl_chart` now, since later slices need them.** Rejected. A dependency with no caller is noise, and `pubspec.yaml` is one of the first files a reviewer opens.

**Put inbox search in slice one.** Rejected, per the brainstorm. Seeded in-memory data returns instantly, so `restartable` would have nothing to cancel. It would be a transformer chosen in order to have chosen one.

**Let `/build` write the evaluator.** Rejected, permanently. The hand-written core is the evidence and it cannot be recovered once an agent has touched it.

## Success Criteria

```success-criteria
GOAL: Keeper runs on the iOS Simulator showing an alert inbox sorted by severity from seeded local data, on top of a hand-written domain and baseline evaluator that were committed with their tests before the first green gate ran.

SUCCESS CRITERIA:
- The app package analyzes clean and every test passes at 100% coverage with generated code excluded | verify: cd app && flutter analyze && very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart'
- Formatting is clean across all hand-written and generated source, scoped so it cannot trip over build output | verify: dart format --output=none --set-exit-if-changed app/lib app/test
- The CI workflow sits at the repository root, where GitHub will actually read it, and carries the coverage exclusion | verify: test -d .github/workflows && ! test -d app/.github && grep -rq 'g.dart' .github/workflows/
- The false-positive policy document names all eight decided values plus the sigma floor | verify: manual 1. Open docs/false-positive-policy.md 2. Confirm it names the minimum history, the band statistic, both hysteresis thresholds, the cadence, N, the gap rule, the sort order, the severity table and the per-metric sigma floor, each with a reason 3. Confirm it states what a false negative costs against a false positive
- No Flutter import appears anywhere in the domain or repository layers | verify: ! grep -rq "package:flutter" app/lib/domain/ app/lib/repositories/
- No weather or calendar leaked into the domain | verify: ! grep -rqiE 'yardconditions|season|hemisphere|weather' app/lib/domain/
- One excursion yields one alert, not one per anomalous reading | verify: grep -rqF 'collapses one excursion into one alert' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'collapses one excursion into one alert'
- A four-metric bear on one hive yields one alert carrying four signals, not four alerts | verify: grep -rqF 'collapses a four-metric bear into one alert' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'collapses a four-metric bear into one alert'
- Candidate causes discriminate rather than look up, proven by bear outranking swarm on the same weight drop | verify: grep -rqF 'ranks bear above swarm when tilt accompanies the weight drop' app/test/domain/ && cd app && flutter test test/domain --plain-name 'ranks bear above swarm when tilt accompanies the weight drop'
- The inbox sort is proven by its own named test | verify: grep -rqF 'orders by severity then raised-at then id' app/test/alert_inbox/ && cd app && flutter test test/alert_inbox --plain-name 'orders by severity then raised-at then id'
- The evaluator has a production caller, proven by a repository test asserting a generated excursion produces the severity the table predicts | verify: grep -rqF 'derives severity from the excursion spec' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'derives severity from the excursion spec'
- The below-minimum-history hive stays silent rather than reading as healthy | verify: grep -rqF 'raises nothing for a hive below the minimum history' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'raises nothing for a hive below the minimum history'
- No user-facing string literal remains in a widget | verify: manual 1. Open each file under app/lib/alert_inbox/view/ and app/lib/alert_detail/view/ 2. Confirm every displayed string resolves through context.l10n 3. Confirm app_en.arb holds the inbox title, the empty message, the failure message, the not-found message, the severity labels and the recovering-until line
- No search field exists in the inbox view | verify: ! grep -rq 'TextField' app/lib/alert_inbox/view/
- No template scaffolding remains | verify: ! test -d app/lib/counter && ! test -d app/test/counter
- The hand-written Bloc tests were committed before the first green gate run | verify: manual 1. Run `git log --oneline -- app/test/alert_inbox/bloc/alert_inbox_bloc_test.dart` 2. Confirm the first commit touching it predates PR 2
- The green gate write-up names at least one gate addition that was rejected, with the reason | verify: manual 1. Open the README section holding the write-up 2. Confirm it states what was hand-written, what the gate added, and which additions were rejected and why
- The app runs on the iOS Simulator, opens an alert, and handles an unknown id | verify: manual 1. `cd app && flutter run --flavor development --target lib/main_development.dart` 2. Confirm the inbox lists seeded alerts most severe first 3. Tap an alert and confirm the detail view renders its candidate causes 4. Navigate to alert/does-not-exist and confirm the not-found view
- The README comparison table has three rows, one per pull request, covering all three reviewers | verify: manual 1. Open the README 2. Confirm three rows naming what CodeRabbit, the flutter-reviewer subagent and /review each caught and missed on each diff
- The README names one Bloc and one Cubit in this repo with the reason for each | verify: manual 1. Open the README's slice one line 2. Confirm both are named with a repo-specific reason, not a general one

NON-GOALS:
- The simulator, in any form. It starts at slice two
- Any network call. Slice one has no network at all
- The domain package extraction, the pub workspace, and path dependencies. Start of slice two
- The data layer and any repository abstraction. Slice two, timed and written up
- Peer comparison in the baseline. Issue 9
- Weather in any form. No `YardConditions`, no evaluator parameter for it, no rain demo. Issue 1
- Season and any other calendar input. Cause ranking keys on metric and pattern only. New issue
- Inbox search, the Drift cache, the outbox, the guided checklist and findings. Slice four
- The metric chart against its baseline band. Slice two
- The sync contract document. Written before slice three, not here
- Notifications. The alert/:id route exists so the deep-link shape is established, and nothing sends one

VERIFICATION COMMAND: dart format --output=none --set-exit-if-changed app/lib app/test && test -d .github/workflows && ! test -d app/.github && grep -rq 'g.dart' .github/workflows/ && test -d app/lib/domain && test -d app/lib/repositories && ! grep -rq "package:flutter" app/lib/domain/ app/lib/repositories/ && ! grep -rq 'TextField' app/lib/alert_inbox/view/ && ! test -d app/lib/counter && ! test -d app/test/counter && ! grep -rqiE 'yardconditions|season|hemisphere|weather' app/lib/domain/ && grep -rqF 'orders by severity then raised-at then id' app/test/alert_inbox/ && grep -rqF 'derives severity from the excursion spec' app/test/repositories/ && grep -rqF 'raises nothing for a hive below the minimum history' app/test/repositories/ && grep -rqF 'collapses one excursion into one alert' app/test/repositories/ && grep -rqF 'collapses a four-metric bear into one alert' app/test/repositories/ && grep -rqF 'ranks bear above swarm when tilt accompanies the weight drop' app/test/domain/ && cd app && flutter analyze && flutter test test/alert_inbox --plain-name 'orders by severity then raised-at then id' && flutter test test/repositories --plain-name 'derives severity from the excursion spec' && flutter test test/repositories --plain-name 'raises nothing for a hive below the minimum history' && flutter test test/repositories --plain-name 'collapses one excursion into one alert' && flutter test test/repositories --plain-name 'collapses a four-metric bear into one alert' && flutter test test/domain --plain-name 'ranks bear above swarm when tilt accompanies the weight drop' && very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart'
```

## Success Metrics

| Metric | Target | Where it is recorded |
|---|---|---|
| Coverage on the app package | 100%, generated code excluded | CI workflow |
| Hand-written test count before the first gate run | Recorded, whatever it is | Green gate write-up |
| Gate additions kept against rejected | Both counts stated, with a reason for at least one rejection | Green gate write-up |
| Reviewer findings per pull request | Per reviewer, caught and missed, three rows | README comparison table |
| Domain file count and import sites at Phase 2 | Recorded | The denominator for slice two's extraction timing |

The first three exist to keep the wall-clock number honest. A generation time only ever appears alongside its verification cost.

## Dependencies & Prerequisites

**Ready:** Dart 3.13.2 via Flutter 3.47.2, `jq` 1.7.1, Very Good CLI 1.5.0, `~/.pub-cache/bin` on PATH, both plugins at 0.0.5, the repository public at `Jamie-DB/keeper`. Verify against `docs/original-plan.md` section 3 on the day. A version there is a snapshot.

| Item | State | Blocks |
|---|---|---|
| `dart` and `very-good-cli` MCP servers | Failing to connect, confirmed Sep 11 | Phase 5 through the agent. Workaround is running the gate by hand |
| Approval to file the fourteen issues | Not given | Nothing. Issue filing no longer gates Phase 1 |
| CodeRabbit installation | Not done | The comparison table's first row, in PR 1 |
| Sign-off on the eight decisions | Given, Sep 11 | Nothing. Settled |
| `very_good_workflows` coverage-excludes input name | Unconfirmed | Phase 1's CI exclusion. Confirm on the day |

## Risk Analysis & Mitigation

| Risk | Consequence | Mitigation |
|---|---|---|
| **The gate runs before Phase 4 is committed** | The hand-written evidence is destroyed permanently and cannot be reconstructed | Phase 4's acceptance criterion is the commit itself, and PR 1 must merge before PR 2 opens |
| **An agent writes any part of Phases 2 to 4 before Jamie does** | Same. The central claim of the repository stops being true, and unlike a later edit this one cannot be undone | The boundary table, the banner at the top of this plan, and `/build` stopping at the end of Phase 1. Edits after the Phase 4 commit are ordinary work and carry no risk here |
| **A scoped test run is mistaken for the gate** | Three phases report green at 100% before the package has been measured, and the real gate fails late | Phases 2 to 4 label their commands "fast loop, not the gate". Only Phase 5's command is called a gate |
| **The evaluator's numbers get picked to make tests pass** | The policy becomes decoration and does not survive one follow-up question | The policy document is written before the evaluator and each number carries its reason. The tests are written against the document |
| **Slice one grows** | Nine days, and slice four is the part that cannot be cut | The non-goals list is the scope boundary. Anything not on it that arrives during Phase 6 becomes an issue |
| **The reading generator eats Phase 4** | It is the one piece of new invention in an otherwise specified phase, and tuning it until the right alerts come out is open-ended | Excursion specs are declarative, so a wrong alert is a wrong spec rather than a generator bug. If tuning passes an hour, seed the alerts directly for the fixtures that resist it and keep the chain live for the one hive that demonstrates it |
| **The generated scaffold differs from what the plan assumes** | Silent gap discovered later | Phase 1 verifies a named list, `pump_app.dart` among them, rather than trusting this plan |
| **MCP stays broken** | `/green-gate` cannot run | Ten-minute timebox, then run the gate by hand. The additions are the deliverable and they do not care which process produced them |
| **CodeRabbit produces little on a young repository** | The three-row comparison is thin | Stated in the README as what happened. Two reviewers with real findings is a better artifact than three where one is padding. This is the brainstorm's open question and it resolves when the findings exist |

## Future Considerations

Slice two extracts `packages/hive_domain/` and times it against the denominator Phase 2 records, introduces the data layer with a second repository implementation and times that too, then builds the simulator's GraphQL read side with a hand-rolled `shelf` handler and a hand-written `schema.graphql`.

The sync contract's eight decisions are written before slice three, because decision 1 puts a client-minted id on every `TriageAction` and that type is written in slice three. `TriageAction` carries its id from the moment the type is first written. Retrofitting ids onto a type with call sites and tests is the avoidable version of that work.

Slice four puts the debounced `restartable` search on `AlertInboxBloc`, which is the reason it is a Bloc rather than a Cubit.

## Documentation Plan

| Document | Change | Phase |
|---|---|---|
| `docs/false-positive-policy.md` | New. The evaluator's specification, all eight decisions plus the sigma floor, each with a reason | 2 |
| `README.md` | Comparison table row for PR 1, the repository-shape and domain-directory deviations | 4 |
| `README.md` | The green gate write-up, comparison table row for PR 2 | 5 |
| `README.md` | Slice one line naming one Bloc and one Cubit with reasons, two shortcomings (cause ranking's missing season key, and worst-wins severity under-ranking quiet correlated failures like queen loss, both pointing at their issues), comparison table row for PR 3, build instructions with the full gate command | 6 |
| `docs/original-plan.md` | Unchanged. Stays the frozen third iteration. This plan carries the deltas | - |

## References & Research

### Internal

- Specification: `docs/original-plan.md`, sections 1 through 8
- Design decisions overriding the specification: `docs/brainstorm/2026-09-11-keeper-hive-monitoring-brainstorm-doc.md`
- README, build log and style standards: `docs/repo-standards.md`
- Architecture, state management and testing rules: `CLAUDE.md`
- Environment table and the MCP failure runbook: `docs/original-plan.md` section 3
- Build order and the stopping rule: `docs/original-plan.md` section 8
- The sync contract's eight decisions: `docs/original-plan.md` section 5

### External, researched Sep 11, 2026

Reading cadence and the gateway architecture were checked against two shipping products rather than guessed.

- **BroodMinder** logs hourly by default and is configurable to every 15 minutes, holding roughly 7,000 readings of internal storage. It broadcasts the latest reading every 5 seconds over Bluetooth and dumps history when a phone comes within range. Hubs gather from sensors within about 20 metres. This is decision 4's citation. [Betterbee guide](https://www.betterbee.com/instructions-and-resources/broodminder-hive-monitoring-system-guide.asp), [Honey Bee Suite](https://www.honeybeesuite.com/broodminder-transmits-hive-data-to-your-phone/)
- **Arnia** runs one gateway per apiary within 30 metres, collecting from every hive monitor before transmitting. It confirms the gateway-per-yard architecture the app assumes, and it is the reason weather belongs at yard level whenever issue 1 is picked up: forty hives share one sky, and the shipping products put that sensor on the hub rather than on each hive. [Arnia how it works](http://dev.arnia.co.uk/how-it-works/), [Pod Group](https://podgroup.com/arnia-remote-hive-monitoring-system/)

### Related work

- Merged: Jamie-DB/keeper#1, day one setup and brainstorm
- Issues: none filed yet. Ten have a paragraph each in `docs/original-plan.md` section 1, four slice issues need one line each, all held for approval
