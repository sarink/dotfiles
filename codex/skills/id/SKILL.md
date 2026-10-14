---
name: id
description: Print the current conversation's thread ID. Use when explicitly invoked with $id.
---

Run `printf '%s\n' "$CODEX_THREAD_ID"` and reply with exactly the ID it prints,
in a code span, and nothing else. If it prints nothing, say that Codex didn't
set `CODEX_THREAD_ID` in this session.
