# Public repo standards

> **REPO-SAFE.** May be pasted into a session in the project repo or committed to it.

*Distilled Sep 11, 2026 from the hub's `docs/repo-context.md`, which is the standard every one of Jamie's public repos is held to. That file cannot travel, because it opens by explaining why the repos exist. This one carries the bar without the reason.*

**The audience is someone doing ten minutes of homework before talking to Jamie.** Not users. Every README, doc and commit-facing artifact is a work sample. Docs that would be fine for an ordinary open-source project are not automatically fine here.

## README standard

Five sections, in this order:

1. **What it does and why I built it.** Two to four sentences, a real need, plain voice.
2. **How it was built: the workflow.** What was delegated to agents, what Jamie decided or corrected himself. Specific, honest, no hype. For this project that means the three-reviewer comparison table and the read-before-accept rule.
3. **Current shortcomings.** An honest list. Knowing exactly what is wrong with your own software is the senior signal. **Never sand this section down.** Where a stated principle has an unpaid cost, the cost is the close, not a footnote.
4. **What's next.** Points at real open issues, not a wish list.
5. **Build and run instructions that actually work from a fresh clone.** Test them from a fresh clone before calling the README done.

## Build log standard

A narrative `BUILDLOG.md`, six to ten dated milestone entries derived from commit history. Story, not raw log. **Include dead ends and reversals**, because throwing away an approach is a senior signal. For this project the domain-package extraction is the planned entry, with its cost in minutes. Claude drafts from git history, Jamie edits for truth.

## Style rules, all outward-facing text

- **No em dashes.** Single dash, or restructure.
- **No semicolons in prose.** Plain sentences.
- **No LLM-isms** (delve, leverage, robust), no hype adjectives, no corporate polish.
- **Metrics and specifics over claims.** "Parses 40-minute transcripts in ~2s" beats "fast". A small unimpressive count is worse than claiming the scope, so claim the scope and keep the count in a trace file.
- **Shortcomings stated plainly, not spun.** "Known issue," never "opportunity."
- **Never lead with generation time.** A wall-clock number may only appear alongside its verification cost: the review trail, the issue count, the correction loop. The claim is never "fast," it is "fast to generate, rigorous to verify." A bare small-time claim reads as vibe coding.
- **Never name a school or an employer in a critique.** Anything about what an institution got wrong gets generalized to the industry. If a reader can map an argument back onto a specific employer, rewrite it wider.
- **No bad-faith magnets.** Screen every example for whether a hostile or careless reader could make the example the story instead of the work. Religion, politics, demographics, anything identity-adjacent. An example that loses the reader's attention to its own subject has already failed.

## Before the repo is public

This one goes public at the first push, so run these before the first push rather than before a flip:

- **No secrets, keys or tokens**, and scan history rather than only HEAD.
- **Author identity is right.** History on this machine predating Sep 1, 2026 was authored under an old work address. A fresh repo starts clean, so just confirm `git config user.email` is the personal address before the first commit. Getting this wrong after the fact means a history rewrite.
- **LICENSE present.** MIT unless Jamie says otherwise.
- **Nothing half-finished in tracked files.** Stray TODOs are fine. A broken main is not.
- **The page title and any static heading**, if anything ends up rendered, not just the repo name and description. Those are the surface a reader sees in a browser tab and a link preview.

## Working with Jamie

- Senior developer using Claude Code as a primary tool. Skip boilerplate explanations. The hard parts are design decisions, integration and edge cases.
- Ask questions in batches.
- When he pushes back hard, that is stress-testing, not anger. Push back with substance if he is wrong.
