# Ship Loop - ticket to merged

Default loop for a defined unit of work: a Jira ticket, a feature request, a spec.
Use when the destination is known and the path is not.

Each phase has a gate. Do not cross a gate on optimism.

## 1. Frame

Pull the actual source of truth: the ticket, the linked spec, the thread where it was
decided. Extract and write down:

- Goal in one sentence.
- Acceptance criteria, verbatim where possible.
- Explicitly out of scope.
- Constraints that are not negotiable (API compatibility, wire format, deadline).

**Gate:** you can state what "done" looks like without using the word "working".

## 2. Locate

Find every file the change touches. Trace the real execution path end to end, not the
one the ticket implies. Name the integration points and the existing pattern you will
follow.

**Gate:** you can name the files and the pattern. If the trace surfaced a second
subsystem nobody mentioned, stop and report before designing.

## 3. Design

Only if the change spans more than about three files or introduces a new concept.
Otherwise skip to 4; a design doc for a two-line fix is the over-engineering this kit
exists to prevent.

Cover: components touched, data flow for the main scenario, and three concrete risks
each with a mitigation or an accepted consequence.

**Gate:** design reviewed by me, or explicitly waived.

## 4. Build

Smallest correct diff, per `AGENTS.md` section 2. Match the surrounding code's idiom.
Mark deliberate shortcuts with a `shortcut:` comment naming the ceiling.

Work in vertical slices that each leave the tree building. Never a broken-tree
checkpoint you intend to fix in the next step.

**Gate:** it builds.

## 5. Verify

Run the check. Then run whatever the repo already runs (its test target, its linter).
Cover each acceptance criterion from phase 1 explicitly, one at a time, and say which
command demonstrates it.

**Gate:** the check passes and you watched it pass. A failure here goes back to phase
2, not to a patch on the symptom.

## 6. Review

Read your own diff top to bottom as if someone else wrote it. Hunt specifically for:
leftover debug output, a helper you wrote that already existed, an abstraction with one
caller, a widened scope nobody asked for.

**Gate:** the diff contains nothing you cannot justify in one sentence.

## 7. Hand off

Report: what changed and why, every file touched, the command that proves it works,
what was deliberately left out, and the shortcuts you marked. Update the dossier at
`C:\code\readme\<branch>-README.md`.

Do not commit, push, or open a PR unless asked.

## When it goes sideways

A phase that fails sends you back to the earliest phase whose assumption broke, not
back one step. Verify failing usually means Locate was incomplete. Build ballooning
usually means Frame was vague. Fix the upstream phase; do not grind the current one.
