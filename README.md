# george-cto-plugin

**Your AI agents need a CTO.**

AI coding agents are powerful, but without leadership they produce inconsistent work — skipping tests, pushing to main, hardcoding assumptions, and leaving debt everywhere. This plugin gives your agents a development culture.

## What's Inside

### 🧑‍💼 Team Lead Agent

A production-tested agent identity (`agents/team-lead/`) that transforms any AI coding agent into a senior Team Lead who:

- **Owns execution end-to-end** — plans the approach, implements with tests, reviews their own work, and ships clean code
- **Manages subagents as their engineering team** — delegates research, implementation, and review to specialized agents
- **Follows the VS Code Development Cycle** — plan → implement with tests → holistic testing → clean up debt → report back
- **Enforces quality gates** — tests pass, lint passes, CI is green before merging. No exceptions.
- **Carries product thinking** — doesn't just make code work, thinks about naming, architecture, scalability, and the next developer who reads it

### 📋 Dispatch Skill

A skill (`skills/dispatch-team-lead/`) that teaches other agents how to spawn Team Leads via [acpx](https://github.com/openclaw/acpx). Includes:

- When to dispatch a Team Lead vs. handling it yourself
- How to dispatch via `acpx` with **any supported agent** (copilot, claude, codex, pi, gemini, cursor, etc.)
- How to inject the Team Lead culture into the dispatch prompt
- How to write good dispatch prompts (what + why, not step-by-step how)
- Session management for observing dispatched agents

### 🔒 Hooks Awareness

Rather than shipping global hooks (every project has its own linter, test runner, and quality gates), the Team Lead culture teaches agents to **value and invest in hooks** as part of their work:

- **Check for existing hooks** before starting work on any project
- **Respect project hooks** as automated quality gates
- **Create hooks when they're missing** — post-edit lint, session-end tests, pre-commit checks
- **Knows hook locations** for Copilot CLI (`.github/hooks/`), Claude Code (`.claude/hooks/`), and Codex (`.codex/hooks/`)

Hooks belong in the project, not in a global plugin. This keeps quality enforcement tailored to each project's ecosystem.

## Quick Start

### Prerequisites

Install [acpx](https://github.com/openclaw/acpx), the universal session layer for dispatching agents:

```bash
npm install -g acpx
```

You'll also need at least one supported coding agent installed. acpx works with:
- `copilot` — GitHub Copilot CLI
- `claude` — Anthropic Claude Code
- `codex` — OpenAI Codex CLI
- `pi` — Inflection Pi
- `gemini` — Google Gemini CLI
- `cursor` — Cursor Agent
- And others as acpx adds support — run `acpx --help` for the current list

### Install as a Claude Code Plugin (recommended)

Install directly from GitHub:

```
/plugin install george-cto-plugin@george-cto-tools
```

Or add the marketplace first, then install:

```
/plugin marketplace add TylerLeonhardt/george-cto-plugin
/plugin install george-cto-plugin@george-cto-tools
```

Test locally during development:

```bash
claude --plugin-dir ./george-cto-plugin
```

### Install as an Open Plugin

If your tool supports the Open Plugin format (`.plugin/plugin.json`), the plugin is also compatible with that system.

### Manual Installation

Clone this repo and reference it from your project:

```bash
git clone https://github.com/TylerLeonhardt/george-cto-plugin.git
```

Copy what you need into your project's `.github/` directory:

```bash
# Copy the Team Lead agent
cp -r george-cto-plugin/agents/team-lead your-project/.github/agents/

# Copy the dispatch skill
cp -r george-cto-plugin/skills/dispatch-team-lead your-project/.github/skills/
```

### Dispatching a Team Lead with `acpx`

Use acpx to dispatch a Team Lead with any supported agent. The Team Lead culture from `agents/team-lead/team-lead.agent.md` gets prepended to your task prompt:

```bash
acpx <agent> -s <session-name> --approve-all --cwd <project-dir> exec "<culture + task prompt>"
```

**Examples:**

```bash
# With copilot
acpx copilot -s add-auth --approve-all --cwd ./my-project \
  exec "<full culture from team-lead.agent.md>

George (the CTO) has given you this direction:
Add authentication middleware with JWT support and write integration tests."

# With claude
acpx claude -s add-auth --approve-all --cwd ./my-project \
  exec "<full culture from team-lead.agent.md>

George (the CTO) has given you this direction:
Add authentication middleware with JWT support and write integration tests."

# With codex
acpx codex -s add-auth --approve-all --cwd ./my-project \
  exec "<full culture from team-lead.agent.md>

George (the CTO) has given you this direction:
Add authentication middleware with JWT support and write integration tests."
```

The agent doesn't matter — the culture does. See `skills/dispatch-team-lead/SKILL.md` for the full dispatch guide, including how to inject the Team Lead culture into the prompt and manage sessions.

## The Development Culture

This plugin encodes a specific philosophy about how AI agents should work:

**Quality over everything.** A clean, well-tested implementation tomorrow is worth far more than a hacky one now. Agents using this plugin will take the time to do things right.

**Test diversity matters.** Unit tests for pure logic. Integration tests with real dependencies. E2E tests for critical flows. Mocking everything and asserting the mock was called proves nothing.

**Agents push feature branches freely. Direct pushes to main are escalated for approval.** Always a feature branch, always a PR. This is how we maintain quality and enable review.

**Leave the project smarter.** Every agent session should leave behind knowledge — updated docs, new skills, improved tooling. Intelligence compounds.

**Never hardcode assumptions.** Every feature must work for any user, any project, any environment. No hardcoded usernames, paths, or "the user" assumptions.

## What's the Point?

Without a development culture, AI agents are brilliant interns — fast and capable, but they'll cut corners unless someone sets expectations. This plugin is that someone.

With it, every agent you dispatch:
- Writes tests alongside implementation
- Reviews their own code before committing
- Uses feature branches and opens PRs
- Runs lint and tests before shipping
- Documents what they learned for the next agent

It's the difference between "the code compiles" and "I'd bet my weekend on deploying this."

## License

MIT — see [LICENSE](LICENSE).
