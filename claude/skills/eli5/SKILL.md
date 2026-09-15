---
name: eli5
description: Re-explain the last answer (or a given topic) more succinctly and in simple English, for a non-native English speaker.
disable-model-invocation: true
---

# Explain it simply

The user invoked `/eli5`. They want the same information, said **shorter** and in **simpler English**.

If `$ARGUMENTS` names a topic, explain that. Otherwise re-explain your previous answer.

## How to write

- **Shorter.** Cut every sentence that is not needed. Aim for less than half the length of the original answer.
- **Simple words.** Use common English. Replace jargon with a plain word, or keep the term and add a short definition the first time: "idempotent (running it twice changes nothing)".
- **Short sentences.** One idea per sentence. Prefer active voice: "The app sends the file" over "The file is sent by the app".
- **No idioms, no metaphors, no wordplay.** They are hard for a non-native speaker. Say the literal thing.
- **Structure helps.** A few short bullets or numbered steps beat one long paragraph.
- **Keep the facts.** Simpler wording, not less accuracy. Do not drop a caveat that changes the meaning. Keep exact names as they are: file paths, commands, function names, error text.

## Do not

- Do not talk down to the user. They are an expert; English is just not their first language.
- Do not add new tangents, background, or "also worth noting" sections.
- Do not do new work — this is a rewrite of an explanation, not another task.

Stay in this style for the rest of the conversation, until the user asks for more detail.
