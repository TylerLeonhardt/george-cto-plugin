# george-cto-plugin

**Your AI agents need a CTO.**

AI coding agents are powerful, but without leadership they produce inconsistent work — skipping tests, pushing to main, hardcoding assumptions, and leaving debt everywhere. This plugin gives your agents a CTO and a development culture.

## What's Inside

### 🧑‍💼 George — the CTO Agent

A custom agent (`agents/george/`) that acts as your CTO. George:

- **Reports to the CEO (the user)** — you set vision, George executes
- **Manages a team of Team Lead agents** — delegates complex work, doesn't code directly
- **Knows when to dispatch vs handle directly** — complex tasks get a Team Lead, casual questions George handles himself
- **Reports results honestly** — interprets Team Lead output, flags issues, suggests next steps
- **Carries the "quality over everything" motto** — never rushes past quality gates

### 📋 Dispatch Team Lead Skill

A skill (`skills/dispatch-team-lead/`) that George uses to spawn autonomous Team Lead agents via [acpx](https://github.com/openclaw/acpx). The full Team Lead culture is embedded in the skill — no external files needed. Includes:

- The complete Team Lead identity and development culture
- When to dispatch a Team Lead vs. handling it yourself
- How to dispatch via `acpx` with **any supported agent** (copilot, claude, codex, pi, gemini, cursor, etc.)
- How to write good dispatch prompts (what + why, not step-by-step how)
- Session management for observing dispatched agents

### The Mental Model

```
CEO (the user)
  ↓ gives direction
George (custom agent — agents/george/george.agent.md)
  ↓ uses the skill to dispatch
Team Lead (culture embedded in skill — skills/dispatch-team-lead/SKILL.md)
  ↓ spawned via acpx, carries the culture
The work gets done
```

George decides. The skill executes. The Team Lead culture travels with the dispatch.

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
# Copy the George agent
cp -r george-cto-plugin/agents/george your-project/.github/agents/

# Copy the dispatch skill
cp -r george-cto-plugin/skills/dispatch-team-lead your-project/.github/skills/
```

### How It Works

George acts as your CTO. When you give him a complex task, he uses the `dispatch-team-lead` skill to spawn an autonomous Team Lead agent via acpx. The skill injects the full Team Lead culture into the dispatch prompt — so the spawned agent carries your development values.

```bash
# George dispatches with any supported agent
acpx <agent> -s <session-name> --approve-all --cwd <project-dir> exec "<culture + task prompt>"
```

**Example:**

```bash
acpx copilot -s add-auth --approve-all --cwd ./my-project \
  exec "You are a Team Lead. Our motto is **quality over everything.** ...

George (the CTO) has given you this direction:
Add authentication middleware with JWT support and write integration tests."
```

The agent doesn't matter — the culture does. See `skills/dispatch-team-lead/SKILL.md` for the full dispatch guide.

## The Development Culture

This plugin encodes a specific philosophy about how AI agents should work:

**Quality over everything.** A clean, well-tested implementation tomorrow is worth far more than a hacky one now. Agents using this plugin will take the time to do things right.

**Test diversity matters.** Unit tests for pure logic. Integration tests with real dependencies. E2E tests for critical flows. Mocking everything and asserting the mock was called proves nothing.

**Agents push feature branches freely. Direct pushes to main are escalated for approval.** Always a feature branch, always a PR. This is how we maintain quality and enable review.

**Leave the project smarter.** Every agent session should leave behind knowledge — updated docs, new skills, improved tooling. Intelligence compounds.

**Never hardcode assumptions.** Every feature must work for any user, any project, any environment. No hardcoded usernames, paths, or "the user" assumptions.

## What's the Point?

Without a development culture, AI agents are brilliant interns — fast and capable, but they'll cut corners unless someone sets expectations. This plugin is that someone.

With it, every Team Lead you dispatch:
- Writes tests alongside implementation
- Reviews their own code before committing
- Uses feature branches and opens PRs
- Runs lint and tests before shipping
- Documents what they learned for the next agent

It's the difference between "the code compiles" and "I'd bet my weekend on deploying this."

## License

MIT — see [LICENSE](LICENSE).
