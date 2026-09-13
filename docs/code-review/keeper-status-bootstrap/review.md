# Code Review — keeper-status-bootstrap

10 findings · 🔴 0 critical · 🟡 5 important · 🔵 5 suggestions
Across 38 files (platform directories excluded). Agents: vgv-review-agent, architecture-review-agent, test-quality-review-agent, code-simplicity-review-agent. All four completed.

## Findings Index

| ID | Severity | Rule | Location | Finding |
|----|----------|------|----------|---------|
| FINDING-01 | 🟡 Important | `vgv/readme-gate-incomplete` | `README.md:32` | List every CI gate step in the README |
| FINDING-02 | 🟡 Important | `vgv/dirty-working-tree` | `app/.gitignore` | Commit or discard the uncommitted app/.gitignore edit |
| FINDING-03 | 🟡 Important | `architecture/coverage-exclusion-broader-than-stated-reason` | `app/very_good.yaml:11` | Narrow the bootstrap.dart exclusion or write down why AppBlocObserver is unmeasured |
| FINDING-04 | 🟡 Important | `vgv/plan-override-unrecorded` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:277` | Record or reverse the default org name the scaffold kept |
| FINDING-05 | 🟡 Important | `vgv/plan-override-unrecorded` | `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:277` | Drop or justify the macOS, web, and Windows runners the plan excluded |
| FINDING-06 | 🔵 Suggestion | `vgv/workflow-path-filter-gap` | `.github/workflows/license_check.yaml:11` | Trigger the license check on lockfile changes |
| FINDING-07 | 🔵 Suggestion | `architecture/single-package-ci-gate` | `.github/workflows/main.yaml:22` | Put packages/ CI, license and dependabot coverage on slice two's checklist |
| FINDING-08 | 🔵 Suggestion | `vgv/dead-config-glob` | `.github/workflows/main.yaml:35` | Replace the spell-check glob that matches nothing |
| FINDING-09 | 🔵 Suggestion | `vgv/readme-self-contradiction` | `README.md:20` | Reconcile the stub paragraph with the Build and run section |
| FINDING-10 | 🔵 Suggestion | `vgv/template-placeholder-left` | `app/pubspec.yaml:2` | Replace the template pubspec description |

## Important

### FINDING-01 · `vgv/readme-gate-incomplete` · `README.md:32`
List every CI gate step in the README.
- **Why**: CI also runs `dart format --set-exit-if-changed` and `bloc lint .` before the test, so a contributor who runs the two listed commands can still fail CI.
- **Fix**: Add `dart format --set-exit-if-changed lib test` and `bloc lint .` to the gate block.
- **Reported by**: vgv-review-agent, architecture-review-agent · [details](raw/vgv-review.md) · [details](raw/architecture-review.md)

### FINDING-02 · `vgv/dirty-working-tree` · `app/.gitignore`
Commit or discard the uncommitted app/.gitignore edit.
- **Why**: The tree on disk adds `.build/` and `.swiftpm/` (plus a macOS Xcode project migration) that the branch lacks, so the reviewed file is not the one that will be pushed and the branch re-dirties on the next macOS run.
- **Fix**: Commit the edits with the macOS changes, or discard both if the macOS directory is deleted.
- **Reported by**: vgv-review-agent, architecture-review-agent · [details](raw/vgv-review.md) · [details](raw/architecture-review.md)

### FINDING-03 · `architecture/coverage-exclusion-broader-than-stated-reason` · `app/very_good.yaml:11`
Narrow the bootstrap.dart exclusion or write down why AppBlocObserver is unmeasured.
- **Why**: The README justifies excluding entry points as untestable `runApp` wiring, but the glob also drops `AppBlocObserver` (`app/lib/bootstrap.dart:7-21`), plain Dart a unit test measures, from the denominator with no stated reason.
- **Fix**: Move `AppBlocObserver` to its own file with a test so `**/bootstrap.dart` covers only `bootstrap()`, or add one README sentence stating the observer is deliberately unmeasured and why.
- **Reported by**: architecture-review-agent · [details](raw/architecture-review.md)

### FINDING-04 · `vgv/plan-override-unrecorded` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:277`
Record or reverse the default org name the scaffold kept.
- **Why**: The plan says pass `--org-name` at scaffold time because changing it later is a multi-file edit; the tree carries `com.example.verygoodcore.keeper` and neither the plan's Done bullet nor the PR body records the deviation.
- **Fix**: Rescaffold with `--org-name` now while nothing depends on the platform folders, or write the override and its reason into the Phase 1 bullet and open an issue for the rename.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)

### FINDING-05 · `vgv/plan-override-unrecorded` · `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:277`
Drop or justify the macOS, web, and Windows runners the plan excluded.
- **Why**: The plan says `--platforms=android,ios` because nothing builds the other runners; 62 tracked files exist that nothing builds, they push every PR toward CodeRabbit's file limit, and the macOS runner is already dirtying the working tree.
- **Fix**: Delete `app/macos`, `app/web`, `app/windows` and their `.metadata` entries, or record the override with its reason in the plan.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)

## Suggestions

### FINDING-06 · `vgv/workflow-path-filter-gap` · `.github/workflows/license_check.yaml:11`
Trigger the license check on lockfile changes.
- **Why**: A transitive dependency change lands in `app/pubspec.lock` with no `pubspec.yaml` edit, so the check that caught `pubspec_lock_parse` on this PR would not run for it.
- **Fix**: Add `app/pubspec.lock` to both `paths` lists.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)

### FINDING-07 · `architecture/single-package-ci-gate` · `.github/workflows/main.yaml:22`
Put packages/ CI, license and dependabot coverage on slice two's checklist.
- **Why**: `main.yaml`, `license_check.yaml` paths and dependabot all point at `app/` only, and the plan extracts `packages/hive_domain/` in slice two with no CI change listed, so the shared evaluator would ship without a CI gate.
- **Fix**: Add to slice two's checklist a build job or matrix over `packages/*`, `packages/*/pubspec.yaml` in the license paths, and a dependabot entry per package.
- **Reported by**: architecture-review-agent · [details](raw/architecture-review.md)

### FINDING-08 · `vgv/dead-config-glob` · `.github/workflows/main.yaml:35`
Replace the spell-check glob that matches nothing.
- **Why**: No `.md` is tracked under `app/`, and the domain package arriving in slice two lives under `packages/`, which the glob does not cover.
- **Fix**: Drop `app/**/*.md` now and add `packages/**/*.md` when `packages/hive_domain/` lands.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)

### FINDING-09 · `vgv/readme-self-contradiction` · `README.md:20`
Reconcile the stub paragraph with the Build and run section.
- **Why**: Line 20 promises build instructions "once there is something to run" and line 22 provides them from a fresh clone.
- **Fix**: Remove "build instructions verified from a fresh clone" from the stub sentence or reword it to promise shortcomings and a walkthrough.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)

### FINDING-10 · `vgv/template-placeholder-left` · `app/pubspec.yaml:2`
Replace the template pubspec description.
- **Why**: "A Very Good Project created by Very Good CLI." is the last template placeholder in a hand-edited file and `flutter pub` surfaces it.
- **Fix**: Use one line from the README's opening paragraph.
- **Reported by**: vgv-review-agent · [details](raw/vgv-review.md)

## Why this matters

Nothing here is a bug. The set is about the PR's own claims: the README describes a gate CI does not quite run, the coverage exclusion is wider than its stated reason, and the scaffold was run without two flags the plan asked for. Fixing those now, while nothing depends on the platform folders, is cheap; the same edits after slice two touch every platform file and every bundle identifier.
