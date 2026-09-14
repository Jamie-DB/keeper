# Test Quality Review — `docs/plan-learning-guidance` vs `main`

Scope: 8 files (CLAUDE.md, README.md, the build plan, and the five committed
`docs/code-review/keeper-status-bootstrap/**` review artifacts). No Dart
source or test files changed on this branch. This review's surface is the
testing guidance inside the plan's three new collapsed teaching blocks
(Phases 2, 3, 4), checked against `CLAUDE.md`'s binding Testing section, the
`vgv-ai-flutter-plugin:testing` and `:bloc` skills, and the plan's own
acceptance criteria.

## What was checked and how

- Read `git diff origin/main...HEAD` in full (two commits, docs only).
- Read `CLAUDE.md`'s Testing section (binding project rules) and
  `docs/repo-standards.md`.
- Read every line the diff added to
  `docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md`, focusing on
  the four collapsed `<details>` blocks (Phase 1 reading guide, Phase 2, 3, 4
  constructs).
- Loaded the `vgv-ai-flutter-plugin:testing` skill's `SKILL.md` and the
  `bloc` skill's `references/testing.md` to compare the plan's taught
  conventions (group-by-type, `late`/`setUp`/mock conventions, `blocTest`
  shape) against the documented project standard.
- Re-verified the Dart snippets myself rather than trusting the plan's Sep
  13 verification claim at face value:
  - Confirmed `group(Object? description, ...)` in `package:test` (via
    `test_api-0.7.14/lib/src/scaffolding/test_structure.dart`) accepts any
    `Object?` and calls `.toString()` on it, so `group(Book, () {...})`
    compiles and is exactly the pattern the `testing` skill's own
    `SKILL.md` teaches (`group(UserRepository, ...)`, `group(AuthService,
    ...)`).
  - Ran `dart analyze` against the pre-existing, already-resolved scratch
    package at `.context/pr7-archive/learning/examples/watchtower/`
    (`bloc`, `bloc_test`, `equatable`, `mocktail`, `test`,
    `very_good_analysis` 11.0.0, Dart 3.13.2): `No issues found!` across
    `lib/` and `test/`. That package's files instantiate essentially every
    construct the plan's three blocks teach (the `new(...)` unnamed-
    constructor form, `extension type const Id(String value);`, sealed
    result types with `isA<T>()` / `as`, the enum-with-field ranking
    pattern, the repository-plus-Bloc shape, the `_MockX extends Mock
    implements X;` semicolon form, `group(Type, ...)`, `closeTo`,
    `isEmpty`, `hasLength`, `everyElement`), and its Bloc test
    (`test/incident_inbox/bloc/incident_inbox_bloc_test.dart`) wraps
    `late`/`setUp`/`test`/`blocTest` inside `group(IncidentInboxBloc, () {
    ... })`.
  - Built a second scratch package in `/tmp` to isolate and re-verify the
    "Five lints" table (Phase 1 block) by deliberately writing each
    violation and confirming `very_good_analysis` 11.0.0 fires
    `unnecessary_type_name_in_constructor`,
    `unnecessary_const_in_enum_constructor`, `prefer_initializing_formals`,
    `always_put_required_named_parameters_first`, and
    `empty_container_bodies` exactly as described. All five fired as
    claimed.
  - Wrote a small `dart run` script against `equatable: ^2.1.0` (the
    version pinned in `app/pubspec.yaml`) to check the plan's claim about
    `Map` fields under `Equatable`. Did not run `dart test` or
    `flutter test` per the task's instruction; this was a plain script run
    with `dart run`, which the instruction did not restrict.
- Cross-checked the plan's Phase 4 acceptance criteria (the five exact
  `blocTest` names) against the constructs block to confirm the block's
  throwaway types (`ThingBloc`, `ThingRepository`, `Book`, `Lookup`, etc.)
  cannot collide with or be mistaken for the real, named tests.
- Spot-checked the README diff and the plan's new paragraph citing
  `docs/code-review/keeper-status-bootstrap/review.md` findings 7 and 8
  against that file's actual FINDING-07/FINDING-08 text, per the task's
  instruction to flag the committed review artifacts only if something
  outside them misrepresents them. No mismatch found; the plan's summary of
  "a build job or matrix over `packages/*`, license paths, a dependabot
  entry per package, and the spell-check glob" matches both findings'
  stated fixes.

## Findings

### 1. Critical — the Phase 4 `blocTest`/`mocktail` snippet teaches `setUp` outside a group, the exact anti-pattern the plan says it is overriding

`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:802-812` (the
`blocTest` and `mocktail` code block) reads:

```dart
class _MockThingRepository extends Mock implements ThingRepository;

late ThingRepository repository;

setUp(() {
  repository = _MockThingRepository();
});

blocTest<ThingBloc, ThingState>(
  'emits failure when the repository throws',
  ...
);
```

`late repository` and `setUp(...)` sit at the top level of the snippet, with
no enclosing `group(...)`. Four things make this a real defect rather than
an artifact of showing a fragment:

- `CLAUDE.md`'s Testing section is explicit and unconditional: "`setUp` and
  `tearDown` live inside a group." This is one of the six bullets the
  section lists, not a soft preference.
- The `vgv-ai-flutter-plugin:testing` skill lists this exact shape in its
  Anti-Patterns table: "`setUp` at the top level of `main()` — Breaks when
  test runner merges files for optimization — Move `setUp` inside a
  `group`."
- The plan's own Phase 4 "Read first" bullet
  (`docs/plan/...:434` in the current file, same line the diff touches)
  says: "That reference's Bloc example puts `setUp` outside a group and
  names its mock without an underscore; the rules below win." The plan is
  explicitly flagging the plugin's `bloc` skill's `references/testing.md`
  Bloc Test Example (`setUp` before `group('TodosBloc', ...)`) as the wrong
  shape and promising the rules below correct it. The new constructs block
  is exactly "the rules below," and it reproduces the same mistake it was
  introduced to fix.
- The bullet directly under the snippet (`docs/plan/...:825`) says "`late`
  plus `setUp` inside the group, so every case gets a fresh mock" — the
  prose asserts a `group` wrapper that the code above it does not show.

The already-verified reference example the plan cites as having been
analyzer-checked
(`.context/pr7-archive/learning/examples/watchtower/test/incident_inbox/bloc/incident_inbox_bloc_test.dart`)
gets this right: it wraps `late`/`setUp`/`test`/`blocTest` inside
`group(IncidentInboxBloc, () { ... })`. The plan's abbreviated teaching
snippet diverges from its own verified source in precisely the dimension
that matters for this rule.

**Why it matters at this cost**: the author is new to Dart, is instructed to
write these files by hand with no agent touching them, and is told this
snippet is the language reference for the exact section of the exact file
(`app/test/alert_inbox/bloc/alert_inbox_bloc_test.dart`) that Phase 4's
acceptance criteria require to carry five exactly-named `blocTest` cases.
If the hand-written file mirrors the shown shape, `flutter-reviewer` (which
grades PR 2 against these standards) and the `/review` VGV agents have a
concrete, named anti-pattern to catch on the first hand-written Bloc test in
the repository — the one the README's three-reviewer comparison table is
built to showcase.

**Fix**: wrap the snippet in `group(ThingBloc, () { ... })` (or equivalent),
matching the analyzed reference file, so the code and the prose bullet
beneath it agree.

### 2. Important — the `Equatable`/`Map` equality claim is factually wrong for the pinned `equatable` version

`docs/plan/2026-09-11-feat-foundation-and-alert-inbox-plan.md:826` (the last
bullet of the Phase 4 constructs block) states:

> `expect` compares with `==`, so every state and everything inside it must
> come through `Equatable`. A `List` field compares element by element
> through `props`; a `Map` does not.

This is incorrect for `equatable: ^2.1.0`, the version pinned in
`app/pubspec.yaml`. `Equatable`'s `==` delegates to `iterableEquals` over
`props`, which calls `objectsEquals` per element
(`equatable-2.1.0/lib/src/equatable_utils.dart`). `objectsEquals` has an
explicit branch: `else if (a is Map && b is Map) { return mapEquals(a, b);
}`, and `mapEquals` compares key-by-key, value-by-value (`objectsEquals`
recursively), the same as its `Iterable`/`List` branch. I confirmed this
empirically with `dart run` against the pinned version:

```
map equal same content: true
map not equal diff content: false
list equal same content: true
```

Two `Equatable` instances whose only differing field is a `Map` with
identical keys and values compare equal, exactly like a `List` field does.

**Why it matters**: this sits in the same bullet that teaches how
`blocTest`'s `expect: () => [...]` list comparison works, for the file
whose named tests (`orders by severity then raised-at then id`, `collapses
a four-metric bear into one alert`, etc.) depend on state equality working
correctly. A false belief that `Map` fields need special handling under
`Equatable` could push the hand-written state design away from a `Map`
field it would otherwise reach for (e.g., a signal-to-magnitude map on an
alert state), or cause a real equality bug elsewhere to be misdiagnosed as
"the Map problem" during Phase 4's hand-written debugging, with no agent
allowed to write into that file to help sort it out.

**Fix**: drop the second half of the sentence, or replace it with the
version-accurate statement: both `List` and `Map` fields compare
element-by-element / key-by-key through `props`; only a custom object that
is not `Equatable`, a `List`, a `Map`, a `Set`, or a `num` falls back to
plain `==` and can silently break the comparison.

## Non-findings, checked and cleared

- **`group(Book, () {...})`, passing a `Type` rather than a `String`.**
  Verified against `package:test`'s `group()` signature
  (`Object? description`, stringified). Matches the `testing` skill's own
  documented convention (`group(UserRepository, ...)`) exactly. Not a
  defect — this is a correct and more rename-safe convention than the
  scaffold's own `group('CounterCubit', ...)` (Very Good CLI template,
  unrelated to this diff, deleted in Phase 6 anyway).
- **The "Five lints" table** (Phase 1 block):
  `unnecessary_type_name_in_constructor`,
  `unnecessary_const_in_enum_constructor`, `prefer_initializing_formals`,
  `always_put_required_named_parameters_first`, `empty_container_bodies`.
  Reproduced each violation in an isolated scratch package under
  `very_good_analysis` 11.0.0 and confirmed all five fire with the stated
  wording.
- **The `new(...)` unnamed-constructor shorthand and `extension type const
  Id(...)`.** Both confirmed to analyze cleanly under Dart 3.13.2 in a
  from-scratch minimal package, independent of the pre-existing scratch
  package.
- **`isA<T>()` then `as` for reading a sealed result, and `closeTo` for
  doubles** (Phase 3 block). Matches real usage in the verified reference
  package's `latency_checker_test.dart`
  (`expect(result, isA<Spiked>()); final spike = (result as Spiked).spike;`
  and `closeTo(3.5, 0.001)`).
- **The matcher set** (`equals`, `isNot`, `isA<T>()`, `closeTo`, `isEmpty`,
  `hasLength`, `everyElement`). All seven appear in real, analyzer-clean
  test files in the reference package, used correctly.
- **Mock declaration shape** (`class _MockX extends Mock implements X;`,
  private, underscore-prefixed). Matches `CLAUDE.md`'s "Private mocks per
  file, underscore-prefixed" and the `testing` skill. The semicolon form is
  the `empty_container_bodies`-compliant version of the skill's own
  (slightly older) `{}` example; not a contradiction, an update to a newer
  lint the skill's static examples predate.
- **Acceptance-criteria collision risk.** Phase 4's five exactly-named
  `blocTest` cases (`orders by severity then raised-at then id`, `derives
  severity from the excursion spec`, `raises nothing for a hive below the
  minimum history`, `collapses one excursion into one alert`, `collapses a
  four-metric bear into one alert`) do not appear, or get contradicted, by
  anything in the constructs blocks — the blocks deliberately use throwaway
  domain names (`Book`, `Lookup`, `ThingBloc`, `Signal`/`Guess`) so nothing
  in them could be mistaken for, or retyped as, the real spec.
- **The five newly-committed `docs/code-review/keeper-status-bootstrap/**`
  files and their README/plan cross-references.** Per the task's scope
  note, I did not review their prose or findings. I did check the plan's
  new paragraph under "Deferred to slice two" that cites "findings 7 and 8"
  against the actual `review.md` FINDING-07/FINDING-08 text: the summary
  (build job or matrix over `packages/*`, license `paths` entries, a
  dependabot entry per package, the spell-check glob) matches what those
  two findings actually say. No misrepresentation found.
- **Widget-test conventions (`pumpApp`, `MockBloc`/`MockCubit`).** Not
  applicable — none of Phases 2, 3, or 4 write or test widgets; that
  guidance would belong to Phase 6, which is out of this diff's scope (no
  widget teaching block was added).

## Verdict

One Critical and one Important finding, both confined to the Phase 4
`blocTest`/`mocktail` constructs block. Everything else in the three new
testing blocks — the pure-Dart test shape, the sealed-result reading
pattern, the matcher set, the lint table, the mock declaration shape — held
up under independent re-verification (analyzer runs against isolated
scratch packages, not just trust in the plan's own verification claim).

Fix the two findings above before the guidance is relied on for the actual
hand-written Phase 4 file: the `setUp`-outside-a-group snippet is the kind
of defect that is cheap to fix in a markdown block and expensive to fix
after it has shaped a hand-typed, unassisted test file that a three-way
review is specifically designed to catch it in.
