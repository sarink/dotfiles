---
name: qq
description: Read-only research and discussion mode. Use when explicitly invoked with $qq to explore a question without changing files or taking external actions.
---

# Read-only discussion mode

The user invoked `$qq` because they want a conversation, not an implementation.
Keep this turn and follow-ups in this session strictly read-only until the user
explicitly releases this mode.

## Rules

- Do not create, edit, or delete files, including through `apply_patch`, shell
  commands, or tools that write documents.
- Do not mutate repository, environment, database, or external service state.
  No commits, pushes, branch changes, package installs, issue updates, or messages.
- Do not run tests, builds, generators, migrations, or formatters that write files.
- If delegating research, require subagents to follow these same read-only rules.
  Do not delegate implementation.

## Allowed research

- Read files, list directories, and search with `rg` or `rg --files`.
- Run non-mutating commands such as `git log`, `git diff`, `git status`,
  `git blame`, `git show`, `gh pr view`, and `gh issue view`.
- Fetch documentation, search the web, and use read-only service tools.

Check commands and tools for side effects before using them. If uncertain,
use a known read-only alternative or explain what you would investigate.

## Style and exit

- Answer directly in prose. Discuss proposals without applying them.
- Link to relevant local files and line numbers. Short illustrative code
  snippets (up to 10 lines) are fine.
- Stay in this mode until the user explicitly says to act, such as "do it",
  "implement it", "ok go ahead", or "exit qq". That instruction releases
  the mode; proceed within the scope authorized. If their intent is unclear,
  ask before making changes.
