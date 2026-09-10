#!/usr/bin/env bash
# Validates wiz-vulnerability-remediation skill structure before Runlayer publish.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$ROOT/.cursor/skills/wiz-vulnerability-remediation"
ERRORS=0

err() { echo "FAIL: $1" >&2; ERRORS=$((ERRORS + 1)); }
ok() { echo "OK:   $1"; }

echo "=== Skill structure validation ==="

[[ -f "$SKILL_DIR/SKILL.md" ]] && ok "SKILL.md exists" || err "missing SKILL.md"

for f in wiz-tools.md defaults.json remediate.md fix-patterns.md pr-template.md; do
  [[ -f "$SKILL_DIR/$f" ]] && ok "$f exists" || err "missing $f"
done

# Frontmatter checks
if grep -q '^name: wiz-vulnerability-remediation' "$SKILL_DIR/SKILL.md" 2>/dev/null; then
  ok "SKILL.md has name frontmatter"
else
  err "SKILL.md missing name: wiz-vulnerability-remediation"
fi

if grep -q '^description:' "$SKILL_DIR/SKILL.md" 2>/dev/null; then
  ok "SKILL.md has description frontmatter"
else
  err "SKILL.md missing description"
fi

# Runlayer publish set (triage only — no remediate.md)
for f in SKILL.md wiz-tools.md defaults.json; do
  [[ -f "$SKILL_DIR/$f" ]] && ok "Runlayer publish file: $f" || err "missing Runlayer publish file: $f"
done

if grep -q 'remediate.md' "$SKILL_DIR/SKILL.md" 2>/dev/null; then
  err "SKILL.md must not reference remediate.md (Runlayer scanner)"
else
  ok "SKILL.md has no remediate.md reference"
fi

for phrase in create_pull_request create_branch push_files fix-patterns pr-template; do
  if grep -qi "$phrase" "$SKILL_DIR/SKILL.md" "$SKILL_DIR/wiz-tools.md" 2>/dev/null; then
    err "Runlayer publish files must not mention $phrase"
  else
    ok "no $phrase in Runlayer publish files"
  fi
done

# Config
if [[ -f "$ROOT/config/defaults.json" ]]; then
  if python3 -c "import json; json.load(open('$ROOT/config/defaults.json'))" 2>/dev/null; then
    ok "config/defaults.json is valid JSON"
  else
    err "config/defaults.json is invalid JSON"
  fi
else
  err "missing config/defaults.json"
fi

if python3 -c "import json; d=json.load(open('$SKILL_DIR/defaults.json')); assert d.get('githubOwner') == 'MYOB-Technology'" 2>/dev/null; then
  ok "defaults.json has githubOwner MYOB-Technology"
else
  err "defaults.json must set githubOwner to MYOB-Technology"
fi

SCAN_FILES="$SKILL_DIR/SKILL.md $SKILL_DIR/wiz-tools.md"
if ! grep -qiE 'override|ignore (previous|all) instruction|prompt injection|untrusted input|guardrail bypass|privilege escalation' $SCAN_FILES 2>/dev/null; then
  ok "no scanner-trigger phrases in Runlayer publish files"
else
  err "remove scanner-trigger phrasing from SKILL.md or wiz-tools.md"
fi

lines=$(wc -l < "$SKILL_DIR/SKILL.md" | tr -d ' ')
if [[ "$lines" -le 500 ]]; then
  ok "SKILL.md line count ($lines) <= 500"
else
  err "SKILL.md too long ($lines lines)"
fi

echo ""
if [[ "$ERRORS" -eq 0 ]]; then
  echo "All checks passed."
  exit 0
else
  echo "$ERRORS check(s) failed."
  exit 1
fi
