# Hunt Loop - find and kill a bug

Use for a defect: something misbehaves and the cause is unknown. Not for a feature.

## 1. Reproduce first

No fix before a reproduction. Get to a single command or a written sequence that fails
reliably, and record it.

Cannot reproduce? That is the whole task until it is solved. Gather the version, the
config, the exact input, the full error with stack. Ask for them if missing. A fix
built on a guess cannot be verified, so it is not a fix.

Intermittent? Find the condition that makes it deterministic (ordering, timing, cache
state, a specific record). "Sometimes" is a clue, not an obstacle.

## 2. Bisect to the smallest failing case

Shrink the reproduction until nothing more can be removed without the failure
disappearing. Strip inputs, layers, config. In parallel, if the code used to work,
`git bisect` or read the history of the file to find the commit that changed behaviour.

**Gate:** you have a minimal failing case and know which layer owns the failure.

## 3. Find the root cause, not the symptom

State the mechanism in one sentence: "X is null here because Y returns early when Z,
and the caller assumes it never does."

Then check the blast radius before writing anything: grep every caller of the function
at fault. Almost always the same latent bug reaches callers the ticket never mentioned.
A guard in the shared function is both the smaller diff and the complete fix.

**Gate:** you can explain the mechanism, and you know the full caller list. If your
explanation contains "somehow" or "for some reason", you are at a symptom, keep going.

## 4. Fix at the root

Smallest change at the place all the broken paths route through. Fix the class of bug,
not the instance, when they cost the same.

If the correct fix is genuinely too large for now, say so, apply the narrow fix, mark it
with a `shortcut:` comment naming the unfixed siblings, and report both.

## 5. Prove it, both directions

- The reproduction from step 1 now passes.
- Leave a regression check behind that fails against the OLD code. If it passes either
  way, it does not test the bug. Verify that by reverting the fix, watching the check
  fail, and reapplying.
- Run the repo's existing tests. A fix that breaks two other things is not done.

**Gate:** you watched the regression check fail without the fix and pass with it.

## 6. Report

Symptom, root cause mechanism in one sentence, the fix, the sibling callers you also
covered, the regression check and how to run it. If the bug had a marked shortcut as
its origin, say so; that is how the ledger earns its keep.
