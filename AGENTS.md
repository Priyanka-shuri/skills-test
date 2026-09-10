# Billing Agents

Cursor skills and Runlayer agents for the Billing team.

## How to invoke (pick one)

| Method | Where you work | Invoke | Whose credentials? |
|--------|----------------|--------|-------------------|
| **Cursor skill** (recommended) | Any repo | `@wiz-vulnerability-remediation fix wiz for payment-connect` | Yours (Wiz + GitHub via Runlayer) |
| **Runlayer agent** | Runlayer UI or `run_agent` from Cursor | `Fix HIGH+ Wiz for payment-connect` | Agent owner's connectors |
| **Open billing-agents** | This repo | Same `@` skill | Yours |

You do **not** need to open `billing-agents` if you install the skill globally
(see [One-time setup](#one-time-setup)) or use the published Runlayer agent.

### One-time setup

**Per-user (recommended)** — skill available in every Cursor workspace:

```bash
git clone git@github.com:MYOB-Technology/billing-agents.git ~/Projects/billing-agents
ln -s ~/Projects/billing-agents/.cursor/skills/wiz-vulnerability-remediation \
      ~/.cursor/skills/wiz-vulnerability-remediation
```

Authenticate **Wiz** and **GitHub** in the Runlayer plugin (Cursor MCP settings).

**Team Runlayer org skill** — maintainer publishes after [docs/TESTING.md](docs/TESTING.md):
[docs/PUBLISH.md](docs/PUBLISH.md)

## Prerequisites

1. **Cursor** with the **Runlayer** plugin enabled.
2. **Runlayer connectors** authenticated in Cursor MCP settings:
   - **Wiz** — read vulnerability findings for repos your account can see.
   - **GitHub** — read files, create branches, push commits, open PRs.

## Available skills

| Skill | Invoke | Purpose |
|-------|--------|---------|
| `wiz-vulnerability-remediation` | `@wiz-vulnerability-remediation` | Query Wiz for a repo, fix findings, open a PR |

Skill files live in `.cursor/skills/`.

## Runlayer agents

| Agent | Definition | Publish guide |
|-------|------------|---------------|
| Billing Wiz Remediation | [`agents/billing-wiz-remediation/prompt.md`](agents/billing-wiz-remediation/prompt.md) | [`setup.md`](agents/billing-wiz-remediation/setup.md) |

## Wiz vulnerability remediation

Fix Wiz-reported issues for **any** billing repository by name. You do not need
the target repo checked out locally — the skill uses GitHub to read and push
changes. If the target repo **is** your open workspace, it fixes files locally
instead.

### Example prompts

```
@wiz-vulnerability-remediation fix Wiz vulnerabilities for payment-connect

@wiz-vulnerability-remediation check HIGH+ Wiz issues for MYOB-Technology/billing-notification-service-adapter and open a PR

@wiz-vulnerability-remediation triage Wiz findings for self-portal-bff — suggest only, no PR
```

### Repo name formats

| Input | Resolved as |
|-------|-------------|
| `payment-connect` | `MYOB-Technology/payment-connect` (default owner from config) |
| `MYOB-Technology/payment-connect` | As given |
| `this repo` | From `git remote` of the open workspace |

### Configuration

Team defaults: [`config/defaults.json`](config/defaults.json)

| Field | Default | Description |
|-------|---------|-------------|
| `githubOwner` | `MYOB-Technology` | Owner when only repo short name is given |
| `defaultBranch` | `main` | PR base branch |
| `severityMin` | `HIGH` | Minimum severity to fix |
| `allowedOwners` | `["MYOB-Technology"]` | GitHub org allowlist |
| `allowedRepoNamePrefixes` | billing repo prefixes | Repo name allowlist |
| `maxFindingsPerPr` | `5` | Cap per pull request |
| `draftPr` | `true` | Draft PR by default |
| `requireUserConfirmationBeforePr` | `true` | Confirm before GitHub writes |

Override in the prompt: `MEDIUM+`, `base branch develop`, `draft PR`, `max 3 findings`.

### What it does

1. Queries Wiz (your credentials) for open findings on the target repo.
2. Triages fixable SCA / IaC issues with vendor fixes available.
3. Updates dependency manifests (Gradle, npm, Maven, Docker, etc.).
4. Creates a branch and opens a **PR for review** — never merges.

### What it does not do

- Auto-merge PRs or resolve findings in the Wiz UI.
- Fix issues with no vendor fix or that need non-code changes.

The **Runlayer agent** variant uses the agent owner's connectors — not per-user
tokens. Use the **Cursor skill** path when PRs must be in the developer's name.

## Contributing

Add new skills under `.cursor/skills/<skill-name>/` with a `SKILL.md` frontmatter
and update this file. Keep skills focused; use separate files for tool references
and templates.
