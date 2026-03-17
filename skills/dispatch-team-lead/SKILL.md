---
name: Dispatch Team Lead
description: >-
  Dispatches autonomous Team Lead agents via acpx for complex tasks.
  Supports any acpx agent (copilot, claude, codex, pi, gemini, cursor, etc.).
  The Team Lead culture lives in references/team-lead-culture.md and is
  injected into every dispatch — Team Leads own execution end-to-end.
---

# Dispatch Team Lead

Use this skill when you need to dispatch an autonomous Team Lead agent to handle a complex task. Team Leads are senior engineers who own execution end-to-end — you give them direction and context, they figure out the how.

## Prerequisites

Before dispatching, ensure the following are available:

- **acpx** must be installed — this is the universal session layer for dispatching agents:
  ```bash
  npm install -g acpx
  ```
  See [acpx documentation](https://github.com/openclaw/acpx) for setup details.

- **At least one supported coding agent** must be available on the system. acpx supports:
  - `copilot` — GitHub Copilot CLI
  - `claude` — Anthropic Claude Code
  - `codex` — OpenAI Codex CLI
  - `pi` — Inflection Pi
  - `gemini` — Google Gemini CLI
  - `cursor` — Cursor Agent
  - And others as acpx adds support — run `acpx --help` to see the current list

## When to Dispatch a Team Lead

Dispatch a Team Lead when:

- **The task requires multiple steps** — implementation, testing, review, and shipping
- **The task needs autonomous decision-making** — architecture choices, testing strategy, refactoring decisions
- **You want quality enforcement built in** — Team Leads carry the development culture (quality over everything, test diversity, self-review, branch policy)
- **The task should run independently** — you want to hand it off and get a structured summary when it's done

Don't dispatch a Team Lead for:
- Simple one-file edits or quick fixes
- Questions that only need research (use an explore agent instead)
- Tasks where you need real-time control over every step

## How to Dispatch

The dispatch pattern uses acpx to spawn an agent with the Team Lead culture injected into the prompt:

```bash
acpx <agent> -s <session-name> --approve-all --cwd <project-dir> exec "<culture-prompt + task>"
```

**Parameters:**
- `<agent>` — any acpx-supported agent: `copilot`, `claude`, `codex`, `pi`, `gemini`, `cursor`, etc.
- `-s <session-name>` — a descriptive session name for observability (e.g., `fix-auth-bug`, `add-user-api`)
- `--approve-all` — lets the Team Lead execute autonomously without approval prompts
- `--cwd <project-dir>` — the project directory to work in
- `exec "<prompt>"` — the combined culture + task prompt in quotes

### Building the Dispatch Prompt

The Team Lead culture lives in `references/team-lead-culture.md`. Read the FULL contents of `references/team-lead-culture.md`. Never truncate or summarize it — the complete culture must be injected into every dispatch prompt. This is what transforms a generic agent into a Team Lead.

**Step 1:** Read the FULL contents of `references/team-lead-culture.md`.

**Step 2:** Combine the culture with your task:

```
<full contents of references/team-lead-culture.md>

---

George (the CTO) has given you this direction:

<your task description>
```

**Step 3:** Dispatch with the combined prompt:

```bash
acpx <agent> -s <session-name> --approve-all --cwd <project-dir> exec "<combined prompt>"
```

### Using the dispatch script

For reliable culture injection, use the bundled dispatch script:

```bash
./scripts/dispatch.sh <agent> <session-name> <project-dir> "<task>"
```

This automatically reads the Team Lead culture, verifies acpx is installed, and combines everything into the dispatch prompt.

### Examples

With **copilot**:
```bash
acpx copilot -s add-webhook-support --approve-all --cwd /path/to/my-api \
  exec "<full culture> ... George (the CTO) has given you this direction:
Add webhook support for order events. Create POST /webhooks endpoint..."
```

With **claude**:
```bash
acpx claude -s fix-auth-bug --approve-all --cwd /path/to/my-api \
  exec "<full culture> ... George (the CTO) has given you this direction:
Fix the authentication bug where JWT tokens aren't being refreshed..."
```

> **Note:** The `<full culture>` in the examples represents the FULL contents of `references/team-lead-culture.md`. Never truncate it.

The agent doesn't matter — the culture does. Any acpx-supported agent will behave as a Team Lead when given the culture prompt.

## Gotchas

- **Never truncate the Team Lead culture.** Agents will try to summarize it to save tokens — include ALL of `references/team-lead-culture.md` in the dispatch prompt. Truncated culture produces agents that skip quality gates.
- **`--approve-all` is required.** Without it, the dispatched agent stalls waiting for approval prompts that nobody will answer. The session will hang until timeout.
- **Verify acpx is installed before first dispatch.** Run `acpx --version`. If it fails, install with `npm install -g acpx`. A missing acpx produces cryptic "command not found" errors.
- **Don't dispatch for trivial tasks.** Single-file edits, quick lookups, simple questions — handle these yourself. Team Leads will over-engineer simple tasks because the culture tells them to invest in expertise and create PRs.
- **Session names must be unique.** If you reuse a session name, acpx may resume an old session instead of starting fresh. Use descriptive, task-specific names like `fix-auth-bug` or `add-dark-mode`.

## Session Management

acpx provides session management for observability into dispatched agents:

```bash
# List all sessions for an agent
acpx <agent> sessions list

# Check if a specific session is still running
acpx <agent> status -s <session-name>

# View the history of what happened in a session
acpx <agent> sessions history <session-name>
```

Use descriptive session names (`fix-auth-bug`, `add-webhook-support`, `refactor-payments`) so you can easily identify what each dispatched Team Lead is working on.

## Writing Good Dispatch Prompts

Team Leads are autonomous — they don't need step-by-step instructions. Give them **what** and **why**, not **how**.

### ✅ Good prompts

```
"Add rate limiting to the API. We're getting hammered by a single client making
thousands of requests per minute. Use a sliding window approach, return 429 with
Retry-After headers, and make the limits configurable per-route."
```

```
"Fix the flaky test in auth.test.ts. It passes locally but fails in CI about 30%
of the time. Likely a timing issue with the token expiry mock."
```

### ❌ Bad prompts

```
"Open auth.ts, go to line 45, change the timeout from 30 to 60."
```
→ Too prescriptive. Just tell the Team Lead what's wrong and let them decide the fix.

```
"Do stuff with the API."
```
→ Too vague. Team Leads need clear context about what and why.

## What You Get Back

When a Team Lead finishes, it provides a structured summary:

```
## Agent Summary
**Status:** completed (or failed)
**What was done:** Brief description
**What worked:** What went well
**What failed:** Any issues encountered
**Follow-up recommendations:** Next steps or remaining debt
```

Plus a detailed report covering implementation, testing, tradeoffs, and any technical debt.
