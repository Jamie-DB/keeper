# VGV Code Review: keeper-status-bootstrap vs origin/main

> _Report as delivered Sep 13, 2026. Not maintained against later code; dispositions are in the README comparison row. See the caveat in [`../review.md`](../review.md)._

Branch: `keeper-status-bootstrap` (PR 6). Scope: root CI and config files, `app/` non-platform files, README, CLAUDE.md, the plan. Platform directories excluded per the task. The counter feature's existence is out of scope by instruction.

## Summary

The scaffold is clean and the CI move is correct. Every reusable-workflow input the branch uses exists in the `v1` source (`collect_coverage_from`, `coverage_excludes`, `includes`, `skip_packages`), the analyzer and formatter pass locally, and all three jobs plus the license check are green on PR 6. CLAUDE.md, `very_good.yaml`, the CI workflow, and the README carry the same four-glob exclusion, so the gate is consistent across its four homes. What blocks a clean accept is plan fidelity, not code: the plan tells the scaffold to pass a non-default `--org-name` and `--platforms=android,ios`, the tree shows neither was passed, and the plan is marked Done with only the spell-check deviation recorded. The README also understates the gate. Needs work, none of it in Dart.

## Critical: Must Fix Before Merge

None.

## Important: Should Fix

- **docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:277, app/android/app/build.gradle.kts:17, app/ios/Runner.xcodeproj/project.pbxproj:401** — The scaffold kept the default org. Namespace and bundle identifier are `com.example.verygoodcore.keeper`. The plan says to pass `--org-name` at scaffold time "because changing it later is a multi-file edit", and neither the plan's Phase 1 bullet nor the PR body records the deviation (the PR body says "nothing missing, nothing added by hand").
  - Why: Learned rule 1 makes the plan the authority and requires every override to carry its reason; the CLAUDE.md hard rule says an undone item is an open issue, not a silence. Right now it is a silence, and a `com.example` identifier ships in a public work sample.
  - Fix: Either rescaffold with `--org-name` before merge (nothing depends on the platform folders yet, so this is the cheap moment) or record the override in the Phase 1 bullet with the reason and open an issue for the rename.

- **docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:277, app/macos, app/web, app/windows** — The scaffold generated macOS, web, and Windows (62 tracked files). The plan says `--platforms=android,ios`, "since the iOS Simulator and the Android emulator are the claim and the template otherwise generates macOS, web and Windows runners that nothing in this plan builds." Same silence as above. The `.coderabbit.yaml` exclusion list exists partly to hide these, and the working tree already shows uncommitted Xcode churn under `app/macos/`.
  - Why: Every tracked file is a liability; these are 62 that nothing builds, they inflate every PR toward CodeRabbit's file limit, and they drift whenever a Flutter tool touches them.
  - Fix: Delete `app/macos`, `app/web`, `app/windows` and their `.metadata` entries, or record the override with its reason in the plan. Deleting matches the plan; keeping needs the reason written down.

- **README.md:32** — "The gate, which CI runs on every pull request" lists `flutter analyze` and the coverage command. The build job also runs `dart format --set-exit-if-changed` and `bloc lint .` (`run_bloc_lint: true`), confirmed in the `flutter_package.yml@v1` source at lines 136 and 145. The PR body itself reports "format clean, bloc lint clean", so the author knows the gate has four steps.
  - Why: The README is the fresh-clone contract. A contributor who runs the two listed commands can still fail CI on format or bloc lint, and the CLAUDE.md hard rule requires README claims to be exact.
  - Fix: Add `dart format --set-exit-if-changed lib test` and `bloc lint .` to the block, or state that CI runs those two on top.

- **app/.gitignore** — Uncommitted working-tree edit adds `.build/` and `.swiftpm/` (the Flutter tool writes these when it regenerates the macOS runner). The PR's version lacks them, so the file on disk and the file under review differ.
  - Why: A dirty tree at review time means the next `flutter run` on macOS re-dirties the branch, and the reviewed `.gitignore` is not the one that will be committed.
  - Fix: Commit the two lines or discard them together with the `app/macos` changes. If the platforms finding above resolves by deletion, discard.

## Suggestions: Nice to Have

- **README.md:20** — The stub paragraph promises "build instructions verified from a fresh clone, once there is something to run", then the next heading is "Build and run ... From a fresh clone".
  - Suggestion: Drop "including ... build instructions verified from a fresh clone" from the stub sentence, or reword it to say the full treatment adds shortcomings and a walkthrough.

- **.github/workflows/license_check.yaml:11-19** — `paths` filters trigger on `app/pubspec.yaml` only. A transitive dependency change lands in `app/pubspec.lock` with no `pubspec.yaml` edit, and the check that flagged `pubspec_lock_parse` on this very PR would not run for it.
  - Suggestion: Add `app/pubspec.lock` to both `paths` lists.

- **.github/workflows/main.yaml:35-37** — `includes` lists `app/**/*.md`, which matches nothing (no `.md` is tracked under `app/`). Slice two adds `packages/hive_domain/`, whose README will also be unchecked.
  - Suggestion: Replace with `packages/**/*.md` when the domain package lands, or drop the dead glob now and add the real one then.

- **app/pubspec.yaml:2** — `description: A Very Good Project created by Very Good CLI.`
  - Suggestion: One line from the README's first paragraph. `flutter pub` surfaces this string and it is the only template placeholder left in a hand-edited file.

## Notes that are not findings

- All reusable-workflow inputs verified against the `v1` sources fetched Sep 13, 2026: `flutter_package.yml` declares `collect_coverage_from`, `coverage_excludes`, `min_coverage`, `run_bloc_lint`, `working_directory`; `spell_check.yml` declares `includes`, `modified_files_only`, `working_directory` and resolves `config` against `working_directory`, which validates the plan's spell-check reasoning; `license_check.yml` declares `skip_packages` and `allowed`.
- The workflow pins `very_good_cli 1.1.1` and emits `--collect-coverage-from all` from the input, and PR 6's build job passed with it, so the pinned CLI accepts the flag.
- CLAUDE.md line 32 already carries the four-glob exclusion; earlier drafts had one glob, so no drift there.
- `.gitignore` anchoring to `/.idea/` and `/.vscode/` is correct and the launch configs are tracked as intended.
- Template Dart and tests match the project's own testing rules where they survive the counter removal: `pump_app.dart` and `helpers.dart` follow the shared-helper rule, `app_test.dart` pumps `App` itself rather than an inline `MaterialApp`. Counter tests use a private `_MockCounterCubit`, `late` in `setUp`, `blocTest`, and `pumpApp`. No deletions against `origin/main`, no dependency removed, no test weakened.
- `dart format --set-exit-if-changed` and `flutter analyze` pass locally on `app/lib` and `app/test`.

## Simplicity Assessment

- Lines that could be removed: roughly 62 files under `app/macos`, `app/web`, `app/windows` if the plan's platform choice is honoured; one dead spell-check glob.
- Unnecessary abstractions: none in the hand-edited files.
- YAGNI violations: the three unbuilt platform runners.
- Complexity verdict: Minor tweaks needed.

## Testing Assessment

- New code with tests: none of the hand-edited files are code; the template's Dart is covered and the gate passes at 100 with the four exclusions.
- Test quality: template-grade, meaningful for what it covers; removed in PR 3.
- State management test coverage: Complete for `CounterCubit` (template).
- UI component test coverage: Complete for `App`, `CounterPage`, `CounterView` (template).
