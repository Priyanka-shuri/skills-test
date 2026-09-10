# Connector allowlist

Model providers cap tools at **128**. Attach only the tools below — resolve
`server_id` with `list_servers` (match on server name; do not guess UUIDs).

## Wiz (read-only allowlist)

| Tool |
|------|
| `list_vulnerability_findings_grouped` |
| `list_sca_library_findings` |
| `list_iac_findings` |
| `get_vulnerability_finding` |
| `get_vulnerability_catalog` |

Do **not** attach nested Wiz skills or `get_issue_remediation_options`.

## GitHub

| Tool |
|------|
| `get_file_contents` |
| `create_branch` |
| `create_or_update_file` |
| `push_files` |
| `create_pull_request` |
| `pull_request_read` |
| `search_code` |

Do **not** attach: Runlayer connector, merge tools, or full connector bundles.

## create_agent example

```text
name: Billing Wiz Remediation
is_public: true
listed_in_workspace: true
memory_scopes: []
skill_ids: [<billing-wiz-vulnerability-remediation skill UUID>]
prompt: <contents of prompt.md>
connectors:
  - server: Wiz → tool_names from table above
  - server: GitHub → tool_names from table above
```

## example_prompts

- `Fix HIGH+ Wiz vulnerabilities for payment-connect and open a PR`
- `Remediate Wiz SCA findings for MYOB-Technology/billing-notification-service-adapter`
- `Triage open Wiz issues for self-portal-bff — no PR`
