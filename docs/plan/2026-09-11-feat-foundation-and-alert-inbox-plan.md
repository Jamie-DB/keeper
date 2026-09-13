---
title: "feat: foundation and alert inbox"
type: feat
date: 2026-09-11
---

## feat: foundation and alert inbox - Extensive

> **Read this before `/build` runs anything.** Phases 2, 3 and 4 are written by Jamie by hand, and no agent touches those files until they are committed. `/build` must stop at the end of Phase 1 and wait. This is an ordering rule, not a permanent claim on the files. See [Human and agent boundary](#human-and-agent-boundary).

> **For Jamie:** everything from Overview to Environment is reasoning, read once. Work from [Implementation Phases](#implementation-phases) down. Each phase opens with what it earns, the hand-written ones with what to have open, and the hints stay collapsed until stuck, so read the plan rendered rather than in an editor. Nothing new reaches the screen between Phase 1's counter and Phase 6. Phases 2 to 4 are proved by tests, and the bear is the thread: `ranks bear above swarm when tilt accompanies the weight drop` in Phase 3, `collapses a four-metric bear into one alert` in Phase 4, then the bear's alert on screen in Phase 6.

*Reviewed Sep 11, 2026 by the simplicity, VGV-conventions and scope-splitting agents. Their findings are applied inline rather than listed. Where two disagreed, the disagreement and its resolution are recorded in [Alternative approaches considered](#alternative-approaches-considered). A refinement pass the same day traced the data paths and moved four things: the pull request split, the window unit, the evaluator's shape and the cause-ranking score. Each change is recorded where it lands. A polish pass on Sep 13, 2026 scaffolded the template into a temporary directory and ran the gate on it, which corrected three claims: the CLI has a config file, `all`-files coverage needs the entry points and the localization output excluded or the untouched scaffold fails at 27 percent, and both MCP servers connect. It also moved the implementation hints for the hand-written phases into collapsed blocks so the spec is read first. A teaching pass the same day walked the six phases as a follow-along and the four handoffs between Jamie and the tooling against the skills' own files. It added what each phase earns, what to read first, what cold permits, the read-before-accept lens, and the mechanics of stopping and resuming `/build`. It also corrected three claims: a scoped `very_good test` is the full gate once the config file exists, the template's workflow runs on pull requests and not on branch pushes, and three of the six listed dependencies were already in the scaffold.*

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
| 5. First green gate and its additions | Jamie runs it once, `/green-gate` loops, Jamie reads the diff | The gate's additions are the evidence, so they must be distinguishable |
| 6. Inbox screen and slice one | Agent-assisted, read before accept | The tooling writes the rest, per rule 2 |

**How the handoffs work, mechanically.** `/build` picks the first phase whose `**Status:**` line is not the exact string `Done` and builds it, so marking a phase done means editing that line in this file, in the commit that finishes the phase. Any other wording leaves the phase open and the next `/build` starts there, which for Phase 2 is the one failure this plan calls irreversible. When `/build` asks at its start how to commit, answer that Jamie commits himself and do not let it save the preference. That mode stops after every phase with the files staged, which is what read-before-accept needs; the recommended auto-commit mode commits before anything is read. Phase 1 starts in a terminal and `/build` joins partway, see the phase. Phase 5 is not a `/build` phase: Jamie runs `/green-gate` on the PR 2 branch and marks Phase 5 `Done` by hand. `/build` is invoked a second time for Phase 6 only, on a new branch from `main` after PR 2 merges, with Phases 1 to 5 all reading `Done`.

**What the boundary actually protects, and what it does not.** Two claims rest on it: that the domain, the evaluator and the inbox Bloc were written cold before an agent touched the repository, and that the green gate's additions are readable as a diff against what Jamie wrote. Both are protected by commit order. Once Phase 4 is committed, the cold version is in git permanently and nothing later can make that commit agent-written.

So the rule is about sequence, not ownership. Two things are one-way doors:

- No agent writes any part of Phases 2 to 4 before Jamie has.
- The gate does not run before Phase 4 is committed.

After PR 2 merges, those files are ordinary code. Phase 6 may extend `Alert`, add a repository method, or reshape anything else it needs, under the same read-before-accept rule that governs the rest of the agent-assisted work. Requiring Phase 4 to anticipate everything Phase 6 might want would force speculative completeness into the one place in this plan that should be minimal.

**What cold permits.** Cold means Jamie typed the code and no agent wrote or dictated it. Reading is open: dart.dev, pub.dev and the package READMEs, `docs/original-plan.md` section 2, the template's own counter feature and tests, and the plugin's skill files. `bloc`, `testing` and `layered-architecture` under the marketplace cache are plain markdown, and they are the standard `flutter-reviewer` grades PR 2 against, so reading them first turns its findings from a lesson after the fact into the standard the code was written to. Asking an agent a question is fine while the answer stays prose. The line is a snippet that lands in a file: an agent-written snippet retyped is not hand-written, and the README sentence stops being true.

**The read-before-accept lens.** Every agent-written file, in Phase 1, Phase 5 and Phase 6, is read through the four items in `docs/original-plan.md` section 7, item 3, before its paragraph is written. Value equality, because Dart classes compare by identity and a Bloc emitting an equal-but-not-`==` state rebuilds forever. Sealed types switched exhaustively with no `default`, so a new variant fails to compile. `const` on every constructor that can take it, since a missing one is invisible and is the most common defect in agent-written Flutter. Nothing async beyond what a `Future` needs, because this app has no honest use for an isolate. Phase 6 adds the three things the counter showed in Phase 1: a key on each list item and what it is keyed on, `BlocProvider` creating in the Page against `BlocProvider.value` in the test, and `context.read` in callbacks against `select` or `watch` in `build`. The paragraph says what the file does on each item that applies. Anything else is a diff summary, which is the thing the rule forbids.

### Three pull requests

| PR | Phases | Why it is its own diff |
|---|---|---|
| 1. Scaffold and repo setup | 1 | It merges green on the template's own tests, which proves the workflow runs at the repository root before any hand-written code depends on it |
| 2. The hand-written core, then the gate | 2 to 5 | The hand-written commits land first and the gate's commits land after, so the gate's additions are the diff between them. See below for why the gate does not get its own pull request |
| 3. The inbox screen | 6 | One layer, one feature, agent-assisted under the read-before-accept rule |

All three get all three reviewers, so the README comparison table gets three rows on three diffs of genuinely different character: CLI output, dense pure-Dart logic with its gate additions, and Flutter UI. `/create-pr` cannot be model-invoked. Jamie types it, on all three.

**Per pull request, in this order:** commit, run `/review` and dispatch the `flutter-reviewer` subagent by name on the clean branch, `/create-pr`, wait for CodeRabbit, then fix. All three report on the same commit or the table compares three different diffs. The comparison row is the last commit on its own pull request, written from all three, and a CodeRabbit pass over the row commit is not a row. `/review` writes an untracked report under `docs/code-review/`; commit it, per `docs/original-plan.md` section 3, so the row cites a file rather than memory. On PR 3, `/build` runs `/review`'s four agents itself after Phase 6 and deletes its report at cleanup, so copy `docs/reviews/review.md` aside first, count it as the `/review` column, and do not run `/review` again on the same diff. `flutter-reviewer` covers bloc, testing, security and accessibility only, so its silence on the router, the theme and the ARB is scope, not a pass, and the row says so. Each row also records any reviewer finding Jamie rejected, with the reason, because `docs/original-plan.md` section 5 asks for one such rejection as an opinion the first run produces. `/rebase` is also typed by Jamie and uses bare `git stash`; Conductor workspaces are worktrees sharing one stash list, so check `git stash list` is empty before running it.

**Why the gate does not get its own pull request.** An earlier draft put the hand-written core in PR 1 and the gate in PR 2. Traced through CI, that cannot work. Phase 1 ships the workflow with `min_coverage` at 100 and blocking. The hand-written tests are expected to sit below 100, because if they did not the gate would have nothing to add and there would be no write-up. So a pull request holding the hand-written core alone is red at merge, and main is broken, which the repo standard forbids. The commit boundary inside PR 2 carries the same evidence, and the write-up describes the gate's additions as the commits after the hand-written commit in PR 2, never by hash.

### Eight decisions neither document settled, now settled

Flow analysis over the inbox and the evaluator found eight decisions with no answer in either document. All eight were decided by Jamie on Sep 11, 2026. The numbers below are the specification. `docs/false-positive-policy.md` restates them with their reasoning in Phase 2, before the evaluator is written.

**The scope call behind all six evaluator decisions.** The evaluator is on the never-cut list because it is the most testable thing in the project, not because its statistics are novel. Nobody reviewing a Flutter repository will audit a scale constant. So every decision below picks the simplest option that stays defensible in one sentence, and the saved effort goes to slice four.

| # | Decision | Value | Why this and not the alternative |
|---|---|---|---|
| 1 | Minimum history before the baseline judges | 336 in-band readings, half the window | Enough samples for a stable mean and sigma, and a restarted hive rejoins monitoring in days rather than a week. Below it the evaluator returns `InsufficientHistory`, so a **learning** hive is never mistaken for a healthy one |
| 2 | Band statistic | Rolling mean plus or minus `k` times the standard deviation over the last 672 in-band readings, a count and not a time span | The rolling window is the mechanism behind "drifts with the season" and it is about 20 lines. Seven days at decision 4's cadence, but counted, see the window paragraph below. Median and MAD was rejected, see the alternatives section |
| 3 | Hysteresis | Leave the band at `k = 3.0`, clear only at `k = 2.5` | Clearing is strictly harder than breaching, so a value sitting on the line cannot oscillate |
| 4 | Reading cadence | 15 minutes. 96 readings per hive per metric per day | BroodMinder's supported fast mode, so the choice defends by citation. Hourly is its default but the bear scenario is a weight drop "over minutes", invisible at hourly |
| 5 | N consecutive breaches | 3, so 45 minutes to alert | Fast enough to catch a bear while it is still happening, slow enough to ignore a single spike |
| 6 | Missing readings | A gap longer than twice the cadence resets the consecutive counter and raises nothing | A silent sensor is neither inside the band nor outside it. Sensor health is its own alert class and it is issue 10 |
| 7 | Inbox sort | Severity descending, then raised-at descending, then alert id ascending, **applied when the loaded state is constructed** | Total and deterministic, so the widget test cannot go flaky. Severity alone is not a total order. The state carries an ordered list and the widget never sorts |
| 8 | Tapping an alert | The `alert/:id` route, backed by `AlertDetailCubit` | Slice two adds the chart and the GraphQL fetch to a screen that already exists. An unknown id resolves to a not-found state in the Cubit, not in the widget, because a deep link can arrive stale |

**Severity.** A lookup table keyed by magnitude tier and duration tier, not a float. A table is something a person can read and argue with.

**Magnitude is the reading's signed distance from the rolling mean, in sigma**, not its distance beyond the band edge. The severity table reads its absolute value. The sign is kept because cause ranking needs direction: a weight drop and a weight gain are different signals, and without the sign a swarm's weight drop would match rain. The band edge sits at 3.0 sigma, so the lowest tier starts exactly where an anomaly becomes possible and nothing can fall off the bottom of the table. Duration is consecutive readings outside the band.

**The window holds only readings that were within the band.** An anomalous reading never enters the baseline it was judged against. Without this an excursion contaminates its own baseline: a six-sigma drop inflates sigma as it runs, each later reading scores lower than the one before, and a worsening situation reads as improving. It is also what makes the reading generator tractable, because a spec asking for five sigma then evaluates near five sigma rather than lower on every subsequent reading. One sentence in the policy document, and it is the same idea as a recovering hive relearning rather than judging.

**The window is a count of in-band readings, not a span of time.** The two are the same 672 until an excursion, and then they diverge in the direction that matters. A time window that excludes anomalous readings drains while an excursion runs: seven days out of band leaves no in-band readings in the last seven days, the hive flips to `InsufficientHistory`, and monitoring stops silently in the middle of the incident it should be reporting. A count window keeps the last 672 readings that were judged fine, however long ago, and never drains. No seeded excursion runs anywhere near 672 readings, so the seed never reaches this edge. The policy document states the rule and the evaluator has a test for it.

**The baseline is the trailing window, ending before the reading under test.** A reading is never part of the statistics it is compared against. Readings that arrive while history is insufficient enter the window unjudged. That is how it fills.

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

The second stage is not about tidiness. `docs/original-plan.md` says correlated signals across metrics are what make bear outrank swarm in the candidate causes, and this plan scores the set rather than the order. That is only possible if one alert can see every signal. Per-metric alerts leave the tilt alert unable to know about the weight drop, and cause ranking degrades to "a tilt means tipped, bear or theft," which is a lookup with no correlation in it. Beat one stops being able to do the thing it exists for.

The per-yard budgeting demo survives. The bear scenario picks a hive or two neighbours, so two hives still produce two alerts, and issue 7 is about thirty hives on a bad day rather than one hive's four metrics.

**Severity is the worst signal in the incident.** The nine-cell table is unchanged and so are its nine tests.

Worst-wins has one real failure and it is worth stating. A quiet correlated failure like queen loss shows as brood temperature losing stability and sound variability rising, neither of them a large departure, so it scores medium when it needs the lid off. The seriousness lives in the combination and worst-wins cannot see combinations.

Raising severity when three or more metrics are involved would fix that and break something worse. Heat drives sound, brood temperature and humidity together, so a hot afternoon would climb toward critical. Telling "three signals because something is wrong" from "three signals because it is hot" needs the neighbouring hives, which is peer comparison, which is issue 9. Until that exists there is no safe version of the rule. Worst-wins fails toward a false negative, the breadth bump fails toward a false positive, and the false-positive policy exists because a wrong alert costs a hive opening. The queen-loss under-ranking goes in the README's shortcomings, pointing at issue 9.

**Severity is computed from the excursion as evaluated and does not drift afterwards.** In slice one the whole generated series exists at once, so the severity an alert carries is its final one. Re-evaluating an open alert as its excursion lengthens needs a live feed and belongs with the simulator, not here.

### The seed holds readings, so the evaluator has a production caller

The obvious shortcut is to seed `Alert` objects directly. It is also a trap: the evaluator, candidate-cause ranking and the whole severity table would then be a tested library that nothing calls until the simulator arrives in slice two. A reviewer opening the repository after PR 3 sees a centrepiece with no caller, which is the same reason weather and season were cut rather than stubbed.

So the seed holds readings and the repository runs the evaluator over them.

- **`seed_readings.dart` generates rather than stores.** A function takes explicit excursion specs, each naming a hive, a metric, a start time, a magnitude in sigma and a duration in readings, and produces the reading series around them. Nothing is a literal, so seven days of history at 15-minute cadence costs a loop rather than tens of thousands of lines.
- **Excursion specs keep the fixtures controllable.** Two specs with the same magnitude and duration on different hives produce the same severity at different raised-at times, which is what the Phase 6 manual check orders by raised-at. The Bloc test builds its own fixture, and it is the only place the id tie-break can be tested, because two alerts sharing one raised-at do not come out of a generator.
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

Ranked causes ride on `Alert` from Phase 4, because the repository ranks them there and a result with nowhere to go has no caller. The hive's recovering-until date is needed by the detail view in Phase 6; Phase 4 may add it or Phase 6 may, whichever reads better once the view exists. A signal is a metric and the sign of an anomaly's magnitude, derived from the anomaly and nothing else. `Alert` carries anomalies, cause ranking reads signals off them, and the pair is named in `candidate_causes.dart`, its only consumer.

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

**State this in PR 2's description.** It is an acceptance criterion of Phase 4, not a sentence in this plan, because the pull request is the one place a reviewer meets the shape without the reasoning attached.

### The domain directory is deliberately not shaped like a package

`app/lib/domain/` holds plain files. No `src/` subdirectory, no barrel export, despite the repository standard requiring both at a package boundary.

The domain is not a package boundary on day one. Slice two extracts it and times the extraction, and that number goes in the README as a pain point with evidence. Pre-shaping the directory now would move most of the extraction cost into this plan and leave slice two measuring a rename.

**The measurement needs a denominator.** Immediately before the extraction, slice two records what it is about to move: the domain file count and the number of import sites referencing it. Not in Phase 2, where nothing outside the domain imports it yet and the count would miss every site Phases 4 and 6 add. Without the denominator, slice two's number is a bare figure with nothing to read it against.

**State this in PR 2's description too**, for the same reason as the repository shape. A reviewer who meets both omissions without the reasoning will read the second in light of the first.

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
| `flutter_bloc` | Scaffolded in. `AlertInboxBloc`, `AlertDetailCubit`, `BlocProvider` in each Page |
| `equatable` | Added by hand at the start of Phase 2. Value equality on every domain type and every Bloc state |
| `go_router` | Added in Phase 6. The `alert/:id` route, so the deep-link shape exists before notifications would need it |
| `mocktail` | Scaffolded in. The repository mock in the Bloc test and in the Page test. Never `mockito` |
| `bloc_test` | Scaffolded in. `blocTest()` for the Bloc, `MockBloc` and `MockCubit` for the View tests |

Only `equatable` and `go_router` are pubspec edits. The template already ships `bloc`, `flutter_bloc`, `bloc_test`, `mocktail`, `bloc_lint` and `very_good_analysis`, verified against the CLI 1.5.0 bundle on Sep 13, 2026, so Phase 4 adds nothing. Check each against pub.dev on the day. The versions in `docs/original-plan.md` section 3 are a Sep 11 snapshot, not a pin.

`go_router` without `go_router_builder` leaves `alert/:id` stringly typed. That is consistent with keeping codegen out of slice one, and the cost is a route that fails at runtime rather than at compile time if a path is mistyped. Stated here rather than discovered.

### Environment and the MCP failure

Prerequisites are in `docs/original-plan.md` section 3 and are not restated here, because two copies of a dated table drift the moment either is touched. Verify against that section on the day.

One plan-specific fact: both the `dart` and `very-good-cli` MCP servers failed to connect on Sep 11, 2026 and connected on Sep 13, 2026 from a Conductor session, verified by running `very_good test` through the tool. If that regresses it blocks **every test run an agent makes**, not Phase 5 alone, because the plugin's hook stops raw `flutter test` in Bash: Phase 1's validation, Phase 5's gate and Phase 6's widget tests. The fix order is in section 3 of the build plan. Ten minutes, then run the gate by hand in a terminal and say so. The gate's additions are the deliverable and they do not care which process produced them.

**The MCP `test` tool has no `--collect-coverage-from` parameter**, so on its own it can only run the `imports` gate. `app/very_good.yaml` closes that: the CLI reads the file's `test` section as the default for every flag not passed on the command line, the MCP tool included, so a bare `very_good test` from any process is the full gate. So is a scoped one: `very_good test test/domain` reads the same file, collects coverage over every `lib/` file and fails the floor on a correct domain, and `--coverage` cannot be negated. The fast loop in Phases 2 to 4 is therefore `flutter test <path>` in a terminal. The explicit flags on the gate commands in this plan stay, because they agree with the file and a reader sees the gate without opening it.

## Implementation Phases

### Phase 1: Scaffold and repo setup

- **Status:** Done
- **Owner:** Split at the scaffold. Jamie types the scaffold and the rename, reads the tree, installs CodeRabbit in the browser, opens the pull request and runs the simulator. `/build` does the rest, read before accept. This is PR 1.
- **Scope:** Scaffold the Flutter app with Very Good CLI, rename the directory to `app/`, verify the generated tree, set the coverage exclusion in CI, install CodeRabbit.
- **Earns:** What a VGV scaffold contains and why: three flavors with their own entry points, `bootstrap.dart` with a `BlocObserver`, `context.l10n`, the mirrored `test/` tree with `pumpApp`, and the counter feature, which is the template's own worked example of a Page that provides and a View that consumes, a Cubit, and a widget test that mocks it. Also why a coverage gate can pass over a file it never measured.
- **Files touched:** `app/**` (generated), `app/very_good.yaml`, `.github/**` at the repository root, `.gitignore`, `README.md`
- **Detail:**
  - Phase 1 starts in the terminal. Jamie scaffolds, renames, deletes `app/LICENSE` and reads the tree, then invokes `/build` on this plan, which does the workflow move, the repointing, `.gitignore`, `very_good.yaml` and the README row against the tree that exists. Invoked first, `/build` would scaffold through the MCP `create` tool, unwatched, which is what the next bullet exists to avoid.
  - `very_good create flutter_app keeper` run in a terminal by hand so the output is watched, then `mv keeper app`. Plain `mv`, because nothing is tracked yet and `git mv` refuses an untracked path. The one argument sets both the directory and the Dart package name, so scaffolding directly as `app` would make every import read `package:app/...`, which says nothing in a public work sample. This way imports read `package:keeper/domain/evaluator.dart`. `--output-directory` does not remove the rename: it names a parent directory and still creates `keeper/` inside it, verified against the CLI source. Two flags are worth passing at scaffold time because changing them later is a multi-file edit: `--org-name` with something other than the default `com.example.verygoodcore`, since it becomes the iOS bundle identifier and the Android application id in every platform folder, and `--platforms=android,ios`, since the iOS Simulator and the Android emulator are the claim and the template otherwise generates macOS, web and Windows runners that nothing in this plan builds. Done Sep 13, 2026 with `--org-name engineer.jamiebrown --platforms android,ios`, on a second scaffold: the first was run without either flag from an older copy of this bullet and was replaced before PR 1 merged, while nothing depended on the platform folders.
  - The rename lands in the same commit as the scaffold, so history shows the intended shape rather than a move.
  - **Verify rather than trust**, and record what is actually there: three flavors with their own entry points, `bootstrap.dart` with a `BlocObserver`, localization wired with `context.l10n`, a mirrored `test/` tree, **`test/helpers/pump_app.dart` and `test/helpers/helpers.dart`**, `very_good_analysis` present, and a GitHub Actions workflow with coverage enforced. Anything missing is added by hand and noted.
  - **Read the tree before `/build` touches it**, in this order: `lib/bootstrap.dart`, `lib/main_development.dart`, `lib/app/view/app.dart`, `lib/counter/` with `test/counter/`, then `test/helpers/pump_app.dart`. The counter is the template's worked example of everything Phase 4 writes and Phase 6 asks an agent for: `CounterPage` creates the Cubit under `BlocProvider`, `CounterView` reads it with `context.read` in callbacks and `context.select` in `build`, and `counter_page_test.dart` declares a private `_MockCounterCubit extends MockCubit`, stubs `state`, and pumps the View under `BlocProvider.value` through `pumpApp`. `AppBlocObserver` in `bootstrap.dart` logs every state change to the console, which is the transition trail the Bloc-over-Cubit rule refers to, and it is worth watching during Phase 6's manual check. Phase 6 deletes the counter, so this is the only time it is there to read. Reading template output does not touch the cold claim, which is about who wrote the files.
  - **Move the workflow to the repository root.** The scaffold writes `.github/workflows/main.yaml` inside the package it generates, so after the rename it lands at `app/.github/workflows/`, alongside `license_check.yaml`, `dependabot.yaml`, `cspell.json` and `PULL_REQUEST_TEMPLATE.md`, which move with it. GitHub Actions only reads `.github/` at the repository root and will silently run nothing. Move it to the root and set the build job's `working_directory` input to `app`. The template's workflow triggers on `pull_request` to `main` and `push` to `main` only, verified against the bundle, so a branch push alone runs nothing. Confirm the `build`, `semantic-pull-request` and `spell-check` jobs appear when PR 1 opens, and read no jobs as the workflow being in the wrong place. Give the moved `PULL_REQUEST_TEMPLATE.md` a `## Read before accept` heading under `## Description`: `/create-pr` builds the body from that file, so every pull request gets a slot for the per-file paragraphs, PR 1 for what the scaffold actually contained and PR 2 for the two deviations.
  - **Two of the moved files still point at the old root**, verified against the template bundle and the `v1` reusable workflows on Sep 13, 2026. `dependabot.yaml` has the `pub` ecosystem at `directory: "/"`, which becomes `/app`; the `github-actions` entry stays at `/`. `license_check.yaml` needs `working_directory: app`, its two `paths` filters changed from `pubspec.yaml` to `app/pubspec.yaml`, and `flutter_version: "3.47.x"` added to match `main.yaml`, because the reusable license workflow runs plain `dart pub get` when no Flutter version is given and that cannot resolve a Flutter package. The spell-check job is covered below.
  - **The root `.gitignore` swallows two things the template means to commit.** It ignores `.idea/` and `.vscode/` at any depth, and git cannot re-include a file inside an ignored directory, so `app/.vscode/launch.json` and `app/.idea/runConfigurations/` never reach a commit even though the template's own `.gitignore` re-includes them. Anchor the root patterns to `/.idea/` and `/.vscode/` so the nested rules apply. The launch file carries the flavor run configurations and is worth keeping.
  - **The coverage settings live in two places that must agree: the CI workflow and `app/very_good.yaml`.** The generated workflow calls the `very_good_workflows` reusable Flutter workflow, whose inputs are `coverage_excludes`, `min_coverage`, `working_directory` and `collect_coverage_from`, confirmed against the `v1` workflow source on Sep 11, 2026. CI reads only those inputs, because the reusable workflow pins CLI 1.1.1, which predates the config file. Locally, CLI 1.4.0 and later read `very_good.yaml` from the package directory or any ancestor, and its `test` section supplies the default for every flag not passed on the command line. An earlier draft of this plan said no such file existed; it has since Aug 10, 2026. Write it with `coverage: true`, `min_coverage: "100"`, `collect_coverage_from: all` and the exclusion below, so a bare `very_good test` in `app/` is the gate for a fresh clone, for a terminal and for the MCP tool alike. Put the full command in the README's build instructions as well, so the gate is visible without opening the file.
  - **Coverage is collected from all files, not from imported files.** The workflow's `collect_coverage_from` input and the CLI's `--collect-coverage-from` flag both default to `imports`, verified Sep 11, 2026 against the workflow source and CLI 1.5.0. At that default a file in `lib/` that no test imports is absent from the denominator, so a gate can report 100 over a package it has not measured. Set the input to `all` and carry `--collect-coverage-from all` on every gate command in this plan and the README.
  - **Under `all`, the scaffold is red until four exclusions are in place.** Verified Sep 13, 2026 by scaffolding the template into a temporary directory and running the gate: the untouched template reports 27 percent, not 100. `all` mode appends every `lib/` file that has no coverage record as fully uncovered, and four kinds of file have none: `bootstrap.dart` and the three `main_*.dart` entry points, which no test loads, and the localization output under `lib/l10n/gen/`, whose `// coverage:ignore-file` header removes it from the record so `all` mode adds it straight back. The exclusion is therefore `**/*.g.dart **/l10n/gen/*.dart **/main_*.dart **/bootstrap.dart`, space separated, in both the workflow input and `very_good.yaml`. The CLI has split that list since 1.1.0, so the pinned CI version handles it. With it in place the untouched scaffold passes at 100, verified the same way. Excluding the entry points is stated in the README with its reason: they are device wiring, and a test that calls `runApp` inside the test binding would prove nothing about them. Slice one has no `.g.dart` at all, so that glob is set for the codegen slices two and four bring and does nothing yet.
  - **What else the template ships, verified against the CLI 1.5.0 bundle.** `analysis_options.yaml` includes `bloc_lint` recommended and CI runs `bloc lint`, so the hand-written Bloc in Phase 4 meets `avoid_public_bloc_methods`, `avoid_public_fields`, `avoid_flutter_imports`, `prefer_file_naming_conventions` and `prefer_void_public_cubit_methods` cold. The last one accepts `Future<void>`, so `AlertDetailCubit` in Phase 6 may await its fetch. The workflow has three jobs: `build`, `semantic-pull-request`, which requires a conventional-commit title on every pull request, and `spell-check` over every `.md` file with incremental mode off. Moved to the root, spell-check scans `docs/` and fails on the beekeeping vocabulary. An earlier draft set `working_directory: app`, but the reusable workflow passes that value as the cspell root and resolves its `config` input against it, so the job would look for `app/.github/cspell.json`, which no longer exists after the move. Keep the root and narrow `includes` to the root `README.md` and `app/**/*.md` instead. `docs/` goes unchecked and the README is checked by the job rather than by eye. Verified Sep 13, 2026: the root README passes cspell with the template dictionaries. Localization codegen writes to `lib/l10n/gen/` under a `// coverage:ignore-file` header the template puts there. That is the generated-code carve-out from the no-ignores rule, not a violation of it. It does not spare the directory an exclusion under `all`, see the bullet above. The template depends on `material_ui` and `App` imports it, so Phase 6's theme work starts from that package rather than adding one.
  - The MIT LICENSE landed with the plan refinement PR on Sep 12, 2026, after the repository had already been public without one for a day. The scaffold generates its own `LICENSE` inside `app/`; delete that copy so there is one at the root. Confirm `git config user.email` is the personal address before committing, because fixing it later means a history rewrite.
  - Install CodeRabbit. Free tier, and the repository is already public.
  - **Issues are not filed here.** The ten domain issues already have a paragraph each in `docs/original-plan.md` section 1, so redrafting them into a second document is copying rather than deciding. Four slice issues need one line each. Filing more than two issues for a single effort needs Jamie's approval before any are created, so this happens when he says go and it does not gate this phase.
- **Acceptance criteria:** `flutter run --flavor development --target lib/main_development.dart` launches the counter app on a simulator. The generated test suite passes. **The workflow sits at the repository root and its three jobs appear on PR 1.** **The four-glob exclusion and `collect_coverage_from: all` are present in that workflow and in `app/very_good.yaml`**, the workflow being the version that gates merges, and a bare `very_good test` in `app/` passes at 100 on the untouched scaffold. PR 1 merges green on the template's own tests.
- **Validation:** `test -d .github/workflows && ! test -d app/.github && grep -rq 'g.dart' .github/workflows/ && test -f app/very_good.yaml` proves the workflow move, the exclusion and the config file. Then `cd app && flutter analyze` and the unscoped coverage command. Then `manual` 1. Open PR 1 with `/create-pr` 2. Confirm the `build`, `semantic-pull-request` and `spell-check` jobs appear on the pull request, since a workflow in the wrong place fails silently and a branch push runs nothing either way 3. Confirm `flutter run --flavor development --target lib/main_development.dart` launches on a simulator

### Phase 2: False-positive policy and domain types

- **Status:** Not started
- **Owner:** **Jamie, by hand. No agent touches these files.**
- **Scope:** Write the false-positive policy as a document first, then the domain value classes with their unit tests.
- **Earns:** A false-positive policy defended one sentence per number, and the first Dart reps pointable by file. `Equatable`, because Dart classes are identity-equal by default, unlike a Swift struct, and a Bloc emitting an equal-but-not-`==` state rebuilds forever. Sealed classes with exhaustive `switch`, the closest Dart has to Swift enums with associated values. A record, two extension types, and a `const` constructor on every domain type, which the analyzer asks for on an `Equatable` class anyway and is the first meeting with `const` as a contract. Pure Dart tests that run in milliseconds without a widget.
- **Read first:** the eight decisions through the incident paragraphs, the `Alert` and anomaly shapes under State shape, and `docs/original-plan.md` section 2 for each type's fields. Where they differ this plan wins: the fifth metric is `tilt`, not motion, and nothing this plan cut or deferred is written.
- **Files touched:** `docs/false-positive-policy.md`, `app/pubspec.yaml` (adds `equatable`), `app/lib/domain/*.dart`, `app/test/domain/*_test.dart`
- **Detail:**
  - Phases 2 to 4 sit on one branch off `main` after PR 1 merges, and that branch becomes PR 2. Commit at the end of each phase at minimum, formatted with `dart format` and clean under `flutter analyze`, so the gate's diff in Phase 5 is test additions and not whitespace.
  - The policy is written before the evaluator and restates all eight decisions with the reasoning for each, **plus the per-metric sigma floor and the count-based window**, two rules the decisions implied but did not name. It must also state what a false negative costs against a false positive, because that is the first question the design invites. And it settles one thing the decisions table leaves open, because the flap test depends on it: whether the consecutive counter, before any alert is open, resets on the first reading back inside the 3.0 edge or keeps counting until a reading drops under the 2.5 clearing edge. Either is defensible in a sentence. Pick one and write it down, and do the same for which tier owns a reading at exactly 4.5 and exactly 6.0 sigma, because otherwise the tier function decides it and the document gets written to match.
  - Domain types: `Yard`, `Hive`, `HiveStatus`, `Metric`, `Reading`, `Anomaly`, `Alert`, `Severity`. Every class carries `Equatable`; enums and extension types have value equality already. Sealed classes or enums with exhaustive `switch` at the use site. `AlertStatus` is not written here: every slice-one alert is new and nothing moves it, so a sealed type with six variants and one constructor call is the `YardConditions` case again. It arrives in slice three with the triage that produces it. `Yard` is an id and a name; the layout and hive positions arrive with the yard screen in slice three. `EvaluationResult`, `Baseline` and `CandidateCause` are the exceptions and are written in Phase 3, in `evaluator.dart`, `baseline.dart` and `candidate_causes.dart`, because each only makes sense beside the code that computes it.
  - Dart on purpose, deliberately and pointably: a record for the anomaly's magnitude-and-duration pair, an extension type for `HiveId` and `AlertId`, sealed classes for `EvaluationResult` and every Bloc state with exhaustive `switch`. The destructuring `switch` over `EvaluationResult` in Phase 4's repository is the first pattern-matching rep and is pointable now; sealed `AlertStatus` and the triage switch are slice three's. No isolate. There is no honest use for one in this app and manufacturing one is worse than not having one.
- **Acceptance criteria:** Every class carrying `Equatable` has a test file asserting value equality and its own behaviour; enums and extension types get a test only where they carry behaviour. The policy document names all eight decided values plus the per-metric sigma floor and the window as a count, each with a reason, and states what a false negative costs against a false positive.
- **Validation:** `cd app && flutter test test/domain`, in a terminal. Fast loop, not the gate: any `very_good test` in `app/` reads `very_good.yaml` and is the full gate, scoped or not. See Phase 5. Commit when green.

### Phase 3: The baseline evaluator

- **Status:** Not started
- **Owner:** **Jamie, by hand. No agent touches these files.**
- **Scope:** The evaluator: a fold over one hive's readings for one metric, carrying its state from reading to reading, emitting an `EvaluationResult` per reading.
- **Earns:** A sealed `EvaluationResult` switched exhaustively, a stateful fold tested edge by edge and cell by cell against a written policy rather than against the code, and the first passing bear test.
- **Read first:** decisions 1 to 6, the bold paragraphs after the table through the sigma floor, the severity table, and the `EvaluationResult` block under State shape.
- **Files touched:** `app/lib/domain/evaluator.dart`, `app/lib/domain/baseline.dart`, `app/lib/domain/candidate_causes.dart`, `app/test/domain/evaluator_test.dart`, `app/test/domain/baseline_test.dart`, `app/test/domain/candidate_causes_test.dart`
- **Detail:**
  - The rolling window computes mean and standard deviation over the hive's own readings for that metric. Per hive, per metric. No peers, no calendar. Band at `k = 3.0` out and `k = 2.5` back, N of 3, cadence 15 minutes, minimum history half the window. Severity from the nine-cell table.
  - **The evaluator carries state across readings.** Three rules need it: the consecutive count for N, whether a run is open for hysteresis, and the previous timestamp for the gap rule. The shape of the carried state is Jamie's call at the keyboard. What this plan fixes is that there is one, and that an `EvaluationResult` comes out per reading.
  - Candidate cause ranking lives in `candidate_causes.dart` and **scores a set of signals, not one metric**. A signal is a metric and a direction, nothing else, because that is all the evaluator emits. Each cause declares the signals it predicts: bear predicts tilt, weight down and brood temperature down; swarm predicts weight down alone; robbing predicts weight down with sound up; queen loss predicts brood temperature down with sound up. **The score is matched signals over the union of predicted and observed**, so a cause is penalised for predicting what did not happen as well as rewarded for explaining what did. Recall alone cannot do this: on a lone weight drop, bear and swarm each explain one of one and tie, and the tie goes to list order. Under the union score a lone weight drop gives swarm 1 and bear one third. No season, no calendar-derived input anywhere in the domain.
  - This is what lets a bear outrank a swarm, and it is the whole reason incidents group across metrics. It is still a table and a comparison, not a model, and the code should not imply otherwise. The repository calls it when it promotes an incident, so it needs a file and a test of its own rather than hiding inside the evaluator.
  - **Its tests are the discrimination cases**, not coverage of the table: a tilt plus a weight drop ranks bear above swarm, a weight drop alone ranks swarm above bear, and brood temperature down with sound up ranks queen loss first. `docs/original-plan.md` describes queen loss as brood temperature losing stability and sound variability rising. Those are variance signals and a mean-band evaluator never emits one, so slice one expresses queen loss in level terms and the README's queen-loss shortcoming says so alongside the worst-wins point.
  - Tests cover the policy edges explicitly and by name: a value hovering at the band edge does not flap, `N - 1` consecutive breaches raise nothing, the Nth raises, a gap longer than twice the cadence resets the counter, a hive below the minimum sample count returns `InsufficientHistory` rather than `WithinBand`, **a metric whose window sigma is zero uses the floor rather than dividing by it**, **an anomalous reading does not enter the baseline the next reading is judged against**, **a long excursion does not drain the window into `InsufficientHistory`**, and severity for each of the nine cells.
- **Acceptance criteria:** Each named case in the detail list above exists as a test: band-edge flap, `N - 1` raises nothing, `N` raises, the gap reset, below minimum history, the zero-sigma floor, the contaminated-baseline case, the window drain, and all nine severity cells. Seventeen cases minimum. The cause-ranking test the success criteria call by name is `ranks bear above swarm when tilt accompanies the weight drop`, in `app/test/domain/`.
- **Validation:** `cd app && flutter test test/domain`, in a terminal. Fast loop, not the gate. Commit when green.

<details>
<summary><strong>Hints for Phase 3. Open only if stuck.</strong> The spec above is complete without them.</summary>

- The evaluator is a fold, not a pure function of one reading. Because the window holds only readings judged within the band, the baseline for reading `n + 1` depends on the verdict on reading `n`, so `baseline.dart` cannot be computed ahead of `evaluator.dart` and handed to it. One loop owns both. Readings judged `InsufficientHistory` enter the window unjudged, or it never fills.
- For the nine severity cells and the policy-edge tests, build the quiet series flat: every reading equal to the mean. Sigma is then exactly the metric's floor, a reading at the mean plus 3.75 floors is exactly 3.75 sigma, and each test states its cell in the spec's own units with nothing to argue with. Noise belongs to the seed generator in Phase 4, not to these tests.
- The zero-sigma floor test and the cell tests share that fixture. A flat series is a zero-sigma series.
- Under the union score ties happen: robbing and queen loss tie for second on the full bear. Rank ties by declaration order and let each test assert only the position it names.

</details>

### Phase 4: `AlertInboxBloc`, hand-written

- **Status:** Not started
- **Owner:** **Jamie, by hand. No agent touches these files.**
- **Scope:** The reading generator, the repository that evaluates it, and `AlertInboxBloc` with its `blocTest` cases. Committed before any gate runs. Ends the hand-written half of PR 2.
- **Earns:** The Bloc pattern from the inside: events in, states out, one handler where the logic lives, and `blocTest()` as the trail of that. `mocktail` on a concrete class. A repository that takes its dependency through the constructor and holds no Flutter import, as the one place arithmetic becomes a decision. Declarative fixtures, where a wrong alert is a wrong spec. The bear as one alert carrying four signals.
- **Read first:** State shape in full, decision 7 for the three sort keys, The seed holds readings, and The repository has no abstraction yet. Then the template's own examples, which PR 2 still carries: `app/test/counter/cubit/counter_cubit_test.dart` for the `blocTest` shape, `app/test/counter/view/counter_page_test.dart` for a private `MockCubit` with `late` and `setUp` inside a group, and `app/lib/counter/counter.dart` for the barrel. Then the plugin's `bloc` skill, its `references/testing.md` for the `blocTest` parameter table, and the `testing` skill. That reference's Bloc example puts `setUp` outside a group and names its mock without an underscore; the rules below win.
- **Files touched:** `app/lib/repositories/seed_readings.dart`, `app/lib/repositories/alert_repository.dart`, `app/lib/alert_inbox/bloc/*.dart`, `app/lib/alert_inbox/alert_inbox.dart`, `app/test/repositories/seed_readings_test.dart`, `app/test/repositories/alert_repository_test.dart`, `app/test/alert_inbox/bloc/alert_inbox_bloc_test.dart`
- **Detail:**
  - `seed_readings.dart` takes excursion specs, each naming a hive, a metric, a start time, a magnitude in sigma and a duration in readings, and generates the reading series around them. No literals. The quiet series is noise from a fixed-seed generator, so it is reproducible, and the evaluator's sample sigma over 672 readings lands within a few percent of the generator's, not on it. So **specs sit in the middle of a tier, never on an edge**: 3.75, 5.25 and 7.5 sigma for near, far and extreme, and 4, 8 and 14 readings for brief, sustained and prolonged. A spec at exactly 6.0 would land on either side of the tier line from run to run and the test that derives severity from the spec would flake. A flat noise-free baseline was considered, since it makes the floor the sigma and the arithmetic exact, and rejected because the same generator feeds the development flavor and a flat chart in slice two would look like the fake it is.
  - One concrete `AlertRepository` exposing `Future<List<Alert>> fetchAlerts()`. Phase 6 adds `Future<Alert?> fetchAlert(AlertId)` when `AlertDetailCubit` needs it, returning nullable so not-found travels as null rather than an exception. Writing it here instead is fine too. It is one method and the choice does not need making now. The load handler awaiting `fetchAlerts()` is the async rep: `Future` and `async`/`await` map one to one from Swift, isolates do not because there is no shared memory, and nothing here needs one.
  - The repository runs the evaluator from Phase 3 over the generated readings, **collapses consecutive anomalous readings into runs, then groups runs that are open at the same time on one hive into a single alert**, and ranks candidate causes against that alert's whole signal set. That is the one place the arithmetic-to-decision boundary is crossed, and it stands in for what the backend does in the real system. No interface. See the repository shape section for why, and state it in the PR description.
  - **Two repository tests pin the collapse**, because this is the easiest thing in the plan to get wrong and the hardest to notice. Ten alerts for one bear still looks like a working inbox, and so do four. One asserts a single metric's excursion yields one alert rather than one per reading. The other asserts a four-metric bear on one hive yields one alert carrying four signals, not four alerts.
  - Repositories hold no Flutter imports, take dependencies through the constructor, and never import another repository.
  - The seed: at least two yards, a handful of hives each, **two excursion specs with identical magnitude and duration on different hives**, which produce a severity tie at different raised-at times for the manual check, and **one hive with four overlapping specs across tilt, weight, brood temperature and sound**, which is the bear and the multi-metric collapse test.
  - **Seven days of quiet history before the first excursion**, per hive and per metric, so the window holds its full 672 in-band readings when the first excursion is judged and the sigma arithmetic above holds. Three and a half days is the minimum history, not the seed length: a hive with exactly 336 readings before its excursion is judged against a half-full window, and one with fewer is never judged at all. The below-minimum-history hive is the exception and gets fewer than 336 readings in total, so history length is a per-hive parameter on the generator.
  - **`HiveStatus.recovering` is seeded display state in slice one, not behaviour.** Suppressing evaluation for a recovering hive needs a recovery start date, and that date comes from a finding, and findings arrive in slice four. So the recovering hive here has an ordinary excursion in its readings, produces an ordinary alert, and the status rides along on that alert so the inbox has something to render. The relearning behaviour lands with the feedback edge that produces it, not before.
  - **The below-minimum-history hive renders nothing, by construction.** It has no baseline, so it raises no alerts and never appears in an alert list. It stays in the seed because it exercises the evaluator's suppression path end to end, and the assertion that it stays silent lives in the repository test, not in a widget test.
  - **A repository test asserts the evaluator actually ran**, meaning an alert's severity matches what the nine-cell table predicts for its excursion spec. Otherwise the chain is assumed rather than proven.
  - States and events per the state shape section. Sealed, `Equatable`, no `empty` variant.
  - **Ordering is applied when `AlertInboxLoaded` is constructed.** The state carries an ordered list. No widget sorts anything.
  - `blocTest()` for every transition. Never raw `test()` with manual stream assertions. Private mocks per file, underscore-prefixed. `setUp` and `tearDown` inside a group. Mutable objects are `late` and assigned in `setUp`. Test names read as sentences down the group hierarchy.
  - **Commit this phase before Phase 5 runs.** The commit boundary is the evidence.
- **Acceptance criteria:** `blocTest` cases cover load success, empty result, failure and the full three-key sort including the tie-break. **Five tests carry exact names, because success criteria call them by name:** `orders by severity then raised-at then id`, `derives severity from the excursion spec`, `raises nothing for a hive below the minimum history`, `collapses one excursion into one alert`, and `collapses a four-metric bear into one alert`. The commit exists before the first gate run, and Phases 2, 3 and 4 read `Done` in this file in that commit.
- **Validation:** `cd app && flutter test test/alert_inbox test/repositories`, in a terminal. Fast loop, not the gate. Commit when green.

<details>
<summary><strong>Hints for Phase 4. Open only if stuck.</strong> The spec above is complete without them.</summary>

- Add noise to the quiet series only. An excursion reading sits at exactly the mean plus the spec's magnitude times the metric's sigma, with no noise on it, so the run length is the spec's duration and the furthest reading is the spec's magnitude. The only slack left is the evaluator's sample sigma against the generator's, which the mid-tier values absorb.
- A spec's magnitude is in units of the sigma the evaluator will use for that metric, which is the larger of the floor and the quiet series' sigma. Give the generator the same floor rule, or keep every metric's quiet sigma above its floor. Otherwise a tilt spec at 7.5 quiet-sigmas can sit under the floor, never breach, and the bear loses its tilt.
- Magnitudes are signed and cause ranking reads the sign. The bear is tilt and sound up, weight and brood temperature down.
- The bear is four specs sharing one hive and one start time. Nothing else is needed for the runs to be open at the same time.
- If a fixture resists tuning for more than an hour, the risk table already allows seeding those alerts directly and keeping the chain live for the hive that demonstrates it.

</details>

### Phase 5: First green gate, and its additions

- **Status:** Not started
- **Owner:** Jamie runs the gate once by hand, then `/green-gate` loops. Jamie reads the diff. Not a `/build` phase. This is the second half of PR 2, in its own commits after the hand-written commits.
- **Scope:** Run the unscoped gate over the app package. The diff from the hand-written commit to the gate's last commit is the gate's additions.
- **Earns:** The gate as a tool rather than a score: what `all`-files coverage measures that `imports` does not, and how to read an agent's additions critically enough to reject one with a reason. This is the repository's answer to "how do you work with AI".
- **Files touched:** `app/test/**`, `app/lib/**` (formatting only), `README.md`
- **Detail:**
  - **This is the gate on hand-written code.** Phase 1 runs the same unscoped command against the generated scaffold, which passes there once the entry points and the localization output are excluded, see Phase 1. The scoped runs in Phases 2 to 4 use `flutter test`, which collects no coverage at all, so three phases can report green before the package has ever been measured. They cannot use `very_good test`: with `very_good.yaml` in place every `very_good test` in `app/` is the gate, scoped or not, because the file supplies coverage, the 100 floor and `all` mode, and `--coverage` cannot be negated. Without `all`, `--collect-coverage-from` defaults to `imports` and a file no test loads is absent from the denominator rather than failing it. That is why every gate command carries `--collect-coverage-from all`.
  - **Run the gate once in a terminal on the Phase 4 commit before any agent loops, and keep the output.** The coverage percentage and the uncovered lines it prints are the denominator for what the gate adds, and `/green-gate` overwrites `coverage/lcov.info` every round, so only this run shows what the hand-written tests covered. The test count and the percentage both go in the write-up.
  - **`/green-gate` passes its own `exclude_coverage`, and a passed flag beats the file.** Its default glob is `**/*.{g,freezed,gen}.dart` plus the l10n directories, which replaces the four-glob list rather than merging with it, so `bootstrap.dart` and the three `main_*.dart` return to the denominator at zero. Invoke it as `/green-gate app` with the four globs from `very_good.yaml` stated in the same message and the instruction that the entry points are excluded, not tested. A gate addition that tests `bootstrap.dart` or `main_*.dart` is the wrong glob, not a coverage gap, and is rejected on sight. The same applies when `/build`'s ship step delegates to the skill after Phase 6.
  - The MCP servers connected on Sep 13 and `very_good.yaml` makes a bare MCP `very_good test` the full gate; the skill's own call is not bare, see the bullet above. If the connection regresses, ten-minute timebox, then run by hand and say so.
  - **The commit shape is the evidence.** The gate does not commit its output. Commit it unedited as the gate's commit, then Jamie's rejections as one commit of his own after it, then run the gate once more so the head of PR 2 is green. The write-up's range reads hand-written, gate, kept. A rejection that removes coverage is replaced by a hand-written test in the same commit; a rejection that removes none, a redundant case or a test of the mock, is simply deleted. If closing coverage needs a change in `lib/` beyond formatting, the agent stops and Jamie makes it by hand.
  - The gate will extend and reshape the hand-written tests to close coverage. Read its additions through the read-before-accept lens under [Human and agent boundary](#human-and-agent-boundary); a gate-added test that compares states by identity or drops a `const` is a rejection, with that as the reason. Because Phase 4 is already committed, its additions are the diff between that commit and the gate's, and the write-up names the range by its position in PR 2, never by hash.
  - The write-up is three parts: what was written by hand, what the gate added, which additions were kept and why the rest were not. That is a better answer to "how do you work with AI" than any sentence about it.
  - Never weaken a gate to pass it. No deleted assertions, no `// coverage:ignore` on reachable code, no lowered floor without an issue explaining why.
- **Acceptance criteria:** The gate passes at 100% with generated code excluded. The write-up names at least one gate addition that was rejected, with the reason. Phase 5 reads `Done` in this file, set by hand. PR 2 opens after this phase is committed, not after Phase 4, because a pull request holding the hand-written commits alone is red. **Its description states the repository-shape and domain-directory deviations with their reasons**, under the template's `## Description` heading. PR 2 merged with all three reviewers run and its row added to the README comparison table.
- **Validation:** `cd app && very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart **/l10n/gen/*.dart **/main_*.dart **/bootstrap.dart' --collect-coverage-from all`

### Phase 6: The inbox screen, and slice one

- **Status:** Not started
- **Owner:** Agent-assisted, read before accept. This is PR 3.
- **Scope:** The inbox list, the detail Cubit and view, the router, localization, widget tests, and the removal of the generated counter feature.
- **Earns:** What `docs/original-plan.md` section 5 says slice one earns: keys and list identity, `BlocProvider` as the honest answer to "explain `InheritedWidget`", `const` as a contract, and the Bloc versus Cubit opinion with a reason from this repo rather than a blog, each pointing at a file. Plus a route by id, localization by default, severity that does not rely on colour, and widget tests that mock the Bloc through `pumpApp`.
- **Files touched:** `app/pubspec.yaml` (adds `go_router`), `app/lib/alert_inbox/view/*.dart`, `app/lib/alert_detail/cubit/*.dart`, `app/lib/alert_detail/view/*.dart`, `app/lib/alert_detail/alert_detail.dart`, `app/lib/app/view/*.dart`, `app/lib/app/router.dart`, `app/lib/app/app.dart`, `app/lib/l10n/arb/app_en.arb`, `app/test/app/view/app_test.dart` (rewritten, it asserts on `CounterPage`), `app/test/alert_inbox/view/*_test.dart`, `app/test/alert_detail/**/*_test.dart`, `app/test/helpers/pump_app.dart` (extend), **deletions:** `app/lib/counter/**`, `app/test/counter/**`, the counter's ARB entries, and `app/lib/l10n/arb/app_es.arb` with the `es` entry in `ios/Runner/Info.plist`, because an untranslated locale is template scaffolding
- **Detail:**
  - Page provides the Bloc or Cubit, View consumes it. No business logic in a widget. Exhaustive `switch` over the sealed state, so a new variant fails to compile rather than rendering nothing. This split is where `BlocProvider` becomes the answer to "explain `InheritedWidget`": when reading the generated Page and View, trace how `context.read<AlertInboxBloc>()` in the View finds the Bloc the Page provided, and put that in the file's paragraph.
  - The view **renders the list in the order the state carries**. No sorting in the widget. No search field. Search is slice four. The list is where keys and list identity are earned: the generated list either keys each row on the alert id or it does not, and the paragraph says which, and whether a key is needed at all when the state carries the order and the widget never reorders.
  - `AlertDetailCubit` calls `fetchAlert(id)` and maps a null return to `AlertDetailNotFound`. The widget never decides that. If Phase 4 did not write that method, write it here. The hand-written commit is already merged, so extending the repository now costs nothing that matters.
  - **Widget tests mock the Bloc, not the repository.** `class _MockAlertInboxBloc extends MockBloc<AlertInboxEvent, AlertInboxState> implements AlertInboxBloc {}`, stub `state` per case, pump the View under `BlocProvider.value`. The repository fake with `mocktail` is reserved for the one Page test asserting the Page builds the Bloc and dispatches its first event.
  - Extend the template's existing `pump_app.dart` with the repository provider, the router and Bloc provision. Import through the `helpers.dart` barrel. Do not create a second helper.
  - **Every new user-facing string goes through `context.l10n`.** The inbox title, the empty message, the failure message, the not-found message, the severity labels and the recovering-until line. No literals in widgets. Verifying localization in Phase 1 and then hardcoding here would be the worse of the two options, because a reviewer sees both.
  - **Severity is not conveyed by colour alone.** Colour alone fails WCAG 1.4.1. One text or icon cue per severity, and severity colours live in `ThemeData` or a `ThemeExtension`, not inline in the list item.
  - **Delete the generated counter feature.** Nothing half-finished ships in a public work sample, and its ARB key would outlive its only caller. It survives through PR 1 and PR 2 as the temporary home screen, which is fine and worth one line in PR 3's description. `test/app/view/app_test.dart` asserts on `CounterPage` and stops compiling the moment the directory goes, so it is rewritten against the inbox. The template's tests open with `// ignore_for_file: prefer_const_constructors`; the new tests do not inherit that header.
  - `const` is a contract here, not a style choice. A missing `const` is invisible and it is the most common defect in agent-written Flutter.
  - Every generated file is read before it is accepted, with one paragraph written on the decision it makes and whether that decision was right. Not a diff summary. If a file cannot be explained on demand it is rewritten by hand rather than patched. The lens is under [Human and agent boundary](#human-and-agent-boundary). The paragraphs go in PR 3's description under the `## Read before accept` heading, one per file, so the three reviewers read them beside the diff. `/build` runs its own review after this phase; see the pull requests section for how it counts.
  - The README gains its slice one line: what the slice earned and what it left open. Earned is the four items above, each pointing at a file in this repo; left open is the shortcomings in the documentation plan.
- **Acceptance criteria:** The app runs on the iOS Simulator, shows a sorted inbox from seeded data, and opens an alert. No template scaffolding remains. No user-facing string literal remains in a widget. The README comparison table has three rows. PR 3 merged.
- **Validation:** `manual` 1. `cd app && flutter run --flavor development --target lib/main_development.dart` 2. Confirm the inbox lists seeded alerts, most severe first 3. Confirm the two same-severity alerts order by raised-at, newest first 4. Tap the bear hive's alert, the one carrying four signals, and confirm bear ranks first among its candidate causes 5. Navigate to `alert/does-not-exist` and confirm the not-found view 6. Confirm the alert on the recovering hive shows its recovering-until line 7. Confirm severity carries a non-colour cue 8. Clone `Jamie-DB/keeper` into a temporary directory and run the README's build and gate commands from it, exactly as written, before PR 3 is marked ready

## Alternative Approaches Considered

**One pull request, or four.** The three review agents disagreed. The simplicity agent argued for one, on the grounds that the build plan says one pull request per slice. That rule is about slices, and the foundation is not one, so its premise does not reach this plan. The scope agent argued for four, separating the scaffold from the hand-written core and the gate from both. Three is the resolution, and the split moved once on the Sep 11 refinement pass: the scaffold is its own pull request because it is the only diff that merges green under the coverage floor before the gate has run, the hand-written core and the gate share a pull request with the boundary at a commit, and the screen is the third. The scope agent's point about isolating the gate is kept at commit granularity, because at pull request granularity it leaves the hand-written pull request unable to merge green.

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

The `verify:` lines and the `VERIFICATION COMMAND` are Jamie's, typed in a terminal. The plugin hook denies `flutter test` and `very_good test` to an agent's Bash and the MCP `test` tool cannot select a test by name, so when `/build` reports the command un-runnable the answer is to run it by hand and confirm, not to replace it. The agent's substitute is the `grep` half of each line plus the whole suite through the MCP tool.

```success-criteria
GOAL: Keeper runs on the iOS Simulator showing an alert inbox sorted by severity from seeded local data, on top of a hand-written domain and baseline evaluator that were committed with their tests before the first green gate ran.

SUCCESS CRITERIA:
- The app package analyzes clean and every test passes at 100% coverage with generated code excluded | verify: cd app && flutter analyze && very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart **/l10n/gen/*.dart **/main_*.dart **/bootstrap.dart' --collect-coverage-from all
- Formatting is clean across all hand-written and generated source, scoped so it cannot trip over build output | verify: dart format --output=none --set-exit-if-changed app/lib app/test
- The CI workflow sits at the repository root, where GitHub will actually read it, and carries the coverage exclusion | verify: test -d .github/workflows && ! test -d app/.github && grep -rq 'g.dart' .github/workflows/
- The false-positive policy document names all eight decided values plus the sigma floor and the window unit | verify: manual 1. Open docs/false-positive-policy.md 2. Confirm it names the minimum history, the band statistic, the window as a count of in-band readings, both hysteresis thresholds, the cadence, N, the gap rule, the sort order, the severity table and the per-metric sigma floor, each with a reason 3. Confirm it states what a false negative costs against a false positive
- No Flutter import appears anywhere in the domain or repository layers | verify: ! grep -rq "package:flutter" app/lib/domain/ app/lib/repositories/
- No weather or calendar leaked into the domain | verify: ! grep -rqE 'YardConditions|Season|Hemisphere|Weather' app/lib/domain/
- One excursion yields one alert, not one per anomalous reading | verify: grep -rqF 'collapses one excursion into one alert' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'collapses one excursion into one alert'
- A four-metric bear on one hive yields one alert carrying four signals, not four alerts | verify: grep -rqF 'collapses a four-metric bear into one alert' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'collapses a four-metric bear into one alert'
- Candidate causes discriminate rather than look up, proven by bear outranking swarm on the same weight drop | verify: grep -rqF 'ranks bear above swarm when tilt accompanies the weight drop' app/test/domain/ && cd app && flutter test test/domain --plain-name 'ranks bear above swarm when tilt accompanies the weight drop'
- The inbox sort is proven by its own named test | verify: grep -rqF 'orders by severity then raised-at then id' app/test/alert_inbox/ && cd app && flutter test test/alert_inbox --plain-name 'orders by severity then raised-at then id'
- The evaluator has a production caller, proven by a repository test asserting a generated excursion produces the severity the table predicts | verify: grep -rqF 'derives severity from the excursion spec' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'derives severity from the excursion spec'
- The below-minimum-history hive stays silent rather than reading as healthy | verify: grep -rqF 'raises nothing for a hive below the minimum history' app/test/repositories/ && cd app && flutter test test/repositories --plain-name 'raises nothing for a hive below the minimum history'
- No user-facing string literal remains in a widget | verify: manual 1. Open each file under app/lib/alert_inbox/view/ and app/lib/alert_detail/view/ 2. Confirm every displayed string resolves through context.l10n 3. Confirm app_en.arb holds the inbox title, the empty message, the failure message, the not-found message, the severity labels and the recovering-until line
- No search field exists in the inbox view | verify: ! grep -rq 'TextField' app/lib/alert_inbox/view/
- No template scaffolding remains | verify: ! test -d app/lib/counter && ! test -d app/test/counter
- The hand-written Bloc tests were committed before the first green gate run | verify: manual 1. Run `git log --oneline -- app/test/alert_inbox/bloc/alert_inbox_bloc_test.dart` 2. Confirm the first commit touching it predates the gate's first commit in PR 2
- The green gate write-up names at least one gate addition that was rejected, with the reason | verify: manual 1. Open the README section holding the write-up 2. Confirm it states what was hand-written, what the gate added, and which additions were rejected and why
- The app runs on the iOS Simulator, opens an alert, and handles an unknown id | verify: manual 1. `cd app && flutter run --flavor development --target lib/main_development.dart` 2. Confirm the inbox lists seeded alerts most severe first 3. Tap the bear hive's alert and confirm bear ranks first among its candidate causes 4. Navigate to alert/does-not-exist and confirm the not-found view
- The README comparison table has three rows, one per pull request, covering all three reviewers | verify: manual 1. Open the README 2. Confirm three rows naming what CodeRabbit, the flutter-reviewer subagent and /review each caught and missed on each diff
- The README's slice one line names the four things the slice earned, each pointing at a file | verify: manual 1. Open the README's slice one line 2. Confirm keys and list identity, BlocProvider as the InheritedWidget answer, const as a contract, and Bloc versus Cubit each name a file in this repo and a repo-specific reason, not a general one

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

VERIFICATION COMMAND: dart format --output=none --set-exit-if-changed app/lib app/test && test -d .github/workflows && ! test -d app/.github && grep -rq 'g.dart' .github/workflows/ && test -d app/lib/domain && test -d app/lib/repositories && ! grep -rq "package:flutter" app/lib/domain/ app/lib/repositories/ && ! grep -rq 'TextField' app/lib/alert_inbox/view/ && ! test -d app/lib/counter && ! test -d app/test/counter && ! grep -rqE 'YardConditions|Season|Hemisphere|Weather' app/lib/domain/ && grep -rqF 'orders by severity then raised-at then id' app/test/alert_inbox/ && grep -rqF 'derives severity from the excursion spec' app/test/repositories/ && grep -rqF 'raises nothing for a hive below the minimum history' app/test/repositories/ && grep -rqF 'collapses one excursion into one alert' app/test/repositories/ && grep -rqF 'collapses a four-metric bear into one alert' app/test/repositories/ && grep -rqF 'ranks bear above swarm when tilt accompanies the weight drop' app/test/domain/ && cd app && flutter analyze && flutter test test/alert_inbox --plain-name 'orders by severity then raised-at then id' && flutter test test/repositories --plain-name 'derives severity from the excursion spec' && flutter test test/repositories --plain-name 'raises nothing for a hive below the minimum history' && flutter test test/repositories --plain-name 'collapses one excursion into one alert' && flutter test test/repositories --plain-name 'collapses a four-metric bear into one alert' && flutter test test/domain --plain-name 'ranks bear above swarm when tilt accompanies the weight drop' && very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart **/l10n/gen/*.dart **/main_*.dart **/bootstrap.dart' --collect-coverage-from all
```

## Success Metrics

| Metric | Target | Where it is recorded |
|---|---|---|
| Coverage on the app package | 100%, generated code excluded | CI workflow |
| Hand-written test count and coverage percentage before the first gate run | Recorded, whatever they are, from the one terminal run on the Phase 4 commit | Green gate write-up |
| Gate additions kept against rejected | Both counts stated, with a reason for at least one rejection | Green gate write-up |
| Reviewer findings per pull request | Per reviewer, caught and missed, three rows | README comparison table |
| Domain file count and import sites immediately before the extraction | Recorded at the start of slice two, not earlier | The denominator for slice two's extraction timing |

The first three exist to keep the wall-clock number honest. A generation time only ever appears alongside its verification cost.

## Dependencies & Prerequisites

**Ready:** Dart 3.13.2 via Flutter 3.47.2, `jq` 1.7.1, Very Good CLI 1.5.0, `~/.pub-cache/bin` on PATH, both plugins at 0.0.5, the repository public at `Jamie-DB/keeper`. Verify against `docs/original-plan.md` section 3 on the day. A version there is a snapshot.

| Item | State | Blocks |
|---|---|---|
| `dart` and `very-good-cli` MCP servers | Connected, verified Sep 13 after failing Sep 11 | Nothing while it holds. If it regresses, any agent-run test in Phases 1, 5 and 6, and the workaround is running the gate by hand |
| Approval to file the fourteen issues | Not given | Nothing. Issue filing no longer gates Phase 1 |
| CodeRabbit installation | Not done | The comparison table's first row, in PR 1 |
| Sign-off on the eight decisions | Given, Sep 11 | Nothing. Settled |
| `very_good_workflows` input names | Confirmed Sep 11: `coverage_excludes`, `min_coverage`, `working_directory`, `collect_coverage_from` | Nothing |

## Risk Analysis & Mitigation

| Risk | Consequence | Mitigation |
|---|---|---|
| **The gate runs before Phase 4 is committed** | The hand-written evidence is destroyed permanently and cannot be reconstructed | Phase 4's acceptance criterion is the commit itself, and the gate's commits sit after it in PR 2 |
| **An agent writes any part of Phases 2 to 4 before Jamie does** | Same. The central claim of the repository stops being true, and unlike a later edit this one cannot be undone | The `**Status:**` lines, which are what `/build` actually reads, set to `Done` in each phase's commit; the commit-yourself answer, which stops `/build` after every phase; and the banner. Edits after the Phase 4 commit are ordinary work and carry no risk here |
| **A scoped test run is mistaken for the gate** | Three phases report green at 100% before the package has been measured, and the real gate fails late | Phases 2 to 4 run `flutter test`, which measures nothing, and label it "fast loop, not the gate". Any `very_good test` in `app/` is the gate |
| **The evaluator's numbers get picked to make tests pass** | The policy becomes decoration and does not survive one follow-up question | The policy document is written before the evaluator and each number carries its reason. The tests are written against the document |
| **Slice one grows** | Nine days, and slice four is the part that cannot be cut | The non-goals list is the scope boundary. Anything not on it that arrives during Phase 6 becomes an issue |
| **The reading generator eats Phase 4** | It is the one piece of new invention in an otherwise specified phase, and tuning it until the right alerts come out is open-ended | Excursion specs are declarative, so a wrong alert is a wrong spec rather than a generator bug. If tuning passes an hour, seed the alerts directly for the fixtures that resist it and keep the chain live for the one hive that demonstrates it |
| **The generated scaffold differs from what the plan assumes** | Silent gap discovered later | Phase 1 verifies a named list, `pump_app.dart` among them, rather than trusting this plan |
| **The MCP connection regresses** | `/green-gate` cannot run | Ten-minute timebox, then run the gate by hand. The additions are the deliverable and they do not care which process produced them |
| **CodeRabbit produces little on a young repository** | The three-row comparison is thin | Stated in the README as what happened. Two reviewers with real findings is a better artifact than three where one is padding. This is the brainstorm's open question and it resolves when the findings exist |

## Future Considerations

Slice two records the denominator, extracts `packages/hive_domain/` and times it, introduces the data layer with a second repository implementation and times that too, then builds the simulator's GraphQL read side with a hand-rolled `shelf` handler and a hand-written `schema.graphql`.

The sync contract's eight decisions are written before slice three, because decision 1 puts a client-minted id on every `TriageAction` and that type is written in slice three. `TriageAction` carries its id from the moment the type is first written. Retrofitting ids onto a type with call sites and tests is the avoidable version of that work.

Slice four puts the debounced `restartable` search on `AlertInboxBloc`, which is the reason it is a Bloc rather than a Cubit.

## Documentation Plan

| Document | Change | Phase |
|---|---|---|
| `docs/false-positive-policy.md` | New. The evaluator's specification, all eight decisions plus the sigma floor, each with a reason | 2 |
| `README.md` | Comparison table row for PR 1, the gate command, and the entry-point exclusion with its reason | 1 |
| `README.md` | The green gate write-up, the repository-shape and domain-directory deviations, comparison table row for PR 2 | 5 |
| `README.md` | Slice one line naming the four earned items with a file each. The shortcomings the plan promises, each pointing at its issue: cause ranking's missing season key; queen loss under-ranked twice over, by worst-wins severity and by an evaluator that emits level signals when variance is what marks it; `AlertInboxLoadFailure` reachable only through a mock; Bloc on the inbox chosen against slice four rather than slice one; `alert/:id` failing at runtime rather than compile time; and whatever CodeRabbit produced. The workflow section's note on where `/build` stopping at Phase 1 and resuming at Phase 6 helped and where it was ceremony. A What's next section pointing at the filed issues, which means the fourteen are filed on Jamie's go before PR 3 opens, or at `docs/original-plan.md` section 1 by number if not. The stub notice out. Comparison table row for PR 3. Build instructions with the full gate command, tested from a fresh clone | 6 |
| `BUILDLOG.md` | Not written in this plan. Its first entries are the three pull requests here and the reversals already recorded in the alternatives section. Drafted from git history after PR 3 merges, per `docs/repo-standards.md`, and edited by Jamie for truth | after 6 |
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

- Merged: Jamie-DB/keeper#1, day one setup and brainstorm; Jamie-DB/keeper#2, this plan; Jamie-DB/keeper#3, its refinement from the data-path audit
- Issues: none filed yet. Ten have a paragraph each in `docs/original-plan.md` section 1, four slice issues need one line each, all held for approval
