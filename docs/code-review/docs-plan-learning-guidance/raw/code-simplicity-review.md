# Code Simplicity Review: `docs/plan-learning-guidance` vs `main`

Scope: 8 files, documentation only, no Dart source changed. Reviewed as a design/planning
artifact with a maintenance cost, per the task brief: duplication, length against adherence,
the rejected alternative (closed PR 7), and `CLAUDE.md` rule 8.

## Core Purpose

The branch does two things:

1. Retracts the plan's "cold writing" requirement and replaces it with four collapsed
   `<details>` teaching blocks (Phase 1 reading guide, Phases 2-4 "constructs" blocks), so
   Jamie (new to Dart, on a deadline) has worked examples before hand-writing the domain,
   evaluator, repository, and Bloc.
2. Commits PR 1's prior review report as evidence and records two deferred findings in the
   plan and the README comparison table.

`CLAUDE.md` gets one new numbered rule (8) documenting the same policy shift.

## Method

Read `CLAUDE.md` in full (Hard rules, Rules engine, Learned Rules), `docs/repo-standards.md`,
and the full diff of the plan file (`git diff origin/main...HEAD -- docs/plan/...`), comparing
each new `<details>` block against the plan sections that already existed (Eight decisions,
State shape, the Phase 1 "Read the tree" bullet, the pre-existing "Hints" blocks). Did not
review the five files under `docs/code-review/keeper-status-bootstrap/` — they are a frozen,
verbatim prior-review artifact per the task's scope notes, and are only in scope for whether
committing them is appropriate (it is: they're cited from the README and referenced from a new
plan paragraph, both as evidence, not as duplicated prose).

## Findings

### 1. Three lint facts from the Phase 1 table are restated almost verbatim in later blocks

Phase 1's collapsed block ends with a lint table (lines ~126-136) that exists specifically to
be "the first two will land on the first file Phase 2 writes" — i.e., a lookup table read once,
up front. But three of its rows are then restated, nearly word for word, at the point of use in
later blocks:

- `prefer_initializing_formals`: Phase 1 (line 132) — "Take the field directly as `required
  this._repository`. Never a plain parameter assigned in an initializer list, and this holds
  even when the constructor also calls `super`." Phase 4 (line 752) — "`required
  this._repository` works even alongside the `super` call, and the initializer-list spelling
  that assigns a plain parameter to the field trips `prefer_initializing_formals`."
- `empty_container_bodies`: Phase 1 (line 134) and again at Phase 4 (line 822), same fact ("a
  `;` rather than `{}`") in near-identical words.
- `avoid_catches_without_on_clauses`: Phase 1 (line 136) and again at Phase 4 (line 752), same
  fact restated.

This is exactly the failure mode the task brief asks to test for: the same policy fact given
two homes. If a future Dart/lint version changes any of these three claims (the plan already
notes two forms the draft had wrong before verification), there are now two places to find and
correct, and nothing marks them as linked. The lint table's stated purpose — "the first two
will land on the first file Phase 2 writes" — already covers the encounter-at-point-of-use
need; restating them again in Phase 4 doesn't teach anything the table didn't.

This is a minor duplication, not a functional defect: the restatements are consistent with each
other today, and each occurs at a natural point where a snippet needs the fact right next to it
to read as self-contained. It's borderline against being intentional pedagogical repetition
(seeing a rule invoked at its use site can be worth the redundancy). I'm flagging it as a
Suggestion rather than an Important, because cutting it costs a small amount of "does this
snippet make sense read alone" value, and the fact is small enough that keeping both in sync is
cheap.

### 2. The Phase 1 constructs block restates the Page/View/Bloc-provider facts the existing "Read the tree" bullet already states

The pre-existing Phase 1 bullet (line 282, present on `main` and carried forward unchanged in
its core claim) already says: "`CounterPage` creates the Cubit under `BlocProvider`,
`CounterView` reads it with `context.read` in callbacks and `context.select` in `build`."

The new constructs block restates the same three facts about the same two widgets under "Page,
View, barrel" (line 337) and "Three ways a widget talks to a Bloc" (line 339): `CounterPage`
**provides** via `BlocProvider`, `CounterView` **consumes** it, `context.select` in `build`,
`context.read` in a callback.

Unlike finding 1, I don't think this rises above a Suggestion either. The existing bullet is
narrative ("read the tree in this order, and here's what you'll see"); the new block is a
generalized rule ("this split is the convention everywhere in this repository") with the verbs
provide/consume introduced as vocabulary the later phases reuse. It's the same underlying fact
told twice at two different altitudes (specific example vs. named pattern), which is a
defensible pedagogical structure, not obviously wasted material. Still, it means a change to
how the counter's Page/View split is described (e.g., if the template's actual counter code
changes on a future scaffold) has two sentences to update instead of one.

### 3. `CLAUDE.md` rule 8 bundles a boundary rule, a teaching procedure, and three separate justifications into one 109-word sentence

Rule 8 is the longest of the eight numbered rules by a wide margin (109 words; the next
longest, rule 7, is 83; the average of the other seven is 60). Word counts of all eight:

```
Rule 1: 32   Rule 2: 52   Rule 3: 60   Rule 4: 33
Rule 5: 59   Rule 6: 68   Rule 7: 83   Rule 8: 109
```

More important than the raw length is what it bundles. One sentence carries:

- a boundary prohibition ("Never write a file under `app/lib/domain/`... for Phases 2 to 4,
  and never answer a question about them with code that could be pasted in")
- a procedure ("teach through the collapsed constructs blocks in the build plan instead, and
  put any new teaching material in the phase that needs it rather than in a new document")
- three separate justification clauses chained with commas and "and" (the retraction, that
  Jamie can explain every line, and the 865-line rejected package)

`CLAUDE.md`'s own "Rules engine" section states two things this rule runs against: "A
multi-step procedure belongs in a skill, not in a rules list," and "Record what was decided and
why, and leave the boundary open rather than writing an absolute that binds every future
session." The procedure clause ("teach through the collapsed constructs blocks... put any new
teaching material in the phase that needs it") is exactly the multi-step-procedure case the
rules engine says doesn't belong here — it's instructing *how* to write future teaching
material, not recording a boundary that was crossed. And the three stacked justifications make
this read as an argument rather than a decision-with-reason.

This also duplicates material: the plan's own "What the boundary permits, and what replaced
cold writing" paragraph (plan lines 42-44 in the diff) already carries the full reasoning —
the retraction, the PR 7 rejection and why, and where the guidance lives. Rule 8 is a second,
compressed home for the same decision. Given `CLAUDE.md`'s explicit stance that "length is a
cost, not a record," and that adherence drops as these files grow, the 109-word single sentence
is worth trimming to the boundary itself (the "never write" clause, one reason), with the
procedural "how to teach" guidance either dropped (the plan file already carries it, and rule 8
does not need to re-teach the plan's own convention) or moved to a skill if it needs to recur
across future planning documents.

I rate this Important: it's a genuine second home for the same decision (rule 8 vs. the plan's
boundary paragraph), and it violates a convention the project has explicitly written down for
itself.

### 4. The rejected-alternative comparison: the in-plan form is simpler, not just relocated

Checked whether the current approach merely moved the ~865 lines of PR 7's example package
into the plan rather than actually simplifying. It did not just move bulk: the four new blocks
in the plan total roughly 450 lines (Phase 1: ~70, Phase 2: ~140, Phase 3: ~110, Phase 4:
~140), all collapsed by default under `<details>`, all built from throwaway types (`Book`,
`Thing`, `Guess`) rather than a second implementation of the evaluator's domain rules. This
avoids the two real defects the task brief names in the rejected PR: a second Dart package sitting
outside `app/`'s CI scope (so `dart analyze`/`flutter test` would never run over it), and the
false-positive policy or evaluator logic being encoded a second time (two homes for one
policy). The new blocks explicitly avoid re-encoding domain policy — they use `Hive`,
`RollingCheck`, and `Grade` as stand-ins for the real `Metric`/`Baseline`/`Severity` types, so
nothing in them can go stale against a policy change the way a second real implementation
would. This is a legitimate simplification, not a relocation of the same complexity, and I have
no finding on it.

## What did not fire

- No inert or dead material: every block earns a "Read first" cross-reference from the phase
  it teaches, so nothing is unreachable.
- No premature abstraction: the constructs blocks are pure syntax reference (records, sealed
  classes, extension types) with no new indirection introduced into the plan's actual
  structure.
- No YAGNI violation in the choice to keep four separate blocks rather than one shared "Dart
  primer": each block's content maps to the constructs that specific phase's spec actually
  uses (Phase 2 gets `Equatable`/enum/extension-type/record/sealed-class, Phase 3 gets the
  stateful fold, Phase 4 gets the repository/Bloc pair). Merging them would force an early
  reader to sit through Bloc syntax before Phase 2 needs it.
- The existing "Hints" blocks (Phase 3, Phase 4) and the new "constructs" blocks are not two
  homes for one idea: hints are behavioral/tuning guidance (fixture values, tie-break rules,
  noise floors) and constructs blocks are language syntax, explicitly split by their own
  subtitles ("the spec above owns the policy/behaviour; this owns the language"). The split is
  justified.
- Committing the five `docs/code-review/keeper-status-bootstrap/` files is not itself a
  simplicity problem — they are cited as evidence from the README and from a new plan
  paragraph, which is the reason to commit a report at all.

## Final Assessment

Total potential line reduction: small, on the order of 10-20 lines (trimming rule 8's
procedural clause and possibly one of the three duplicated lint sentences). This is not a
document that needs a broad simplification pass; the near-doubling in length is mostly new,
non-duplicative teaching material that replaces a strictly worse alternative (a second, ungated
package). The complexity that exists is concentrated in one over-bundled `CLAUDE.md` rule and a
handful of restated facts.

Complexity score: Low.
Recommended action: Minor tweaks only — split or trim `CLAUDE.md` rule 8; optionally drop the
Phase 4 restatements of the three Phase 1 lint facts in favor of a short cross-reference.
