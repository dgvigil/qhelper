# Refresh the Codex database

The files in `source/` are the Exicon and Lexicon CSV exports from
[the-codex](https://github.com/F3-Nation/the-codex). That repository has no
license file. The text is bundled only as a prototype and must not ship in a
release until written permission from F3 Nation is recorded in
`docs/legal/`. See [ADR-0004](../../docs/architecture/decisions/0004-on-device-assistant-prototype.md).

The CSVs are the raw export, including broken characters such as `â€™`.
`tool/import_codex.dart` repairs them and writes the database the app opens.

1. Replace `source/exicon.csv` and `source/lexicon.csv` with the new exports.
   Exicon columns are Title, Tags, Text. Lexicon columns are Title, Text.
2. If the text changed, bump `codexRevision` in
   `lib/data/codex/codex_importer.dart`. The app recopies the asset when that
   value changes.
3. Rebuild the database:

```bash
dart run tool/import_codex.dart \
  tool/codex/source/exicon.csv \
  tool/codex/source/lexicon.csv \
  assets/codex/codex.sqlite
```

4. Run `fvm flutter test test/unit/data/codex_import_test.dart`.
