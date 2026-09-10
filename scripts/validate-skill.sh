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

for f in scope.md wiz-tools.md fix-patterns.md pr-template.md defaults.json; do
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

# Internal links (one level deep)
for link in scope.md wiz-tools.md fix-patterns.md pr-template.md; do
  if grep -q "\\[$link\\]($link)" "$SKILL_DIR/SKILL.md" 2>/dev/null || grep -q "$link" "$SKILL_DIR/SKILL.md" 2>/dev/null; then
    ok "SKILL.md references $link"
  else
    err "SKILL.md should reference $link"
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

# Security defaults
if python3 -c "import json; d=json.load(open('$SKILL_DIR/defaults.json')); assert d.get('draftPr') is True; assert 'allowedOwners' in d" 2>/dev/null; then
  ok "defaults.json has draftPr=true and allowedOwners"
else
  err "defaults.json must set draftPr=true and allowedOwners"
fi

if ! grep -qiE 'override|ignore (previous|all) instruction|prompt injection|untrusted input|guardrail bypass' "$SKILL_DIR/SKILL.md" "$SKILL_DIR/scope.md" 2>/dev/null; then
  ok "no scanner-trigger phrases in SKILL.md or scope.md"
else
  err "remove override/injection phrasing from SKILL.md or scope.md"
fi

if grep -q 'get_issue_remediation_options' "$SKILL_DIR/wiz-tools.md" 2>/dev/null; then
  ok "wiz-tools.md lists out-of-scope tools"
else
  err "wiz-tools.md should list tools not used by this skill"
fi

# Size guard (skill best practice < 500 lines for SKILL.md)
lines=$(wc -l < "$SKILL_DIR/SKILL.md" | tr -d ' ')
if [[ "$lines" -le 500 ]]; then
  ok "SKILL.md line count ($lines) <= 500"
else
  err "SKILL.md too long ($lines lines); split into reference files"
fi

echo ""
if [[ "$ERRORS" -eq 0 ]]; then
  echo "All checks passed."
  exit 0
else
  echo "$ERRORS check(s) failed."
  exit 1
fi
