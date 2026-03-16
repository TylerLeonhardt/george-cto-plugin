---
name: Dispatch Team Lead
description: >-
  Teaches agents how to dispatch autonomous Team Lead agents for complex tasks.
  Team Leads own execution end-to-end — they plan, implement, test, review, and
  ship with full development culture built in.
---

# Dispatch Team Lead

Use this skill when you need to dispatch an autonomous Team Lead agent to handle a complex task. Team Leads are senior engineers who own execution end-to-end — you give them direction and context, they figure out the how.

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

### Option 1: Using `acpx` (recommended for autonomous execution)

```bash
acpx copilot -s <session-name> --approve-all --cwd <project-dir> exec "<task description>"
```

**Parameters:**
- `-s <session-name>` — a descriptive session name (e.g., `fix-auth-bug`, `add-user-api`)
- `--approve-all` — lets the Team Lead execute autonomously without approval prompts
- `--cwd <project-dir>` — the project directory to work in
- `exec "<task>"` — the task description in quotes

**Example:**
```bash
acpx copilot -s add-webhook-support --approve-all --cwd /home/user/my-api exec "Add webhook support for order events. Create POST /webhooks endpoint for registration, implement event dispatch on order create/update/delete, add retry logic with exponential backoff, and write integration tests."
```

### Option 2: Using `copilot` directly with the plugin

```bash
copilot --plugin-dir <path-to-plugin>/agents --agent team-lead/team-lead -p "<task description>" --allow-all
```

**Parameters:**
- `--plugin-dir <path>` — path to the `agents/` directory in this plugin
- `--agent team-lead/team-lead` — selects the Team Lead agent
- `-p "<task>"` — the task prompt
- `--allow-all` — grants full tool access

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

Every Team Lead carries the development culture defined in `agents/team-lead/team-lead.agent.md`. The core values:

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
