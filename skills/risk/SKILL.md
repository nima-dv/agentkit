---
name: risk
description: Feature risk assessor — given a Jira ticket, gathers context from Jira history, Slack, Confluence, and code, then produces a 5-point risk report
trigger: /risk
---

# /risk

Assess the implementation risk of a Jira ticket by gathering context from Jira, Slack, Confluence, and code, then rating risk on a 1–5 scale.

## Usage

```
/risk SB-5457
```

## What You Must Do When Invoked

If no ticket ID is given, ask the user for one before proceeding. Do not invent a ticket ID.

Run all four data-gathering steps. Do them in parallel where possible (Jira + Slack + Confluence can all start at once; code search can follow once you know the ticket's subject matter).

---

### Step 1 — Fetch the Jira ticket

Use `getJiraIssue` (Atlassian Rovo MCP) to fetch the ticket. Extract:
- Summary
- Description
- Type (Story, Bug, Task, etc.)
- Components / labels
- Epic / parent

### Step 2 — Jira history (parallel with Steps 3 and 4)

Search for past tickets related to the same components, keywords, or area of the codebase. You are looking for:
- Past bugs or regressions in this area
- Similar features that caused incidents
- Tickets marked as high complexity or reopened multiple times

Use `searchJiraIssuesUsingJql` with a JQL like:
```
project = SB AND text ~ "<keyword>" AND issuetype in (Bug, Story) AND status in (Done, Closed) ORDER BY updated DESC
```
Run 1–2 searches with different keyword angles from the ticket summary. Fetch up to 10 results per search.

### Step 3 — Slack history (parallel with Steps 2 and 4)

Use `slack_search_public_and_private` to find prior conversations about this feature area. You are looking for:
- Known pain points or complaints
- Past incidents discussed informally
- Warnings or "this is fragile" comments

Search with 1–2 queries derived from the ticket summary or component names.

**Important:** Use Slack for historical signal only. Do not post anything to Slack during this step.

### Step 4 — Confluence (parallel with Steps 2 and 3)

Use `searchConfluenceUsingCql` to find architecture docs, design specs, runbooks, or ADRs related to the ticket's area. Look for:
- Known architectural constraints
- Dependencies that complicate this change
- Prior design decisions that could be violated

### Step 5 — Code search (after Step 1, can overlap with 2–4)

Use `fetch` (GitHub via Atlassian Rovo or GitHub MCP) or the GitHub search API to find files likely touched by this feature. Look for:
- Which modules or services are involved
- Whether the affected code is well-tested or has known tech debt
- Whether this touches shared infrastructure (auth, data pipeline, core algorithms)

---

### Step 6 — Synthesize and score

After collecting all signals, produce the risk report using the format below.

**Risk Score definitions (1–5):**

| Score | Label | Meaning |
|-------|-------|---------|
| 1 | Minimal | Isolated change, well-tested area, no historical issues, clear requirements |
| 2 | Low | Small scope, minor unknowns, tested area, no recent regressions nearby |
| 3 | Moderate | Some unknowns, touches shared code or an area with past bugs, requirements could be clearer |
| 4 | High | Touches core systems, history of regressions in this area, unclear requirements, or cross-team dependencies |
| 5 | Critical | High blast radius, fragile or untested code, unclear requirements, recent instability, or safety-critical path (pipeline inspection data, field hardware) |

**DarkVision context:** DarkVision builds ultrasonic inspection systems for oil & gas pipelines. Changes to signal processing, inspection data, hardware communication, or field-deployment systems carry inherently higher risk. Factor this in.

---

### Output Format

Print this report in the chat. Do NOT post it to Jira or Slack automatically — only do that if the user explicitly asks.

```
═══════════════════════════════════════════════════
RISK ASSESSMENT  ·  <TICKET-ID>
<Ticket summary>
═══════════════════════════════════════════════════

RISK SCORE:  [1–5] / 5  —  <Label>

RISK FACTORS
  • <factor>: <one-sentence explanation>
  • <factor>: <one-sentence explanation>
  (list all that apply; omit categories with no signal)

JIRA HISTORY
  • <ticket key>  <summary>  — <why it's relevant>
  (or "No closely related past issues found.")

SLACK SIGNALS
  • <channel / date>  — <brief paraphrase of relevant discussion>
  (or "No relevant Slack history found.")

CONFLUENCE / ARCHITECTURE
  • <page title>  — <what constraint or concern it surfaces>
  (or "No relevant architecture docs found.")

CODE CONCERNS
  • <file or module>  — <concern: high churn, no tests, shared infra, etc.>
  (or "No code-level concerns identified.")

RECOMMENDED MITIGATIONS
  1. <specific action>
  2. <specific action>
  (list only what's genuinely warranted; skip if score is 1–2 and risks are minimal)

CONFIDENCE:  <Low / Medium / High>
  <One sentence on data quality — what was and wasn't available.>
═══════════════════════════════════════════════════
```

After printing the report, ask: "Want me to post this to the Jira ticket or send it to a Slack channel?"

---

## Honesty Rules

- Never invent Jira tickets, Slack messages, or Confluence pages. If a search returns nothing, say so.
- If the MCP tools are unavailable or return errors, note it in the Confidence line — do not silently skip a data source.
- Do not inflate risk scores to seem thorough. A score of 1 is a valid and useful result.
- Do not deflate risk scores to avoid alarming the team. Call it as the evidence shows.
