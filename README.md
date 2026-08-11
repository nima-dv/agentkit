# agentkit

Cross-project, cross-tool configuration for coding agents. Content lives here; tool
config files are thin pointers to it.

```
C:\code\agentkit\
  AGENTS.md              The rules. Tool-agnostic. Everything points here.
  COORDINATOR.md         The role the top-level session adopts: triage, delegation,
                         model/effort routing, checkpoint reporting.
  SKILLS.md              Generated skill index + broken-reference report.
  agents/                Characters. _TEMPLATE.txt to add one.
  playbooks/             Loops for recurring shapes of work.
  skills/                Skills I own. Junctioned to ~\.claude\skills.
  tools/
    install.ps1          Wires the kit into Claude Code. Idempotent.
    index-skills.ps1     Regenerates SKILLS.md.
    claude/CLAUDE.md     The pointer file install.ps1 copies into ~\.claude.
```

`~\.claude\agents` and `~\.claude\skills` are junctions to this repo, so edits here are
live immediately. Junctions need no admin rights.

## Install

```powershell
C:\code\agentkit\tools\install.ps1
```

Idempotent, and it will not clobber a real directory that has content in it. Keeps one
dated backup of `~\.claude\CLAUDE.md` per change. Rerun it after any installer rewrites
that file, or after moving this repo -- it derives its own location and re-points both
the junctions and the paths inside `CLAUDE.md`.

Discovery is by absolute path from a fixed location, so the working directory is
irrelevant: `claude` reads `~\.claude\CLAUDE.md`, which names this repo directly.

## What loads when

| Tier | What | When |
|---|---|---|
| Always in context | `~\.claude\CLAUDE.md` (~35 lines) | Injected at session start |
| Metadata only | `agents/*.md` frontmatter, skill descriptions | Names and descriptions listed; bodies stay on disk |
| On demand | `AGENTS.md`, `COORDINATOR.md`, `SKILLS.md`, playbooks, agent bodies | When read |

Changes to `~\.claude\CLAUDE.md` and the junctions take effect at the next session start.

## Model routing

| Tier | ID | In / Out per 1M | For |
|---|---|---|---|
| Opus 5 | `claude-opus-5` | $5 / $25 | The ceiling. Hard reasoning, ambiguity, expensive-to-get-wrong |
| Sonnet 5 | `claude-sonnet-5` | $3 / $15 | Well-specified implementation |
| Haiku 4.5 | `claude-haiku-4-5` | $1 / $5 | Mechanical and bounded. 200K context. No `effort` support |

`effort` is `low` / `medium` / `high` / `xhigh` / `max`, orthogonal to tier, on Opus 5
and Sonnet 5 only. Prefer lowering effort over lowering tier. Claude Fable 5 is out of
scope: too expensive.

Characters set their typical `model:` and `effort:` in frontmatter; the coordinator
overrides per call. Full rules in `COORDINATOR.md`.

## Add a character

1. Copy `agents/_TEMPLATE.txt` to `agents/<name>.md`. Only `.md` files in `agents/`
   become selectable agents.
2. Pick skills from `SKILLS.md`. List them in frontmatter `skills:` and restate them in
   the body's Skills table with a trigger condition for each.
3. Set `model:` and `effort:` for the character's typical task.
4. Fill in **Out of scope** and **Done means**.

`agents/atlas.md` and `agents/mercury.md` are worked examples. Mercury is the shape to
copy for a character wrapping a large skill set: skills grouped by direction of work,
each with a trigger condition.

## Add a skill

- Own: create `skills/<name>/SKILL.md` with `name:`, `description:`, optional `trigger:`.
- Third-party: install it, then add its root to the `$roots` table in
  `tools/index-skills.ps1` if the scanner does not already cover it.

Run `tools/index-skills.ps1` after either. The bottom of `SKILLS.md` reports **BROKEN
references** -- slash commands and index files pointing at a `SKILL.md` that does not
exist, which otherwise fail silently.

## Add a playbook

A playbook is a loop with gates and an exit condition.

- `ship-loop.md` -- ticket to merged. The default for defined work.
- `hunt-loop.md` -- find and kill a bug.
- `kaizen-loop.md` -- iterative improvement against a metric.

## Port to another tool

`AGENTS.md` is the portable artifact. To add a tool: create `tools/<tool>/` with that
tool's config file as a pointer to `C:\code\agentkit\AGENTS.md`, then add a line to
`install.ps1` to place it.

Character frontmatter is Claude Code's agent format. Other tools ignore unknown keys and
read the body as a system prompt, so every rule that matters appears in body prose.
