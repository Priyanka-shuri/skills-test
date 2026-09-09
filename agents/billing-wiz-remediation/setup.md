# Publishing the Billing Wiz Remediation agent

Two ways to invoke without opening `billing-agents` in Cursor. Pick based on
whether you need **per-user credentials** or **one-click team invoke**.

## Comparison

| Approach | Invoke from | Whose Wiz/GitHub token? | Best for |
|----------|-------------|-------------------------|----------|
| **A. Runlayer org skill** (recommended) | Any Cursor workspace | Each developer's | Per-user auth, PRs in your name |
| **B. Runlayer public agent** | Runlayer UI or `run_agent` | Agent owner's connectors | Shared service account, scheduled runs |

You can publish **both**: skill for daily dev work, agent for automation with a
dedicated service identity.

---

## A. Runlayer org skill (per-user tokens)

Publishes the playbook once; each developer invokes from **any repo** in Cursor.

### One-time (maintainer)

1. Push `billing-agents` to GitHub.
2. In Runlayer, import the skill:
   - `fetch_skills_from_url` → `https://github.com/MYOB-Technology/billing-agents`
   - `create_skill` with `import_source_url`, `is_public: true`, `auto_update_enabled: true`
   - Copy skill files from `.cursor/skills/wiz-vulnerability-remediation/` via
     `create_skill_file` / `update_skill_file`, or re-import after each release.

### One-time (each developer)

Choose **one**:

**Global Cursor skill (simplest)** — skills available in every workspace:

```bash
ln -s ~/Projects/billing-agents/.cursor/skills/wiz-vulnerability-remediation \
      ~/.cursor/skills/wiz-vulnerability-remediation
```

(Adjust clone path. Restart Cursor if needed.)

**Or** rely on Runlayer skill discovery — in any Cursor chat with Runlayer
connected, ask to load the org skill by name before running the workflow.

### Invoke (any repo, e.g. `payment-connect`)

```
@wiz-vulnerability-remediation fix Wiz vulnerabilities for payment-connect
```

No need to open `billing-agents`.

---

## B. Runlayer public agent (team invoke)

Creates a named agent in the Runlayer workspace catalog.

### One-time (maintainer)

1. Publish the org skill (step A above) and note `skill_id`.
2. `list_servers` → resolve Wiz and GitHub `server_id`s.
3. `list_server_tools` → confirm tool names in [connectors.md](connectors.md).
4. `create_agent`:
   - `name`: `Billing Wiz Remediation`
   - `prompt`: contents of [prompt.md](prompt.md)
   - `skill_ids`: `[<skill_id>]`
   - `is_public`: `true`
   - `connectors`: least-privilege allowlists from [connectors.md](connectors.md)
   - `example_prompts`: see connectors.md

5. Share the agent link with the team.

### Invoke

**Runlayer UI** — open **Billing Wiz Remediation**, enter:

```
Fix HIGH+ Wiz vulnerabilities for payment-connect and open a PR
```

**From Cursor** (any workspace):

```
Run the Billing Wiz Remediation agent for payment-connect
```

(Cursor delegates via `list_agents` → `run_agent`; poll `get_agent_run_trace`.)

### Auth note

The agent uses **connectors attached to the agent**, not each invoker's personal
OAuth. For PRs attributed to individuals, use approach **A**. For a shared
SecEng / automation identity, use **B** with a service GitHub account and Wiz
API access on the agent.

---

## Updating

- **Skill**: merge to `billing-agents` main; Runlayer auto-sync if enabled.
- **Agent**: update prompt via `update_agent` when workflow changes; connector
  allowlist rarely changes.
