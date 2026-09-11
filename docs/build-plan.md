# Hive project: build plan

> **REPO-SAFE.** Everything in this file may be pasted into a session in the project repo or committed to it. It names no company, no person, and no reason for existing beyond the app itself. Keep it that way. The private half of this plan lives in a separate file outside the project and is named in the package README.

*Third iteration, Sep 11, 2026. The first split this out of a ramp schedule. The second ran an engineering audit over it. This one audits for sequence, gaps and bridging, verifies every named package against pub.dev, and replaces the tooling install with a verification, because the tooling is now installed and working.*

**The scope rule for the whole doc: finishable and public beats complete.** Anything not done is an open issue, not a secret.

---

## 1. What the app is

A monitoring and field-work app for a beekeeping operation.

Battery-powered sensors sit on hives and report weight, internal brood temperature, humidity and sound on a schedule, through a gateway at the yard rather than each talking to the internet. A backend scores each reading against a **baseline for that specific hive and that specific metric**, which drifts with the season. A reading that departs from its baseline raises an alert. The beekeeper triages the alert and schedules it into the next yard visit.

**It is a user-facing application that helps its user identify, locate and fix a problem. It is not a dashboard.** That distinction drives every screen.

**The pitch, in one line: inspect when it matters, not on a schedule.** Not "never open your hive." Experienced beekeepers will roll their eyes at that, because sensors cannot replace inspections for the things that matter most. Disease, American and European foulbrood and chalkbrood, needs eyes on the brood comb. Varroa mites, the biggest killer of colonies, are counted with an alcohol wash or a sugar roll, and entrance cameras that try to detect them are not a replacement yet. Brood pattern and queen cells need a visual check to confirm. What sensors do well is tell you when to open the hive and when to leave it alone. Fewer, better-timed inspections is what beekeepers actually want, and it is the honest claim.

**What each sensor is for**, because the candidate causes come from this:

- **Weight** shows nectar flow, harvest timing, and whether winter stores are running low. A sudden drop suggests a swarm or robbing.
- **Brood temperature stability** hints at brood presence and colony strength. A drop suggests queen failure or cluster collapse.
- **Sound** can flag swarming preparation and possible queen loss, since a queenless colony sounds noticeably different. Acoustic monitoring is one of the stronger non-invasive signals.
- **Motion or tilt** catches a tipped hive, bears, or theft. The one metric whose alerts almost always resolve from the outside.

### What the sensors can sense, and what they cannot. This is the resource gathering

Researched Sep 11, 2026 against what commercial hive monitors ship (BroodMinder, Arnia, and the research platforms in the hive-monitoring literature) so the metric set is real rather than guessed. The job of this table is to say, per signal, what a departure can mean, what else explains it, and who resolves it: the sensor alone, a look from the outside, or the lid off. The evaluator, the candidate causes and the two checklist tiers all come from this table.

| Signal | Sensor | A departure can mean | What else explains it | Resolved by |
|---|---|---|---|---|
| **Weight** | Scale under the hive | Sudden drop over hours: swarm. Drop over days: robbing or starvation. Steady gain: nectar flow. Slow loss in winter: stores running low | Rain adds weight for a while. Feeding adds it. Harvest and the beekeeper's own manipulations remove it. Foragers leaving in the morning and returning in the evening are visible in within-day weight | Outside check for most. Lid off for starvation and stores |
| **Brood temperature** | Probe in the brood nest | Stable near 34 to 35 C means brood is present. Loss of that stability: broodless, queen failure, or a cluster too small to hold heat. In winter the warm spot says where the cluster is | Cold snaps stress a small colony. A probe in the wrong place reads the box, not the brood | Lid off. This is the signal that most often earns an opening |
| **Humidity** | Same probe | With temperature, says whether the colony is curing nectar and ventilating. High and cold: condensation risk in winter | Weather. Ventilation changes the beekeeper made | Outside check, mostly. Rarely an alert on its own |
| **Sound** | Microphone or vibration sensor on the box | A rise in power around 110 Hz building toward 300 Hz ahead of swarming. Higher variability in the dominant frequency in a queenless colony. Fanning roar in heat | Rain and cold keep everybody home and the hive gets loud. Heat makes fanning loud. Traffic and wind reach the microphone | Outside check for swarm prep, since queen cells need the lid off to confirm. Lid off to confirm queenless |
| **Motion or tilt** | Accelerometer | Tipped, bear, theft, or a box moved by the beekeeper | The beekeeper's own visit. Wind on a light hive | Outside check. The one metric that almost never needs the lid off |
| **Entrance activity** | Bee counter or entrance camera | Foraging trips per hour, population trend, drift, pollen coming in. Research systems also try to spot Varroa on bees walking in | Weather stops flight. Time of day. Season | Outside check. Not in the first build, see the issues list |
| **CO2** | Gas sensor inside the box | Colony metabolic activity, ventilation | Research-platform territory. Not in the first build | Not built |

**What no sensor sees.** Disease on the brood comb, the mite count, brood pattern, eggs, and the queen herself. Those are the internal tier and they are why the app schedules a person rather than replacing one.

**How a departure becomes a human trip.** The evaluator raises an anomaly from the numbers. The candidate causes come from the pattern, and each cause carries its tier: a tilt resolves from the outside, a swarm suspicion resolves from the outside unless the beekeeper wants to confirm queen cells, a queenless suspicion resolves with the lid off. The visit's checklist is built from the causes on the alerts scheduled into it, external tier first. That is the whole chain, sensor to person, and every link of it is data.

### Weather, and the "it is loud but it is raining" problem

Every confounder in the table above is weather or the beekeeper. Rain shows up as a temporary weight gain, and a subdued temperature curve confirms that the weight change was rain rather than bees. Bees do not fly in cold or rain, so entrance activity drops and the hive gets louder because everyone is home. Heat turns fanning up. A baseline that does not know the weather will cry wolf on every wet afternoon, and crying wolf is the one thing this app must not do.

**Where weather comes from.** Either a small ambient sensor on the gateway, since it already sits at the yard and has power, or a weather service looked up by the backend for the yard's location. Both are yard-level, not hive-level, because forty hives in one yard share one sky. The hub is the right place for it, which is also the right answer for a fleet of anything.

**Where it goes in the model.** A `YardConditions` reading at yard level, ambient temperature, humidity, rain, wind, timestamped, that the evaluator can take as context alongside the hive reading and its baseline. The evaluator's signature should accept it from day one even if the first build passes nothing, so the design shows the thought and the code shows the hook.

**Scope, decided.** Weather context is an open issue, not a slice. The first build ships the hook and a seeded `YardConditions` stream in the simulator with one demo: fire a weight gain with rain on and watch the evaluator hold its fire, fire the same gain with rain off and watch it alert. If that demo costs more than an hour it becomes the issue and nothing else. The related idea, beekeeper-declared events, is the same shape and the same issue: "I fed this hive" and "I harvested this yard" are things the person knows and the sensor cannot, and declaring them ahead suppresses the alert they would otherwise cause.

### Issues to file in the project repo on day one, and leave open on purpose

These are the problem's real edges. Filing them with a paragraph each, and not resolving them, is how the repo shows the problem was understood past what got built.

1. Weather context on the evaluator, with the `YardConditions` hook and the rain demo above.
2. Beekeeper-declared events, feeding and harvest, that suppress the alert they cause.
3. Entrance activity as a sixth metric, with a fake counter in the simulator.
4. Routine, non-alert items on a visit, mite counts above all.
5. Winter mode and long-horizon rules: cluster position from the temperature probe, stores below an absolute floor going into winter, thirty-day weight loss past a limit. These exist because a rolling baseline follows a slow decline down and never alerts.
6. Baseline correction from findings, the feedback edge in beat four, as an explicit algorithm rather than a sentence.
7. Per-yard alert budgeting, so a yard with thirty alerts on a bad day produces one visit with a ranked list, not thirty notifications.
8. Recovery rules per outcome: how long a hive stays recovering after reassembly, requeening and restart, what the relaxed baseline looks like during that window, and when the app should ask "is it back yet." Also feeding after an attack as a declared event, since a fed hive gains weight for reasons that are not nectar.
9. Peer comparison at yard level as a second baseline, if it does not make the first build.
10. Sensor health as its own alert class: a dead battery, a probe reading the box instead of the brood, a scale that drifted. The gateway knows, and a silent sensor is not a healthy hive.

**The phone triages. It does not capture the readings.** The sensors capture. The phone receives a prioritized alert, the person judges it, acts or defers, and records what they found. Everything the phone sends home is a human decision or a human observation, and all of it is small and structured.

### The four beats, and each is a real screen

1. **Identify.** Which hive, which metric, how far from baseline, for how long. Candidate causes ranked by the pattern, because a weight drop reads differently from a brood temperature drop. A weight drop suggests a swarm or robbing. A brood temperature drop suggests queen failure or cluster collapse.
2. **Locate.** Which yard, and where in the yard. A yard has a layout and every hive has a position in it, so the app draws the yard and highlights the box, and answers "which of these forty boxes" rather than leaving it to memory. **The layout is seeded data with yard-local positions, drawn by the app.** No map tiles, no GPS, no device location. Box seven is box seven on the diagram.
3. **Do the task.** A guided checklist cued by the suspected cause, in **two tiers, because every inspection has a cost and the app exists to make each one count.** The external tier first, nothing that needs the lid off: entrance activity, dead bees at the entrance, robbing seen, lid and sensor sitting right, feeder level, a heft of the back of the box, weather. If those explain the alert, it closes right there and the hive stays shut. Only if they do not does the internal tier open, and it is exactly the list sensors cannot see: queen seen, queen cells counted, brood pattern, frames of brood, stores, signs of disease, a mite count. Every observation is a structured entry, a kind and a value, the things a beekeeper genuinely writes in a notebook.
4. **Record the finding.** What it actually was, and what the hive is now. This closes the alert and feeds back to the baseline in one of two ways: **correct** it, when the colony is the same colony and the model's normal was simply off, or **reset** it, when the thing being measured is no longer the same thing. A hive that has been reassembled after a bear weighs less and will for weeks. A requeened hive will show no brood heat for a month. A restarted hive is a new colony with no history. In each case the old baseline is wrong by construction, and an app that keeps judging against it alerts every day until someone gives up on it. So the outcome sets the hive to **recovering**, the baseline relearns from the new state for a period that depends on the outcome, and the sensor's own state, re-tared, remounted, replaced, is recorded alongside. **A maintenance event resets the baseline.** That sentence is the same for a hive and for a machine that just had a bearing replaced.

**What opening a hive actually costs, and get this right because the false-positive policy rests on it.** Opening a hive is disruptive, not destructive. Healthy colonies get inspected routinely and do fine. But every inspection costs something, and unnecessary ones add up:

- **Heat.** The brood nest sits near 34 to 35 C. Pulling frames dumps that heat and the colony burns honey to rebuild it, which matters most in cold weather or for a small colony.
- **Work time.** Foraging and normal activity drop for a while afterwards. A colony can lose part of a day to recovery.
- **Scent.** The hive runs on pheromones, the queen's included. Smoke and open air scramble that signalling for a while.
- **Physical risk.** A careless inspection crushes bees, sometimes the queen. Broken propolis seals have to be rebuilt.
- **Robbing.** When nectar is scarce, an open hive draws bees from other colonies looking to steal honey.

None of these kill a healthy colony. Stack up too many inspections, especially clumsy ones in bad weather, and you get a weaker one. So the claim the app makes is not "never open the hive." It is "fewer unnecessary openings is better," which is exactly why a wrong alert has a price and why the external tier of the checklist comes first.

**Why the guided task with observations matters and is not decoration.** It is what the offline outbox carries. A visit deep in a yard with no signal produces a queue of ticked steps, observations and a finding that must survive the app being killed, upload exactly once when signal returns, and reconcile with whatever changed on the server while the phone was away. Payload size is not what makes an outbox hard, and photos were dropped from this plan for that reason: durability, ordering, idempotency and conflict are the problem, and structured data exercises all four without faking a camera on a simulator. The feedback edge in beat four is the human-in-the-loop design and it is the strongest idea in the project: the algorithm proposes, the person on site decides, and the decision improves the model's reference.

---

## 2. Domain model

Pure Dart. **No Flutter imports in this layer**, so it unit tests in milliseconds without a widget.

- `Yard`: a location holding hives, with a layout (width, depth, and a position per hive)
- `Hive`: belongs to a yard, has a position in it
- `Metric`: weight, brood temperature, humidity, sound, motion. Motion is near-binary and its causes are external, which makes it the cheapest alert type to build and the best one to demo first
- `Reading`: a hive, a metric, a value, a timestamp
- `YardConditions`: ambient temperature, humidity, rain, wind, at yard level, timestamped. **The evaluator takes it as optional context from its first signature.** The first build seeds it in the simulator and passes it for exactly one demo, per the weather scope decision in section 1. Getting it into the signature on day one is free. Adding it later means touching every call site and every test
- `Season`: derived from the date and the hemisphere, nothing stored. It is an input to cause ranking and to nothing else. See the baseline note below for why that is the only place a calendar is allowed
- `Baseline`: per hive, per metric, seasonally drifting, expressed as a band
- `Anomaly`: the computed departure of a reading from its baseline, with magnitude and duration. **An anomaly is arithmetic.**
- `Alert`: an anomaly promoted for a human, carrying severity, ranked candidate causes, and a triage lifecycle. **An alert is a decision waiting to happen.** Keep the two words separate in code and in conversation.
- `AlertStatus`: the triage lifecycle: new, acknowledged, scheduled into a visit, in progress, closed with a finding, dismissed
- `CandidateCause`: a named cause with a rank and the pattern that suggested it, for example weight drop over hours suggests swarm, weight drop over days suggests robbing, a sound change suggests swarm preparation or a queenless colony, a tilt suggests tipped, bear or theft
- `Visit`: a planned trip to one yard on a date, holding the alerts scheduled into it. **This is the centrepiece of the business rule.** Intervention is batched, and the visit is the batch. Real visits also carry routine work that no alert raised, mite counts above all. That is an open issue, not a slice, and the model should not be shaped so it cannot hold it later
- `Observation`: a structured entry made at a checklist step, with a kind, a value, a timestamp, and a tier, external or internal. **External observations never require opening the hive.** The tier is data because the app reports it
- `Finding`: what it actually was, closing an alert, carrying a `HiveOutcome`, and recording **whether the hive had to be opened to know.** Alerts cleared from the outside against alerts that needed the lid off is the one number that shows the false-positive cost, and it belongs on the inbox screen
- `HiveOutcome`: what the hive is after the finding, because a finding on a wrecked hive is not just "it was a bear." Researched Sep 11 against what beekeepers actually do after an attack. Five outcomes: **reassembled** (boxes restacked, queen present, same colony carries on, weaker), **requeened** (queen lost, a bought queen or a frame of eggs from a strong hive, expect a brood gap of three to four weeks), **combined** (remnant merged into a neighbour, this hive goes out of service), **restarted** (new package or nuc in the box, a new colony with a new start date), **decommissioned**. Plus the same choice for the sensor: **still mounted**, **remounted and re-tared**, **replaced**, **gone**
- `HiveStatus`: active, **recovering** with an until date, out of service. A recovering hive keeps reporting but its baseline is relearning, not judging, and the inbox shows that plainly
- `TriageAction`: acknowledge, schedule into a visit, note, dismiss, record observation, close with finding and outcome. **Each carries a client-minted id so it can be retried safely.** That id is decision 1 of the sync contract in section 5, and it is load-bearing from slice three, not from slice four. Mint it when the type is first written

### Baseline, defined. Seasonality is not a calendar

Jamie's question, Sep 11: do we model seasons, or go off pure numbers and let seasonality take care of itself? The answer is the second, with one exception.

- **The baseline is a rolling window of the hive's own readings**, per hive and per metric, on the order of seven to fourteen days. It follows the hive wherever the season takes it. Spring buildup, the main flow, the fall dearth and the winter cluster all move the window with them and nothing needs the date. That is the mechanism behind "drifts with the season."
- **Peers remove weather and season together.** A reading is also compared against the other hives in the same yard on the same day. Forty hives share one sky and one calendar, so rain moves every hive and nobody alerts, first frost drops every hive's brood heat and nobody alerts, and a bear moves one hive out of line with its neighbours and the alert fires. Peer comparison is cheaper and more honest than a weather model. `YardConditions` becomes the explanation shown on an alert, not the thing that decides it. Peer comparison is a stretch in the first build, and an issue if it slips.
- **Season enters in exactly one place: the candidate causes.** A weight drop in May ranks swarm first. The same drop in October ranks robbing or starvation first. No brood heat in January is normal and in June is a queen problem. A season label from the date and the hemisphere is enough, and cause ranking needs it, so it is in scope.
- **What a rolling baseline cannot see is a slow decline.** A hive starving over winter loses weight gradually, the window follows it down, and nothing ever alerts. So long-horizon rules with absolute floors sit alongside the baseline: stores below a threshold going into winter, thirty-day weight loss past a limit. That is issue 5, and it is the same failure mode as a bearing that degrades slowly enough to hide inside its own baseline.
- **A hive with no history**, new or restarted, borrows the yard's peers as its baseline until it has its own. That falls out of peer comparison for free.

**Write the evaluator first.** It takes a reading, its baseline and optional `YardConditions`, and returns an anomaly or nothing, with severity. It is the most testable thing in the project and the best thing to show someone.

**Write the false-positive policy down before the evaluator, as a spec of three lines.** Acting on an alert costs a hive opening, so the evaluator must not cry wolf. The policy: a reading is only an anomaly after it has been outside the band for N consecutive readings, the band edge has hysteresis so a value hovering on the line does not flap, and severity scales with both magnitude and duration. Be able to say why each of the three exists and what a false negative costs against a false positive.

**Dart on purpose.** The domain layer is where the language reps live, so use these deliberately and be able to point at the file: records for the evaluator's return, pattern matching in the triage `switch`, an extension type for `HiveId` and `AlertId`, a `Stream` for the readings feed, sealed classes for `AlertStatus`. There is no honest use for an isolate in this app after photos were dropped. Do not manufacture one. Know the model and say so if asked.

---

## 3. Architecture and stack

**Feature-first, in the four Very Good Ventures layers**: data, domain, business logic, presentation, with repositories between business logic and data.

### Packages, with versions checked against pub.dev on Sep 11, 2026

Check them again on the day. A version here is a snapshot, not a pin.

| Package | Latest | Last published | Call |
|---|---|---|---|
| `very_good_analysis` | 11.0.0 | Sep 3, 2026 | **Use it, from the first commit.** Not `flutter_lints`. 216 rules with strict casts, strict inference and strict raw types on. Current as of eight days ago |
| `flutter_bloc` | 9.1.1 | May 2, 2025 | Use it. Bloc rather than Cubit wherever the transition trail is worth having |
| `bloc_concurrency` | 0.3.0 | Jan 12, 2025 | Use it where it earns its place: `sequential` on the outbox, `restartable` on inbox search. Those two are the concrete answer to "advanced state management" |
| `bloc_test` | 10.0.0 | Jan 12, 2025 | Use it. Every Bloc gets `blocTest` cases, not raw `test()` with manual stream assertions |
| `equatable` | 2.1.0 | Jul 5, 2026 | Use it. Value equality on domain types and Bloc states |
| `go_router` | 18.0.1 | Sep 2, 2026 | Use it, with an `alert/:id` route so an alert can be opened by link. That is the shape a notification would deep link into, without building notifications |
| `drift` | 2.35.0 | Sep 9, 2026 | Use it for local persistence. Two days old, actively maintained |
| `mocktail` | 1.0.5 | Apr 10, 2026 | Use it. Never `mockito`. VGV states this flatly everywhere |
| `fl_chart` | 1.2.0 | Mar 13, 2026 | Use it for the baseline chart in slice two, timeboxed to two hours |
| `graphql_flutter` | 5.3.0 | Mar 14, 2026 | **The GraphQL client to reach for first.** Actively maintained. Apollo-shaped |
| `ferry` | 0.16.1+2 | Jan 6, 2025 | The typed-codegen alternative. Twenty months since its last release. Better generated types, more setup, more staleness risk. Pick it only if the codegen is the point |
| `gql` | 1.0.1 | Sep 20, 2025 | Query parsing, if the simulator ends up hand-rolling its server |
| `shelf_web_socket` | 3.0.0 | Jan 30, 2025 | For the one subscription |

### The GraphQL server problem, and read this before section 4 costs you a day

**`leto` and `leto_shelf` are at `0.0.1-dev.2`, last published October 2, 2023.** The second iteration of this plan named `leto_shelf` as the simulator's GraphQL server on the strength of it existing. Checked Sep 11, 2026: it is a dev prerelease, nearly three years stale, and its dependency list includes packages that have moved on since. Its SDK constraint nominally admits Dart 3, so it may resolve. It may also burn an afternoon of version solving on the one day the simulator was allowed.

Dart has no healthy standalone GraphQL server package. `graphql_server` last shipped in 2020. `angel3_graphql` is current, Aug 21, 2026, but arrives attached to a web framework.

**So decouple the artifact from the library, because the artifact is the part that matters.**

1. **Write `schema.graphql` by hand, first, before any server code.** Arguing about the shape of a contract before it is set is the transferable skill, and the SDL file is the artifact. This step is not optional and does not depend on any package.
2. **Point the client's codegen at the SDL file, not at an introspection endpoint.** Both `graphql_flutter` and `ferry` read a local schema file. This removes the server from the critical path of slice two entirely. The old plan made introspecting a live schema the first act of slice two, which coupled the client's progress to the riskiest dependency in the project. That was backwards.
3. **Then try a server, on a sixty-minute timer.** `angel3_graphql` first, `leto_shelf` second. If either resolves and serves the schema, take it.
4. **If the timer runs out, hand-roll it.** The simulator is a fake with a known, small set of operations. A `shelf` handler that reads the operation name out of the POST body and returns the right seeded shape is an hour of work and passes every client test. Write in the README that the simulator's GraphQL server is a stub rather than a real engine, because that is true and stating it is cheaper than being caught by it. The client side, which is the side that carries the transferable skill, is identical either way.

**Also.** Sealed classes with exhaustive `switch` for state machines. This is the closest Dart has to Swift enums with associated values.

### Repo layout

Three packages in one repo, in a Dart pub workspace:

- `app/`: the Flutter app, feature-first
- `simulator/`: the shelf server and its control surface, a plain Dart package
- `packages/hive_domain/`: the pure Dart domain, because the simulator scores readings with the same evaluator the app uses

**This is the deliberate abstraction decision, and it is also the pain point.** Extracting a domain package has a real reason here, which is two runtimes sharing one evaluator. It also has a real cost: a workspace, path dependencies, and a second place to run tests. VGV names premature packaging as one of their own three pain points. Hit it on purpose, feel the cost, and write it up in the README. It also keeps the simulator out of the app's coverage number.

**When to extract it, and this is a sequencing decision the earlier iterations left open.** The domain is hand-written on day one and the simulator does not exist until slice two. So:

- **Write the domain inside `app/lib/` on day one.** One package, no workspace, no path dependencies. Move fast while nothing else depends on it.
- **Extract it to `packages/hive_domain/` at the start of slice two,** when the simulator becomes the second consumer and the extraction has an actual reason. Do it as its own commit on its own branch so the diff is readable.
- **That commit is the pain point.** The cost shows up as a workspace file, path dependencies in two pubspecs, barrel exports, a second `pub get`, a second place tests run, and CI that has to know about both. Time the extraction and write the number down. A pain point with a number attached survives a follow-up question. One read off a blog post does not.

Extracting on day one would hide the cost, because there would be nothing to compare it against.

### The Claude Code tooling is part of the stack, not an optional extra

Two plugins from the same marketplace, and they stack. Full command-by-command reference is in the package's `jamie-only/vgv-stack-reference.md`, which does not travel into the repo. What follows is what a session inside the repo needs.

**VGV AI Flutter Plugin, the standards layer.** Fifteen skills invokable as slash commands: `create-project`, `bloc`, `layered-architecture`, `testing`, `navigation`, `material-theming`, `animations`, `accessibility`, `internationalization`, `static-security`, `ui-package`, `license-compliance`, `dart-flutter-sdk-upgrade`, `very-good-analysis-upgrade`, and **`green-gate`**, an autonomous verify-fix-rerun loop over analyze, format, test and coverage with a default 100% coverage target that is overridable. Plus a **`flutter-reviewer` subagent**, a read-only reviewer of changed Dart against Bloc, testing, security and accessibility standards, whose shell access is hook-restricted to `git diff` and `git status`. Plus six hooks: `dart analyze` and `dart format` run on every file the agent touches, a session-start warning when Very Good CLI is missing, and a hook that **blocks scaffolding and test commands through raw Bash so they route through the MCP tools instead.** That last one restrains the agent, not you. Your terminal is unaffected.

**VGV Wingspan, the workflow layer.** Twelve skills, not the eleven an earlier draft claimed. The four phases are `/brainstorm`, `/plan`, `/build`, `/review`, each writing artifacts to disk and each ending with an offer to clear context. The other eight are `/refine-approach`, `/plan-technical-review`, `/create`, `/create-pr`, `/rebase`, `/hotfix`, `/debrief`, and `/elements-of-style`. Ten review agents live under `agents/`, nested in four subdirectories, and all ten register.

**Two Wingspan gotchas worth knowing before they cost you something.**

- **`/create-pr` and `/rebase` are `disable-model-invocation: true`.** Claude cannot call them on its own initiative. Jamie types them. Any plan that assumes the agent opens its own pull request is wrong.
- **`/rebase` uses bare `git stash` and `git stash pop`.** Harmless in a standalone repo with one checkout. It is not harmless in a multi-worktree setup, where the stash stack is shared. Know which kind of repo you are in before running it.

**`/elements-of-style` loses to the repo's own rules.** It is a general writing guide. Where the README's standards disagree with it, the README wins.

### Environment. Verified on this machine Sep 11, 2026. Do not re-install

An earlier iteration of this plan carried a four-step install procedure and a table saying Very Good CLI was missing. **All of it is done.** Running the install again wastes a session. Run this verification instead, in a terminal, and only act if a line is wrong:

```
very_good --version   # 1.5.0 observed, plugin floor is 1.3.0
which very_good       # /Users/jamie/.pub-cache/bin/very_good
jq --version          # jq-1.7.1-apple, the build macOS ships
dart --version        # 3.13.2 stable, via Flutter 3.47.2
```

| Prerequisite | State, verified Sep 11, 2026 |
|---|---|
| Dart SDK | Present. 3.13.2 stable, via Flutter 3.47.2 at `~/Dev/flutter/bin` |
| `jq` | Present. 1.7.1-apple. No Homebrew install was ever needed |
| Very Good CLI | **Present. 1.5.0**, above the 1.3.0 floor |
| `~/.pub-cache/bin` on PATH | **Yes.** This was the real blocker in the earlier draft and it is resolved |
| Both plugins | **Installed at 0.0.5**, user scope, from `VeryGoodOpenSource/very-good-claude-code-marketplace` |

**One live problem, and budget ten minutes for it on day one.** The AI Flutter Plugin ships two MCP servers, `dart` and `very-good-cli`, configured to launch as the bare commands `dart mcp-server --enable dart_format` and `very_good mcp`. Both start fine from a login shell. Both **failed to connect** in a Claude Code session on Sep 11, 2026. The likely cause is that the session's process does not inherit the login shell's PATH, so neither binary is findable, but that is an inference and not a confirmed diagnosis.

What it costs if unfixed: Claude cannot run tests or the formatter through MCP, and the block-cli-workarounds hook stops it falling back to Bash, so `/green-gate` has nothing to call. You can still run everything yourself in a terminal.

What to try, in order: start the session from a terminal that already has the right PATH, then failing that, edit the plugin's `.mcp.json` to give both commands absolute paths. Confirm it is fixed by checking that the MCP tools appear, not by assuming.

**Scaffold with their CLI, not with `flutter create`.** `very_good create flutter_app <name>` is how a VGV shop starts a repo. Expect three flavors with their own entry points, a `bootstrap.dart` with a `BlocObserver`, localization wired, a mirrored `test/` tree, `very_good_analysis` already in, and a GitHub Actions workflow with coverage enforced. Verify each of those on the day rather than trusting this list. If the workflow is there, continuous integration is free rather than deferred. Use the flavors for something real: development points at the in-process fake, staging at the simulator.

**Which commands, where.** `/brainstorm` and `/plan` once at the start, with this file as the input and nothing else. `/build` per slice from the plan file. `/review` before every pull request. `/plan-technical-review` once against the hand-written plan for slice four. `/debrief` once, after the domain-package extraction, because that is the pain-point write-up in their own format. Commit every artifact these produce. They are the review trail, produced for free.

---

## 4. The simulator

Roll our own fake backend with a control surface. Public data was considered and dropped: data you seed is data you control, and there is no room for cleaning someone else's.

**A small local Dart server on `shelf`.** Written in Dart so it doubles as reps instead of costing a context switch. It lives in `simulator/` and imports the domain package for the evaluator.

- **Product read side is GraphQL**: yards with layouts, hives, reading history, baselines, alerts, visits. Plus **one subscription, alert raised**, over WebSocket. **Read the GraphQL server problem in section 3 before picking a package.** The hand-written `schema.graphql` comes first and the server library is chosen on a sixty-minute timer, with a hand-rolled `shelf` handler as the fallback.
- **Writes and control are REST.** A POST for triage actions that honours the idempotency key, and control endpoints: fire an alert now, push a reading that breaches a baseline, advance the clock, reset.
- **Chaos knobs: latency, failure rate, and a hard offline toggle.** Control endpoints, driven by curl for now.
- **Scenario buttons, and the bear is the first one.** Raw "push a reading" is for tests. A demo needs a story, so the control surface also has one endpoint per story that plays out across several metrics and several minutes of simulated time:
  - **Bear.** `POST /control/bear?yard=2`. Picks a random hive, or two neighbours. Tilt fires first, then a sharp weight drop over minutes as the honey goes, brood temperature falls because the box is open, sound spikes then goes quiet, and with some probability the sensor stops reporting because it is in the grass. Correlated signals across metrics in the right order are what make "bear" outrank "swarm" in the candidate causes, and one bear producing four alerts on one yard is the per-yard budgeting problem made visible in one press.
  - **Swarm.** Sound rises over days, then a weight drop over an hour on a warm afternoon, brood temperature holds. Resolves from the outside.
  - **Robbing.** Weight drop over days, entrance loud, nectar dearth. Resolves from the outside.
  - **Queen loss.** Brood temperature loses its stability, sound variability rises. Lid off to confirm.
  - **Rain.** Weight gain across every hive in the yard at once with a flat temperature curve and `YardConditions` reporting rain. The evaluator should hold its fire. This is the weather demo from section 1.

  **The bear has a second half.** When the app posts a finding with an outcome, the simulator applies it: reassembled restacks the hive at its new lower weight and resumes readings, requeened resumes with no brood heat for a simulated month, restarted starts a fresh colony with a fresh start date, combined and decommissioned stop the hive's readings, and the sensor outcome decides whether readings resume at all. The hive shows as recovering in the inbox with its until date, and its baseline relearns rather than judges. This is the feedback edge of beat four running end to end, not described. The demo is: press bear, triage, visit, record the outcome, watch the hive come back without a single false alert during recovery.

  Each scenario is a small script in the simulator that schedules readings against the simulated clock, which is also why the clock is a control endpoint. Bear ships in the first build because it is the most fun and it exercises the most. The others are cheap once the first one exists, and any that do not make it are issues.
- **The clickable HTML control page is an open issue, not a slice.** Curl is enough to demo with until after the app is done.

**The chaos knobs are the point.** They are how the offline and sync behaviour gets earned by demonstration rather than asserted. Killing the network from a terminal and watching the outbox hold, retry and reconcile is a thirty-second demo that no amount of explanation replaces.

**Keep an in-process fake behind the same interface** for Bloc and widget tests. Two implementations of one interface from day one is dependency injection demonstrated rather than described.

**The simulator is not built in one sitting. It arrives in three, alongside the slices that need it:**

| Built | When | What |
|---|---|---|
| Nothing | Slice 1 | Slice one has no network. Seeded local data only. Do not start the simulator here, it will eat the day |
| GraphQL read side | Start of slice 2 | `schema.graphql`, seeded yards, hives, readings, baselines, alerts. Enough to feed the detail screen and its chart |
| REST writes and the clock | Slice 3 | The triage POST with idempotency, plus advance-clock and fire-alert. Bear lands here, because bear is what makes triage worth demoing |
| Chaos knobs and the subscription | Slice 4 | Latency, failure rate, offline toggle, and the alert-raised subscription. These exist to make the outbox prove itself |

**Timebox: one working day in total, spread across the four entries above.** The simulator is more fun than the app and it will eat the schedule if allowed. If the running total passes a day, stop and ship what exists.

---

## 5. Build slices

Four, each shippable on its own, each merged through a pull request, each with one issue carrying a checklist. Every slice ends with a line in the README on what it earned and what it left open.

1. **Alert inbox against seeded local data.** List, sort by severity, open one. No network at all.
   *What this slice earns:* keys and list identity, `BlocProvider` as the honest answer to "explain InheritedWidget," `const` as a contract, and the Bloc versus Cubit opinion with a reason from this repo rather than a blog.
2. **Alert detail.** The metric charted against its baseline band, with ranked candidate causes, fetched over GraphQL from the simulator. Chart with `fl_chart`, timeboxed to two hours, and read its painter afterwards for the rendering-model answer. Ranked causes are a lookup table keyed by metric, pattern and season, not a model. **The domain package extraction happens at the start of this slice**, per section 3.
   *What this slice earns:* schema as contract, typed operations and codegen, `RepaintBoundary` as a measured fix rather than a reflex, and how Flutter draws its own pixels.
3. **Triage as a real Bloc.** Acknowledge, schedule into a visit, note, dismiss. Sealed state classes with an exhaustive switch in the UI. The visit screen lists what is scheduled and draws the yard with the scheduled hives highlighted.
   *What this slice earns:* sealed states, `bloc_test`, transformers, and the state-clearing-on-refresh anti-pattern VGV names in their own code review write-up.
4. **Offline and the outbox.** Drift cache for reads, queued actions for writes, the guided checklist with observations, close with a finding, and **staleness shown honestly in the UI**. The inbox gets its cleared-from-outside against needed-the-lid-off counter here, because this is the first slice where findings exist to count.
   *What this slice earns:* the entire offline design conversation.

**Slice four is the one that matters.** One through three exist to make it reachable. If time runs short, a thinner slice two is acceptable and a missing slice four is not.

### The sync contract. Write this down before slice THREE, not before slice four

Eight decisions. Each has a wrong answer that looks fine until it duplicates a finding in production.

**Why slice three and not slice four, corrected in this iteration.** Decision 1 puts a client-minted id on every `TriageAction`, and `TriageAction` is written in slice three. Writing the contract after slice three means retrofitting ids onto a type that already has call sites and tests. Decisions 1, 2 and 6 must be settled before the first `TriageAction` is written. Decisions 3, 4, 5, 7 and 8 can be written at the same time and implemented in slice four, and writing all eight at once takes an hour.

1. **Idempotency keys are client-minted.** A UUID per `TriageAction` at creation, sent with the action, honoured by the server. Client-minted because the client is the one that has to retry without knowing whether the first attempt landed.
2. **Ordering is per alert, first in first out.** Actions on different alerts may interleave. Actions on one alert never reorder.
3. **The outbox is its own Bloc with sealed states:** pending, in flight, failed with an attempt count, dead letter after the retry budget. `sequential` transformer, so two sends never race.
4. **Durability is a Drift transaction.** The action and its outbox row commit together. An app killed mid-visit loses nothing that was ticked.
5. **Retry is exponential backoff with a cap, triggered on attempt, not on connectivity polling.** Try, fail, wait, try. Do not build a connectivity oracle. The network is the oracle.
6. **Conflict policy is per field, written down:** server wins on alert status, client wins on observations, notes and findings. An alert closed by someone else while the phone was away stays closed, and the phone's finding attaches to it as a late note rather than reopening it.
7. **Staleness is a last-synced timestamp per entity, shown in the UI.** "Readings as of 2 hours ago" on the chart. Never present cached data as current.
8. **The retry budget and the dead-letter state are visible.** A dead-lettered action shows in the UI with a reason. Silent loss is the worst outcome and it is the default outcome of a naive queue.

### Four things to hit on purpose

- **Over-abstract one thing deliberately, then write down why it was wrong.** The domain package extraction in section 3 is the chosen one, at the start of slice two, timed. Clean architecture is only interesting with its pain points attached, and a pain point you hit survives a follow-up question in a way a pain point you read does not.
- **Write `bloc_test` cases**, not only widget tests.
- **Show the stale cache as stale.** Pretending cached data is fresh is the easy wrong answer.
- **Decide a false-positive policy and be able to defend it.** Intervention is expensive here, so a wrong alert costs a wasted hive opening.

### Five opinions by the end of the first run

The build exists to manufacture these, and the doc should say so. Each with a file to point at:

1. Bloc versus Cubit, and where in this repo each was the right call.
2. One VGV pain point hit first hand, and what it cost in minutes.
3. One `flutter-reviewer` finding disagreed with, and why.
4. Where Wingspan's phase gating helped, and where it was ceremony.
5. Who mints the idempotency key, and what goes wrong the other way.

---

## 6. Testing standard

**Run Green Gate on the app package and on the domain package, and follow VGV's published standard as the target.** Their contributing guide states 100% coverage is expected, Green Gate defaults to a 100% target, and Wingspan's review phase runs a Test Quality Agent over every testable unit. The simulator package is deliberately outside the coverage number, which is part of why the domain gets extracted.

**Exclude generated code from the denominator or the gate will chase it forever.** Drift and GraphQL codegen both emit `.g.dart` and `.freezed.dart`. Green Gate at 100% will try to cover them, fail, and loop.

```
very_good test --coverage --min-coverage 100 --exclude-coverage '**/*.g.dart'
```

Set that exclusion in the repo's test configuration before the first codegen run, not after the first failed gate.

**Run Green Gate only after the hand-written tests are committed.** Rule 2 in section 7 says the domain, the evaluator and the first Bloc are written cold with their tests. Green Gate will extend and reshape those tests to close coverage. If it runs first, the cold-written work is no longer distinguishable from the generated work. Commit the hand-written tests, then run the gate, then look at the diff. **That diff is evidence**, and it is a better answer to "how do you work with AI" than any sentence about it: here is what I wrote, here is what the gate added, here is which of its additions I kept.

**What good looks like, per layer.** Unit tests for the domain and the evaluator, which is where the interesting logic is. `bloc_test` for every Bloc, against the in-process fake. Widget tests for each screen against a fake repository, using `mocktail`. One integration-style test that runs the offline round trip through the fake: queue, kill, restore, replay, reconcile.

**Where it falls short, file it.** A task starts and ends with tests, and that rule holds for anything hand-written. Where the tooling leaves a gap, or the clock does, the gap becomes an open issue with the missing test named, and the README's shortcomings section points at it. A repo that meets the standard is evidence. A repo that is honest about where it does not is also evidence, and it is the senior kind. What is not acceptable is a coverage number that was quietly overridden with no issue behind it.

---

## 7. How the build runs

**1. Install and run the tooling before the hand-written core**, so the domain goes into their structure rather than being refactored into it later. The tooling is already installed, so this is now a verification and a scaffold. The day-one order is in section 8.

**2. Hand-write two things cold, before any agent touches the repo:** the domain value classes with the baseline evaluator, and `AlertInboxBloc` with its tests. The inbox Bloc because it is simple enough to write cold. `TriageBloc` is also hand-written, in slice three, because it is the state machine. The tooling writes the rest.

**3. The checking list those produce**, and it is the lens every agent-written file gets read through afterwards:

- **Value equality and `==`.** Dart is identity-based by default. A Bloc emitting a state that is equal but not `==` rebuilds forever.
- **Sealed classes and exhaustive `switch`.** What makes a state machine checkable by the compiler rather than by hope.
- **`const` as a contract, not a style choice.** A missing `const` is invisible and it is the most common defect in agent-written Flutter.
- **The async model.** `Future` and `async`/`await` map almost one to one from Swift. Isolates do not, because there is no shared memory. This app does not need one, and that is worth saying rather than hiding.

**4. Read every file the tooling produces BEFORE accepting it, and write one paragraph on what it did and why.** Not a diff summary. An account of the decision the code makes and whether it was right. This is non-negotiable and it is the rule most likely to slip under time pressure.

**5. If a file cannot be explained on demand, rewrite it by hand.** No patching, no deferring.

**Three reviewers on every pull request, and the comparison is the write-up.** CodeRabbit is free for public repositories, verified Sep 11, 2026. Install it on day one. Every slice merges through a pull request reviewed by CodeRabbit, by the `flutter-reviewer` subagent, and by Wingspan's `/review`. Keep a short table in the repo of what each caught and each missed on the same diff. That table is the honest, dated answer to "how do you ensure quality with AI."

**Issues are deliverables.** One issue per slice with a checklist, evidence in comments. Plus a planned-work list for everything deliberately left out, so the README's what's-next section points at real issues rather than a wish.

**Deferred, filed as issues, not built:** the ten domain issues in section 1, the HTML control page for the simulator, Sentry breadcrumbs from the `BlocObserver`, device location as an optional way to confirm which yard you are standing in, and the platform-channel reading exercise. Nothing on this list blocks the repo being shown.

**Repo standards live in their own file, `repo-standards.md`, which travels with this one.** It carries the README standard, the build log standard and the style rules. The short version: shortcomings stated plainly rather than spun, no fabricated claims, and never lead with generation time, since a wall-clock number only ever appears next to its verification cost. Run once on the iOS Simulator and once on an Android emulator before calling the README done, since both platforms are the claim.

**If it finishes early**, the stretch is syntax reps BY HAND, not more features through the tooling. Either a hand-written extension to this app or a small separate project. The tooling gives breadth; unaided writing is what evaporates first under observation.

---

## 8. The build order, and the stopping rule

The earlier iterations had every ingredient and no sequence, so this section exists to hold one. Nothing here is new work. It is the order the rest of the document implies.

### Day one, before any feature code

1. **Name the repo.** It has no name and nothing downstream can start without one, because the scaffold command takes it. `Hum` is a recorded candidate, not a decision. Pick one, write it in the README's first line, move on. Do not spend an hour here.
2. **Verify the environment** against the table in section 3. Do not re-install anything.
3. **Fix or accept the MCP connection failure** in section 3. Ten minutes, then move on either way.
4. **Scaffold.** `very_good create flutter_app <name>` in a terminal, typed by hand, so you watch it happen. It goes in its own directory under `~/Dev/`, with its own git history, never inside another repo's tree. Read the generated tree before anything else touches it.
5. **Copy this file, `repo-standards.md` and `CLAUDE-starter.md` into the repo.** The first two go to `docs/`. The third has its body copied to `CLAUDE.md` at the root, with `<name>` replaced. A session here inherits nothing otherwise.
6. **`git init`, then the first commit, then the first push.** Confirm `git config user.email` is the personal address first, because fixing it later means a history rewrite.
7. **Install CodeRabbit on the repo.** Free tier, needs the repo public.
8. **File the ten open issues from section 1,** a paragraph each, and the four slice issues.

### Then, in order

| Step | What | Gate before moving on |
|---|---|---|
| 1 | `/brainstorm` with this file as the input | A brainstorm artifact on disk you would defend |
| 2 | **Hand-write the domain, the evaluator and the false-positive policy, cold, inside `app/lib/`** | Unit tests pass. Written without an agent |
| 3 | **Hand-write `AlertInboxBloc` and its `bloc_test` cases, cold** | Tests pass. Committed before any gate runs |
| 4 | Green Gate, then read its diff against step 2 and 3 | The diff is captured in the README or an issue comment |
| 5 | `/plan` the rest against the brainstorm | A phased plan on disk, one phase per context window |
| 6 | **Slice 1**, inbox on seeded data. `/build`, read every file, `/review`, pull request | Merged. README line written |
| 7 | **Extract `packages/hive_domain/`, timed**, then the simulator's GraphQL read side | Extraction time recorded. `/debrief` run on it |
| 8 | **Slice 2**, alert detail and the chart | Merged. README line written |
| 9 | **Write the sync contract, all eight decisions** | On disk before the next line of code |
| 10 | **Slice 3**, triage Bloc, plus the simulator's REST writes and the bear | Merged. Bear demo runs |
| 11 | `/plan-technical-review` against the hand-written slice four plan | Findings triaged |
| 12 | **Slice 4**, offline and the outbox, plus the chaos knobs | Merged. The kill-the-network demo runs |
| 13 | README, shortcomings, the reviewer comparison table, the iOS and Android runs | Repo is showable |

### The stopping rule

**The repo has to be showable by Sun Sep 20, 2026.** Not finished. Showable: it runs, the README is honest, the open issues are filed, and slice four exists in some form.

If the clock runs out, cut in this order and say so in the README:

1. The Android emulator run and its screenshots.
2. Scenario scripts other than bear.
3. The `YardConditions` rain demo, which becomes issue 1 and nothing else.
4. Peer comparison in the baseline, which becomes issue 9.
5. Slice 2's chart down to a sparkline.

**Never cut:** the hand-written domain and evaluator, `AlertInboxBloc` written cold, the sync contract as a written document, or slice four. Those four are the whole point. A repo with one thin screen and a real offline outbox is worth more than a repo with four polished screens and no outbox.
