---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up. Use when explicitly invoked with $handoff.
---

Write a handoff summarising the current conversation so a fresh agent can continue the work. Output it in the chat as a single markdown block the user can copy; don't write it to a file.

Include a "suggested skills" section in the handoff, naming which skills the next agent should invoke.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed text after `$handoff`, treat it as a description of what the next session will focus on and tailor the doc accordingly.
