# External Skill Review

## Current Allowlist and Decisions

| name | repo | pinned_ref | writes_outside_repo | network_calls | reads_sensitive_paths | default_decision | reason |
|---|---|---|---|---|---|---|---|
| security-best-practices | openai/skills | `736f600bf6ecbc000c04f1d2710b990899f28903` | no | none | none | allow | Official OpenAI curated skill; text-heavy guidance with no bundled hook or deploy behavior in the reviewed skill path. |
| planning-with-files | OthmanAdi/planning-with-files | `bb3a21ab0d3efbfb3f719124644fc2688a3373e4` | yes | none | local session logs | fork-first | Strong pattern, but the reviewed Codex path still references session catchup against Claude/OpenCode storage and reads planning/session data from home directories. |
| superpowers | obra/superpowers | `eafe962b18f6c5dc70fb7c8cc7e83e61f4cdde06` | yes | local-only | none | fork-first | Valuable methodology, but behaviorally invasive; includes hook-based workflow enforcement and optional local brainstorm server. Better to cherry-pick ideas than install whole framework. |
| ContextKit | FlineDev/ContextKit | `759dd8e9d90fbc0a78e106426b958343da264980` | yes | external | none | deny | Project README says it is no longer actively maintained; installer is `curl | bash`; Claude-first workflow with low Codex fit. |
| deploy-to-vercel | vercel-labs/agent-skills | `64484e9a6022c81e3af59f5dcee6fb6d631bf53e` | yes | external | credentials / env files | deny | Explicit deployment/upload skill; packages code, reads deployment tokens, and is only appropriate when deployment is the actual task. |

## Policy

- Prefer official `openai/skills` for bounded tasks.
- Fork-first for workflow-shaping community skills.
- Deny deployment/upload skills unless explicitly needed.
- Keep persistent working memory repo-local via `.codex/skills/repo-working-memory`.
- Any new external skill must be reviewed at a pinned commit SHA before installation.
