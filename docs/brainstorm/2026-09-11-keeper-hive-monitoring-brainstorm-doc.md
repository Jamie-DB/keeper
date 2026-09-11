---
date: 2026-09-11
topic: keeper-hive-monitoring
---

# Keeper: hive monitoring and field work

## What We're Building

Keeper is a monitoring and field-work app for a beekeeping operation. Battery-powered sensors on hives report weight, brood temperature, humidity, sound and tilt on a schedule through a yard gateway. A backend scores each reading against a baseline for that specific hive and that specific metric, and a departure raises an alert. The beekeeper triages the alert and schedules it into the next yard visit.

It is a user-facing application that helps its user identify, locate and fix a problem. It is not a dashboard. The pitch is inspect when it matters, not on a schedule. Sensors cannot replace inspections for disease, mite counts or brood pattern, so the honest claim is fewer and better-timed openings rather than none.

Full specification is in `docs/build-plan.md`. This document records only what the specification left open or what circumstances changed. The binding constraint is the stopping rule: the repository must be showable by Sun Sep 20, 2026, meaning it runs, the README is honest, the issues are filed, and slice four exists in some form.

## Why This Approach

The specification is already three iterations deep and most architectural questions are settled in it: four Very Good Ventures layers, Bloc over Cubit where the transition trail earns it, a hand-written domain and evaluator before any agent touches the repository, and four slices ending in an offline outbox. Re-opening those would be ceremony.

What remained open were five decisions, recorded below. The through-line in all of them is the same: protect the two things that carry the project, which are the hand-written evaluator and slice four's outbox, and spend risk budget nowhere else.

## Key Decisions

- **The repository is public.** Flipped Sep 11 while the tree was still empty, which was the moment with nothing to leak. CodeRabbit's free tier requires public, and CodeRabbit is one of the three reviewers whose comparison table is a stated deliverable. The placeholder repository description is outward-facing surface and needs a real one before anyone reads the repo.

- **Scaffold as `keeper`, then rename the directory to `app` before the first commit.** `very_good create flutter_app <name>` uses that one argument for both the directory it creates and the Dart package name in `pubspec.yaml`. Scaffolding directly as `app` would make every import read `package:app/...`, which is a poor name in a public work sample and says nothing about what the package is. Scaffolding as `keeper` and moving the directory gives the planned layout with imports that read `package:keeper/domain/evaluator.dart`. The rename happens before the first commit so history shows the intended shape from the start rather than a move.

- **`app/` is a directory on day one, not yet a pub workspace.** No root `pubspec.yaml` and no path dependencies until slice two, so day one holds to one package with the domain inside `app/lib/` as the specification requires. The reason for the directory now rather than later is measurement. Slice two times the extraction of `packages/hive_domain/` and writes the number into the README as a pain point with evidence behind it. A flat layout would force a repository-wide move into that same commit, and the recorded number would stop being the cost of extracting a package.

- **The simulator's GraphQL server is hand-rolled from the start.** The specification allowed a sixty-minute timer on `angel3_graphql` then `leto_shelf` before falling back. The timer is skipped. A `shelf` handler that reads the operation name from the POST body and returns seeded shapes passes every client test, and the client side carries the transferable skill either way. This removes the project's riskiest dependency from the critical path of slice two. `schema.graphql` is still written by hand first, and the client's codegen still points at the local file rather than an introspection endpoint. The README states plainly that the simulator's GraphQL server is a stub rather than a real engine.

- **The first evaluator uses the hive's own rolling window only.** Seven to fourteen days per hive per metric, plus the three-part false-positive policy: N consecutive readings outside the band, hysteresis at the band edge, and severity scaling with both magnitude and duration. Peer comparison against yard neighbours is genuinely better and stays issue 9. `YardConditions` remains an optional parameter on the evaluator signature from the first version, because adding it later means touching every call site and every test.

- **Scenario variety outranks the rain demo, and the cut order changes to match.** A demo needs several things that can happen to a hive, not one. Bear ships first because it exercises the most: correlated signals across metrics in the right order, which is what makes bear outrank swarm in the candidate causes. Swarm, robbing and queen loss are cheap once bear exists and they are what make the candidate-cause ranking visible as more than a lookup table. The rain demo is a stretch goal, first to be cut, because without peer comparison it is the only thing answering the weather confounder but it demonstrates the evaluator holding fire rather than acting. The specification's cut order listed scenario scripts ahead of the rain demo. That is reversed here.

- **Inbox search moves to slice four, and that is where `restartable` earns its place.** `restartable` cancels an in-flight event handler when a new event of the same type arrives. Typing "hive" fires a search on each keystroke, and without it the results for "hi" can arrive after the results for "hive" and overwrite them with stale output. Slice one reads seeded data from memory, so a search there returns instantly and cancellation has nothing to cancel. Putting it in slice one would be a transformer chosen to have chosen one. Slice four reads the inbox from the Drift cache with a real asynchronous query, so a debounced search with `restartable` is justified by the code rather than by the resume. Slice one ships sort by severity and open one, with no search field. `sequential` on the outbox in slice four is unchanged and was never in question.

- **Repository name is `keeper`.** Recorded, since nothing downstream could start without it.

## Open Questions

- What the reviewer comparison table looks like if CodeRabbit produces little on a nine-day repository. Two reviewers with real findings may be a better artifact than three where one is thin. That is a judgment to make when the findings exist rather than now.
