# Code Simplicity Review — keeper-status-bootstrap vs origin/main

> _Report as delivered Sep 13, 2026. Not maintained against later code; dispositions are in the README comparison row. See the caveat in [`../review.md`](../review.md)._

## Core Purpose
This branch bootstraps the repository's tooling: a Very Good CLI Flutter scaffold under `app/`, CI workflows (build, license check, spell check, dependabot), CodeRabbit configuration, and a status update to the foundation plan document. It is infrastructure, not application logic.

## Scope note
Per the task, platform directories (`app/ios`, `app/android`, `app/macos`, `app/windows`, `app/linux`, `app/web`) were excluded. All files under `app/lib`, `app/test`, `app/pubspec.yaml`, `app/analysis_options.yaml`, `app/l10n.yaml` were checked against a stock `very_good create flutter_app` 1.5.0 output and confirmed byte-for-byte scaffold — no hand edits. The counter feature's existence is explicitly out of scope per CLAUDE.md (a later PR removes it).

The only hand-authored surface is: `.coderabbit.yaml`, `.gitignore`, `CLAUDE.md` (rules 5 and 6 appended), `README.md`, `app/very_good.yaml`, `.github/workflows/main.yaml`, `.github/workflows/license_check.yaml`, `.github/dependabot.yaml`, `.github/cspell.json`, `.github/PULL_REQUEST_TEMPLATE.md`, and a two-line status/spell-check-rationale edit to `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md`.

## Unnecessary Complexity Found
None identified. Each hand-authored file is short, single-purpose, and carries an inline comment justifying any nonobvious choice:

- `.coderabbit.yaml` excludes six platform directories with a comment explaining the 100-file CodeRabbit skip threshold. No path filter is present that isn't needed for that purpose.
- `app/very_good.yaml` mirrors the CI coverage flags with a comment explaining why CI can't read the file directly (pinned CLI 1.1.1) and why the two must stay in step. This is duplication across two files, but it is forced duplication (different tools, different config surfaces), not redundant code — the comment on each side names the other, which is the right way to keep intentional duplication safe.
- `.github/workflows/main.yaml` sets `coverage_excludes` with a comment stating exactly what's excluded and why (codegen and untestable entry points). No extraneous jobs or inputs.
- `.github/workflows/license_check.yaml` has one `skip_packages` entry with a comment citing the specific transitive dependency and the licensing discrepancy that justifies it.
- `.gitignore` change (`.idea/` → `/.idea/`, same for `.vscode/`) is a two-character fix, anchoring the patterns to repo root instead of matching nested directories of the same name — a correctness fix, not added complexity.
- `README.md` "Build and run" section states the exact gate command once and explains the four exclusions in one sentence each. No padding.
- `CLAUDE.md` rules 5 and 6 are two-sentence, dated, attributed rules per the project's own rules-engine format; neither introduces a process not already implied by the repo's stated three-way review workflow beyond adding the concrete trigger step and the response-brevity preference.
- `docs/plan/...md` edit: one status flip (`Not started` → `Done`) and a corrected explanation of why `spell-check`'s `working_directory` couldn't be `app` (the reusable workflow resolves the cspell config path against that directory, which doesn't contain `.github/cspell.json` after the move to root). This corrects a real bug in the plan's own earlier proposal rather than adding anything.

## Code to Remove
None. No dead code, no commented-out blocks, no unused config keys were found in the reviewed scope.

## Simplification Recommendations
None to propose. There is no logic here to break down, no nesting to flatten, no duplicate error-handling to consolidate, and no premature abstraction — the diff is CI/tooling configuration plus a plan-document status update, not application code.

## YAGNI Violations
None found. Every config key present in `.github/workflows/main.yaml`, `.github/workflows/license_check.yaml`, `.coderabbit.yaml`, `.github/dependabot.yaml`, and `app/very_good.yaml` maps to a concrete, currently active need (the coverage gate, the license allowlist, the CodeRabbit file-count limit, dependency update cadence, and the local/CI coverage-flag mirror respectively). No speculative extensibility points, generic solutions, or "just in case" entries were added.

## Final Assessment
Total potential LOC reduction: 0%
Complexity score: Low
Recommended action: Already minimal
