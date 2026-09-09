# Testing before Runlayer publish

Test in order. Do **not** publish until Phase 4 passes.

## Phase 1 — Local validation (no Runlayer)

From `billing-agents`:

```bash
./scripts/validate-skill.sh
```

**Pass criteria:** exit code 0, all checks OK.

---

## Phase 2 — Connector smoke tests (your Runlayer auth)

Run these in **Cursor chat** with Runlayer plugin connected (Wiz + GitHub authenticated).
Use **triage only** — no branches, no PRs.

### 2a. Wiz — repo has findings (or empty is OK)

Prompt:

```
Using Runlayer Wiz only: call list_vulnerability_findings_grouped with
group_by VCS_REPOSITORY, asset_names_contains ["payment-connect"],
status OPEN, first 5. Summarize count and severities only.
```

**Pass criteria:**

- Tool call succeeds (no auth error).
- Response mentions `payment-connect` or states zero open findings clearly.

### 2b. Wiz — SCA libraries

```
Using Runlayer Wiz only: call list_sca_library_findings with asset_type
REPOSITORY_BRANCH, status OPEN, severity HIGH and CRITICAL, first 5.
Filter results to payment-connect if possible. Triage only.
```

**Pass criteria:** Tool succeeds; findings listed or explicit empty result.

### 2c. GitHub — read manifest

```
Using Runlayer GitHub only: get_file_contents for MYOB-Technology/payment-connect
path build.gradle.kts ref main. Confirm you can read the file.
```

**Pass criteria:** File content returned (proves your GitHub token can read the repo).

### 2d. GitHub — branch create (dry run cancel)

**Skip unless you want to test write access.** If testing:

```
Using Runlayer GitHub: create_branch test/wiz-skill-smoke-DELETE-ME on
MYOB-Technology/payment-connect from main, then tell me the branch name so I
can delete it manually.
```

**Pass criteria:** Branch created; delete it after test.

---

## Phase 3 — Cursor skill end-to-end (symlink)

### One-time for this test

```bash
ln -sf ~/Projects/billing-agents/.cursor/skills/wiz-vulnerability-remediation \
      ~/.cursor/skills/wiz-vulnerability-remediation
```

Restart Cursor. Open **`payment-connect`** (not billing-agents).

### 3a. Triage only (safe)

```
@wiz-vulnerability-remediation triage Wiz findings for this repo — suggest only, no PR
```

**Pass criteria:**

- Skill loads (follows wiz-tools.md workflow).
- Uses Runlayer Wiz (not web/cli).
- Produces table: CVE, severity, component, fix version, file path.
- Does **not** create branch or PR.

### 3b. Remote repo name (from payment-connect workspace)

```
@wiz-vulnerability-remediation triage HIGH+ Wiz issues for billing-notification-service-adapter — no PR
```

**Pass criteria:** Resolves `MYOB-Technology/billing-notification-service-adapter` from defaults; Wiz query scoped correctly.

### 3c. Fix + PR (optional — use test repo or draft PR)

Only after 3a passes. Prefer a repo with known fixable LOW-risk CVE, or:

```
@wiz-vulnerability-remediation fix Wiz vulnerabilities for payment-connect — draft PR, max 1 finding
```

**Pass criteria:**

- Branch `fix/wiz-*` created.
- PR opened as **draft**.
- PR body matches pr-template.md structure.
- You review and close PR if test-only.

---

## Phase 4 — Runlayer import preview (pre-publish)

**Requires:** `billing-agents` pushed to a **public** GitHub repo (or org-visible per Runlayer policy).

Maintainer in Cursor:

```
fetch_skills_from_url for https://github.com/<org>/billing-agents
```

Then with skill path:

```
fetch_skills_from_url url https://github.com/<org>/billing-agents
skill_path .cursor/skills/wiz-vulnerability-remediation
```

**Pass criteria:**

- Skill discovered with name `wiz-vulnerability-remediation`.
- All files present: SKILL.md, wiz-tools.md, fix-patterns.md, pr-template.md, defaults.json.
- Content matches local repo.

---

## Phase 5 — Publish (maintainer only)

See [PUBLISH.md](PUBLISH.md). Run only after Phases 1–4 pass.

### Post-publish smoke test (second developer)

Another team member (different Wiz/GitHub user):

1. Symlink skill OR rely on Runlayer org skill via `get_skill`.
2. Run Phase 3a from their machine.
3. Confirm findings reflect **their** Wiz visibility (may differ from yours).

---

## Test results log

Record results before publish:

| Phase | Tester | Date | Pass? | Notes |
|-------|--------|------|-------|-------|
| 1 Local | | | | |
| 2a Wiz grouped | | | | |
| 2b Wiz SCA | | | | |
| 2c GitHub read | | | | |
| 3a Triage symlink | | | | |
| 3b Remote repo | | | | |
| 3c PR (optional) | | | | |
| 4 Import preview | | | | |
| 5 Post-publish | | | | |

---

## Current automated status

Run `./scripts/validate-skill.sh` — Phase 1 is automated. Phases 2–4 are manual in Cursor until CI for Runlayer exists.
