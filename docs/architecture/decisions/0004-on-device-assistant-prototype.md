# ADR-0004: On-device Codex lookup and assistant prototype

- Status: Proposed (prototype, not a release)
- Date: 2026-11-13

## Context

Qs look up exercise names and F3 terms while planning. The v0.1 app has no
lookup. The roadmap lists official Exicon integration as conditional on
written permission from F3 Nation, and AI workout generation as unscheduled.
This prototype tries both ideas without putting either into a release.

## Decision

- Ship a **read-only SQLite database** with FTS5, built by
  `tool/import_codex.dart` from the CSV exports of
  [the-codex](https://github.com/F3-Nation/the-codex). The database is an app
  asset. Search works with no network and no model, on every phone.
- The export's text was UTF-8 read as Windows-1252 (`â€™` for an apostrophe).
  The importer repairs that. Characters the export already replaced are gone;
  one of those between two letters becomes an apostrophe.
- An **optional assistant** downloads webAI **TwIL-LM3-Pro** INT4
  (`.litertlm`, about 2.2 GB) on Wi-Fi and runs it with
  `flutter_edge_ai` / `flutter_edge_ai_litertlm` (LiteRT-LM). Each question
  is prefixed with a few search hits so the answer is tied to real entries.
  Phones under about 8 GB of RAM do not see the assistant. Workouts and
  lookup do not load the model.
- Model weights are not committed. See the pull request for the license
  conflict. The Codex text is not cleared to ship; see the
  [content policy](../../legal/content-policy.md).

## Consequences

- The user database is unchanged. The Codex file is a second database.
- The app binary grows by the LiteRT-LM runtime. The model file is downloaded
  later, only if the Q asks for it.
- A store build must not include this prototype until the F3 text and the
  model license are resolved.
