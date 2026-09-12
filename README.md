# keeper

A mock monitoring and field-work app for a beekeeping operation.

'Sensors' on hives report weight, brood temperature, humidity, sound and tilt on a schedule through a gateway at the yard. A backend scores each reading against a baseline for that specific hive and that specific metric, and a reading that departs from its baseline raises an alert. The beekeeper triages the alert and schedules it into the next yard visit.

It helps its user identify, locate and fix a problem. It is not a dashboard. The pitch is inspect when it matters, not on a schedule, because sensors cannot replace an inspection for disease, mite counts or brood pattern. What they do well is tell you when to open a hive and when to leave it alone.

Flutter and Dart, in the four Very Good Ventures layers, with a local simulator standing in for the backend.

## Status

Early. Day one setup. Nothing runs yet.

- Current plan: [`docs/plan/`](docs/plan/)
- Original specification, superseded and kept for reference: [`docs/original-plan.md`](docs/original-plan.md)
- Repo standards: [`docs/repo-standards.md`](docs/repo-standards.md)
- Design decisions: [`docs/brainstorm/`](docs/brainstorm/)

This README is a stub. It gets the full treatment, including shortcomings and build instructions verified from a fresh clone, once there is something to run.
