# User-level Codex instructions

## Git worktrees

- Whenever creating a Git worktree, always place it at `<repo folder>/.codex/worktrees/<worktree-name>`.
- `<repo folder>` means the repository's primary checkout root. When already inside a linked worktree, resolve the primary checkout first so new worktrees are not nested inside existing worktrees.
- Create the `.codex/worktrees` directory as needed, and ensure `/.codex/worktrees/` is ignored by Git in the primary checkout; use the repository's local Git exclude file if it is not already ignored.
