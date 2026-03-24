---
name: Dispatch Team Lead
description: >-
  Dispatches autonomous Team Lead agents to AHP servers via ahpx.
  Supports multi-host fleet dispatch with server targeting, session management,
  and remote filesystem browsing. The Team Lead culture lives in
  references/team-lead-culture.md and is injected into every dispatch.
---

# Dispatch Team Lead

Use this skill when you need to dispatch an autonomous Team Lead agent to handle a complex task. Team Leads are senior engineers who own execution end-to-end — you give them direction and context, they figure out the how.

## Prerequisites

Before dispatching, ensure the following are available:

- **ahpx** must be installed — this is the Agent Host Protocol CLI for dispatching agents to AHP servers:
  ```bash
  npm install -g ahpx
  ```
  See [ahpx documentation](https://github.com/nicholasgriffintn/ahpx) for setup details.

- **At least one AHP server** must be running and discoverable. ahpx discovers servers from `~/.ahpx/connections.json`. Run `ahpx status` to check available servers.

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

The dispatch pattern uses `ahpx exec` to create a session on an AHP server with the Team Lead culture injected into the prompt:

```bash
ahpx exec -s <session-name> --cwd <project-dir> "<culture-prompt + task>"
```

**Parameters:**
- `-s <session-name>` — a descriptive session name for observability (e.g., `fix-auth-bug`, `add-user-api`)
- `--cwd <project-dir>` — the project directory to work in. **REQUIRED when targeting remote servers** — the agent needs to know where to operate.
- `--server <server-name>` — target a specific AHP server in your multi-host fleet. Omit to let ahpx auto-select.
- `"<prompt>"` — the combined culture + task prompt

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
ahpx exec -s <session-name> --cwd <project-dir> "<combined prompt>"
```

### Using the dispatch script

For reliable culture injection, use the bundled dispatch script:

```bash
./scripts/dispatch.sh <session-name> <project-dir> "<task>"
```

This automatically reads the Team Lead culture, verifies ahpx is installed, and combines everything into the dispatch prompt.

### Examples

Dispatch to the default server:
```bash
ahpx exec -s add-webhook-support --cwd /path/to/my-api \
  "<full culture> ... George (the CTO) has given you this direction:
Add webhook support for order events. Create POST /webhooks endpoint..."
```

Dispatch to a specific server in your fleet:
```bash
ahpx exec -s fix-auth-bug --server dev-server-2 --cwd /path/to/my-api \
  "<full culture> ... George (the CTO) has given you this direction:
Fix the authentication bug where JWT tokens aren't being refreshed..."
```

> **Note:** The `<full culture>` in the examples represents the FULL contents of `references/team-lead-culture.md`. Never truncate it.

The server doesn't matter — the culture does. Any AHP server will produce a Team Lead when given the culture prompt.

## Remote Filesystem Discovery

When dispatching to remote AHP servers, you may not know the exact filesystem paths. Use `ahpx browse` to discover project locations:

```bash
# Browse the filesystem on a specific server
ahpx browse --server <server-name>

# Browse a specific path
ahpx browse --server <server-name> /home/projects/
```

This is especially useful when managing a multi-host fleet where projects live on different machines.

## Gotchas

- **Never truncate the Team Lead culture.** Agents will try to summarize it to save tokens — include ALL of `references/team-lead-culture.md` in the dispatch prompt. Truncated culture produces agents that skip quality gates.
- **`--cwd` is REQUIRED for remote servers.** Without it, the agent won't know where to operate. Always specify the project directory when dispatching to remote AHP servers.
- **Verify ahpx is installed before first dispatch.** Run `ahpx --version`. If it fails, install with `npm install -g ahpx`. A missing ahpx produces cryptic "command not found" errors.
- **Don't dispatch for trivial tasks.** Single-file edits, quick lookups, simple questions — handle these yourself. Team Leads will over-engineer simple tasks because the culture tells them to invest in expertise and create PRs.
- **Session names must be unique.** If you reuse a session name, ahpx may resume an old session instead of starting fresh. Use descriptive, task-specific names like `fix-auth-bug` or `add-dark-mode`.

## Session Management

ahpx provides session management for observability into dispatched agents:

```bash
# List all sessions
ahpx sessions list

# Check the status of a specific session
ahpx sessions status -s <session-name>

# View the history of what happened in a session
ahpx sessions history <session-name>
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
