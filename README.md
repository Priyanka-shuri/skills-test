# billing-agents

Billing team **Cursor skills and Runlayer agents**. Invoke security workflows
against any billing repo by name — without opening this repository every time.

## Invoke from any repo (recommended)

**One-time setup** — symlink the skill globally:

```bash
ln -s ~/Projects/billing-agents/.cursor/skills/wiz-vulnerability-remediation \
      ~/.cursor/skills/wiz-vulnerability-remediation
```

Then from **any** workspace (e.g. `payment-connect`):

```
@wiz-vulnerability-remediation fix Wiz vulnerabilities for payment-connect
```

Uses **your** Runlayer Wiz + GitHub credentials.

## Or use the Runlayer agent

Publish **Billing Wiz Remediation** as a public Runlayer agent (see
[`agents/billing-wiz-remediation/setup.md`](agents/billing-wiz-remediation/setup.md)).
Team invokes from the Runlayer UI or via `run_agent` — uses the agent's
connectors (shared service account), not per-user tokens.

## Prerequisites

1. **Runlayer** plugin in Cursor with **Wiz** and **GitHub** authenticated.
2. For the Runlayer agent path: maintainer publishes skill + agent once.

## Documentation

- **[AGENTS.md](AGENTS.md)** — skill catalog, prompts, configuration
- **[docs/TESTING.md](docs/TESTING.md)** — test plan before Runlayer publish
- **[docs/PUBLISH.md](docs/PUBLISH.md)** — publish Runlayer org skill (after testing)
- **[agents/billing-wiz-remediation/setup.md](agents/billing-wiz-remediation/setup.md)** — optional Runlayer agent

## Layout

```
.cursor/skills/              # Cursor skills (@wiz-vulnerability-remediation)
agents/billing-wiz-remediation/  # Runlayer agent prompt + publish guide
config/defaults.json         # Team defaults
AGENTS.md
```
