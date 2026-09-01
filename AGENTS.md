**MANDATORY**: At the start of every session, you MUST read ALL `*.md` files in the `.ai` directory before proceeding with any task.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Agent skills

### Issue tracker

Issues and specs live as local markdown under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), recorded as a `Status:` line. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout; read `.ai/*.md` first (mandatory), then `CONTEXT.md`/`docs/adr/` when present. See `docs/agents/domain.md`.
