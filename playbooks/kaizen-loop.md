# Kaizen Loop - continuous improvement on a living system

Use when the goal is "make this better" rather than "build this thing": performance,
flakiness, code health, developer experience, agent config itself. The work has no
natural end, so the loop supplies one.

## Rule zero

One change per lap. A lap that changes three things cannot tell you which one helped.

## The lap

**1. Measure.** Write down the current number before touching anything. Test runtime,
p99 latency, failure rate, build time, line count, whatever the goal is. No number
means no loop; go find one first. Record it in the dossier
(`C:\code\readme\<branch>-README.md`).

**2. Pick the biggest gap.** From the measurement, name the single largest contributor
to the gap between current and target. Not the most interesting one. Not the one you
already have an opinion about. State it in one sentence.

**3. Form a falsifiable hypothesis.** "If I do X, metric M moves from A to B, because C."
If you cannot state the expected magnitude, you are guessing, and step 5 will not be
able to tell you that you guessed wrong.

**4. Smallest change that tests it.** Apply the ladder in `AGENTS.md` section 2. This
is a probe, not a finished feature; it only has to be good enough to move the number.

**5. Measure again, same way.** Same command, same conditions, same machine state.
Then classify honestly:

- Moved as predicted -> keep it. Clean it up to shippable quality now, not later.
- Moved less than predicted -> keep only if the change also stands on its own merit.
  Otherwise revert; a change you cannot explain is debt.
- Did not move, or moved the wrong way -> **revert**. Do not "fix" the probe. Your
  model of the system was wrong; that is the finding.

**6. Write the lap down.** One line in the dossier: metric before, change, metric
after, verdict. This log is the deliverable. Six laps of "reverted, wrong model"
followed by one that worked is a success, and unreadable without the log.

**7. Exit or lap again.** Stop when any of these is true:

- The target is met.
- Three consecutive laps produced no movement. The remaining gap is structural, not
  incremental; report that and propose a design change instead of another lap.
- The cheapest remaining idea costs more than the value of the gap. Say so and stop.

Never lap indefinitely because laps are available.

## Reporting

At exit, report: starting metric, ending metric, number of laps, the laps that worked,
and the laps that were reverted with what each one disproved. The reverted laps are the
part that stops the next person repeating them.
