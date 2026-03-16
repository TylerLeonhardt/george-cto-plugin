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

A skill (`skills/dispatch-team-lead/`) that teaches other agents how to spawn Team Leads. Includes:

- When to dispatch a Team Lead vs. handling it yourself
- How to use `acpx` and `copilot` CLI to spawn them
- How to write good dispatch prompts (what + why, not step-by-step how)
- Examples of effective and ineffective prompts

### 🔒 Quality Hooks

Automated quality enforcement (`hooks/`) that runs alongside your agents:

- **Post-tool lint** — automatically lints files after every edit/create operation. Detects your project's linter (Biome, ESLint, Deno) and package manager (npm, pnpm, yarn, bun).
- **Session-end tests** — runs the full test suite and typecheck when an agent session ends. Supports Node.js (npm/pnpm/yarn/bun), Rust (cargo), Go, and Make-based projects.

## Quick Start

### Manual Installation

Clone this repo and reference it from your project:

```bash
git clone https://github.com/TylerLeonhardt/george-cto-plugin.git
```

Copy what you need into your project's `.github/` directory:

```bash
# Copy the Team Lead agent
cp -r george-cto-plugin/agents/team-lead your-project/.github/agents/

# Copy quality hooks
cp -r george-cto-plugin/hooks your-project/.github/hooks/

# Copy the dispatch skill
cp -r george-cto-plugin/skills/dispatch-team-lead your-project/.github/skills/
```

### Using with Copilot CLI

Run a Team Lead directly:

```bash
copilot --plugin-dir george-cto-plugin/agents --agent team-lead/team-lead \
  -p "Add authentication middleware with JWT support and write integration tests" \
  --allow-all
```

### Using with `acpx`

Dispatch a Team Lead for autonomous execution:

```bash
acpx copilot -s add-auth --approve-all --cwd ./my-project \
  exec "Add authentication middleware with JWT support and write integration tests"
```

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
