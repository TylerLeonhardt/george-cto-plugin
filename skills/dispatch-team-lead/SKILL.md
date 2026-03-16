---
name: Dispatch Team Lead
description: >-
  Teaches agents how to dispatch autonomous Team Lead agents via acpx for complex tasks.
  Supports any acpx agent (copilot, claude, codex, pi, gemini, cursor, etc.).
  Team Leads own execution end-to-end — they plan, implement, test, review, and
  ship with full development culture built in.
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

### Injecting the Team Lead Culture

Since acpx dispatches a generic agent session, the Team Lead identity must be injected via the prompt itself. Read the culture from `agents/team-lead/team-lead.agent.md` and prepend it to the task.

**Step 1:** Read the Team Lead agent file to get the culture prompt. The file is at `agents/team-lead/team-lead.agent.md` relative to where this plugin is installed. The content after the YAML frontmatter (`---`) is the culture prompt.

**Step 2:** Combine the culture with your task into a single prompt string:

```
<culture from team-lead.agent.md>

George (the CTO) has given you this direction:

<your task description>
```

**Step 3:** Dispatch with the combined prompt:

```bash
acpx <agent> -s <session-name> --approve-all --cwd <project-dir> exec "<combined prompt>"
```

### Examples

With **copilot**:
```bash
acpx copilot -s add-webhook-support --approve-all --cwd /path/to/my-api \
  exec "<full contents of team-lead.agent.md after the --- frontmatter>

George (the CTO) has given you this direction:
Add webhook support for order events. Create POST /webhooks endpoint for registration,
implement event dispatch on order create/update/delete, add retry logic with exponential
backoff, and write integration tests."
```

With **claude**:
```bash
acpx claude -s fix-auth-bug --approve-all --cwd /path/to/my-api \
  exec "<full contents of team-lead.agent.md after the --- frontmatter>

George (the CTO) has given you this direction:
Fix the authentication bug where JWT tokens aren't being refreshed on 401 responses.
Users are getting logged out mid-session. Add regression tests."
```

With **codex**:
```bash
acpx codex -s refactor-payments --approve-all --cwd /path/to/my-api \
  exec "<full contents of team-lead.agent.md after the --- frontmatter>

George (the CTO) has given you this direction:
Refactor the payment module to support multiple providers. Currently hardcoded to Stripe.
We need PayPal next month — build the abstraction now. Keep Stripe working."
```

> **Note:** The `<full contents of team-lead.agent.md ...>` placeholder represents the entire culture prompt from `agents/team-lead/team-lead.agent.md` — all sections including Your Role, Using Your Subagents, The VS Code Development Cycle, Core Values, Quality Gates, etc. The full file must be included, not just the first line.

The agent doesn't matter — the culture does. Any acpx-supported agent will behave as a Team Lead when given the culture prompt.

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

```
"Refactor the payment module to support multiple payment providers. Currently it's
hardcoded to Stripe. We need to add PayPal next month, so build the abstraction now.
Keep Stripe working — don't break existing tests."
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

## Development Culture

The Team Lead culture is defined in `agents/team-lead/team-lead.agent.md`. When dispatching via acpx, this culture gets injected into the prompt (see [Injecting the Team Lead Culture](#injecting-the-team-lead-culture) above). The core values:

- **Quality over everything** — clean, well-tested implementations over fast hacks
- **The VS Code Development Cycle** — plan → implement with tests → holistic testing → clean up debt → report
- **Test diversity** — unit tests for logic, integration tests with real dependencies, E2E for critical flows
- **Self-review** — Team Leads review their own work before committing, using code-review subagents
- **Branch policy** — always feature branches, always PRs, never push directly to main
- **Leave the project smarter** — document discoveries, create skills, improve tooling for the next Team Lead

## Project Hooks

Projects can have their own automated quality hooks that enforce standards at key points — after edits, before commits, at session end. Team Leads should check for and respect these hooks.

**When dispatching a Team Lead to a project, they will automatically:**
1. Check for existing hooks before starting work
2. Respect any quality gates defined by the project's hooks
3. Consider creating hooks if the project doesn't have them yet

**Hook locations vary by agent platform:**
- **Copilot CLI:** `.github/hooks/hooks.json`
- **Claude Code:** `.claude/settings.json` or `.claude/hooks/`
- **Codex:** `.codex/hooks/` or similar

Hooks belong in the project, not in the plugin — each project has its own linter, test runner, and quality gates. The Team Lead culture teaches agents to value and invest in hooks as part of leaving the project smarter.

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
