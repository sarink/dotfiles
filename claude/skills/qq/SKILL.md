---
name: qq
description: Read-only research and discussion mode. Use when the user wants to think through, explore, or ask a question without any code being written or actions being taken.
disable-model-invocation: true
---

# Read-only discussion mode

The user invoked `/qq` because they want a **conversation**, not an implementation. Treat the rest of this turn — and every follow-up in this session until the user explicitly releases this mode — as **strictly read-only**.

## Absolute rules

1. **Do not write or edit any files.** Do not call `Write`, `Edit`, or `NotebookEdit`. If you find yourself reaching for them, stop and explain what you *would* change instead.
2. **Do not mutate any shell state.** No `git commit`, `git push`, `git add`, `git checkout`, `git reset`, `git merge`, `git rebase`, `gh pr create`, `gh pr comment`, `rm`, `mv`, `cp`, `mkdir`, `touch`, `chmod`, `chown`, redirects (`>`, `>>`), or any package manager install/update command (`pnpm install`, `npm install`, `brew install`, `gem install`, `pip install`, `bundle install`, etc.). Do not run tests, builds, code generators, database migrations, or formatters that rewrite files.
3. **Do not invoke any MCP tool that performs writes.** No creating/updating Jira issues, Confluence pages, GitHub issues/PRs, Slack messages, calendar events, documents, or any external side effect.
4. **Do not spawn implementing subagents.** Research subagents are fine if the question genuinely needs broad exploration — prompt them explicitly to research only.

## What you *can* do, freely

- Read files (`Read`), list directories, search (`Grep`, `Glob`).
- Run **non-mutating** shell commands: `git log`, `git diff`, `git status`, `git blame`, `git show`, `cat` (via Read), `ls`, `rg`, `find` (without `-delete`), `gh pr view`, `gh issue view`, `docker ps`, `docker logs`, read-only `psql` queries (no `INSERT`/`UPDATE`/`DELETE`/`DROP`/`CREATE`), `curl` GET requests, build-tool *read* commands (`pnpm exec nx show`, `bundle info`), etc.
- Fetch docs from the web (`WebFetch`, `WebSearch`).
- Launch research-only subagents (Explore, code-explorer, Plan, etc.).

If a command is ambiguous — could it write anything? does it touch the network in a side-effecting way? — **don't run it**. Ask the user instead.

## Style

- Answer the question directly. If the user asked "how would X work" or "what's the trade-off between A and B", discuss it in prose, not in code diffs.
- Reference code with `file_path:line_number` so the user can navigate.
- Short code snippets (≤10 lines) to illustrate a point are fine — they're not edits, just quotes.
- If the user's follow-up clearly implies they want action (e.g. "ok do it", "implement that", "go fix it"), confirm once before exiting this mode: *"Want me to leave `/qq` mode and make the change?"* — then wait for an explicit yes before writing or running anything.

## End condition

Stay in this mode for the remainder of the session unless the user explicitly says something like "ok go ahead", "do it", "implement it", "exit qq", "leave research mode". Don't drift back into action mode on your own judgment.
