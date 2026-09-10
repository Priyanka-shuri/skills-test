# Publishing to Runlayer org

**Gate:** Complete [TESTING.md](TESTING.md) Phases 1–4 before following this guide.

## What gets published

**Runlayer import (triage only — lower risk score):**

```
.cursor/skills/wiz-vulnerability-remediation/
├── SKILL.md          ← publish
├── wiz-tools.md      ← publish
└── defaults.json     ← publish
```

**Cursor symlink only (not uploaded to Runlayer):**

```
├── remediate.md
├── fix-patterns.md
└── pr-template.md
```

Upload only the three Runlayer files via `create_skill_file`. Keep remediation
files in git for developers who symlink the skill into `~/.cursor/skills/`.

This is **not** a Runlayer agent. Developers use their own Wiz/GitHub auth via the Runlayer plugin in Cursor.

**Runlayer org skill vs Cursor symlink — pick one per developer:**

| Delivery | Clone + symlink needed? | How to invoke |
|----------|-------------------------|---------------|
| **Runlayer org skill** (this guide) | **No** | Ask Cursor to follow the org skill by name (see step 4) |
| **Cursor `@` skill** | **Yes** (symlink or copy into `.cursor/skills/`) | `@wiz-vulnerability-remediation ...` |

Publishing to Runlayer does **not** automatically enable `@wiz-vulnerability-remediation` in Cursor. The `@` picker only sees skills on disk (`~/.cursor/skills/` or the repo's `.cursor/skills/`).

## Prerequisites

- [ ] `billing-agents` merged to `main` on GitHub
- [ ] Repo is **public** (required for `fetch_skills_from_url` anonymous import)
- [ ] [TESTING.md](TESTING.md) phases 1–4 logged as pass
- [ ] Runlayer workspace admin or skill-create permission

## Publish steps (maintainer)

### 1. Preview import

In Cursor with Runlayer:

```
fetch_skills_from_url url https://github.com/MYOB-Technology/billing-agents
```

(Replace org/repo if still on a fork during testing.)

Select skill:

```
fetch_skills_from_url
  url: https://github.com/MYOB-Technology/billing-agents
  skill_path: .cursor/skills/wiz-vulnerability-remediation
```

Verify the 3 Runlayer files (SKILL.md, wiz-tools.md, defaults.json).

### 2. Create org skill

```
create_skill
  name: Billing Wiz Vulnerability Remediation
  description: Report Wiz vulnerability findings for billing repos. Per-user Cursor + Runlayer.
  is_public: true
  import_source_url: <source_url from fetch_skills_from_url>
  auto_update_enabled: true
  confirm: true
```

### 3. Upload skill files

`create_skill` returns an empty SKILL.md. Populate:

1. `update_skill_file` — SKILL.md (full content from repo)
2. `create_skill_file` — wiz-tools.md, defaults.json only (do not upload remediate.md, fix-patterns.md, or pr-template.md)

Or re-sync after `auto_update_enabled` if Runlayer supports directory import from path.

### 4. Announce to team

Share in team channel.

**One-time setup (all developers):**

1. Install the **Runlayer** plugin in Cursor.
2. Authenticate **Wiz** and **GitHub** in Runlayer (Cursor MCP settings).

**Option A — Runlayer org skill only (no clone, no symlink):**

```
Follow the Runlayer skill "Billing Wiz Vulnerability Remediation" and triage Wiz findings for payment-connect — suggest only, no PR
```

Cursor loads the playbook via Runlayer (`get_skill` / `get_skill_file`). Works from **any** workspace.

**Option B — Cursor `@` skill (optional, nicer UX):**

Only needed if the team wants `@wiz-vulnerability-remediation`:

```bash
git clone git@github.com:MYOB-Technology/billing-agents.git ~/Projects/billing-agents
ln -sf ~/Projects/billing-agents/.cursor/skills/wiz-vulnerability-remediation \
      ~/.cursor/skills/wiz-vulnerability-remediation
```

Then:

```
@wiz-vulnerability-remediation triage Wiz findings for payment-connect — no PR
```

Option B duplicates content that Option A already serves from Runlayer. Most teams choose **A only** after publish.

### 5. Post-publish verification

Second developer runs [TESTING.md](TESTING.md) Phase 5.

## Updating after publish

1. Merge changes to `billing-agents` `main`.
2. If `auto_update_enabled`: wait for hourly sync, or trigger manual re-sync in Runlayer.
3. **Option B only:** symlinked Cursor skills pick up git changes after pull / Cursor restart. **Option A:** Runlayer auto-sync updates the org skill.

## Rollback

- Set Runlayer skill `listed_in_workspace: false` or delete via Runlayer admin.
- Developers on Option B can keep using the symlink from git until removed. Option A users are unaffected.

## Not in scope for this publish

- Runlayer agent (`agents/billing-wiz-remediation/`) — optional later, uses shared connectors.
- Auto-merge or Wiz finding resolution in Wiz UI.
