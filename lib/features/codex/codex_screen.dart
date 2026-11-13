import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/domain/codex/codex_entry.dart';
import 'package:q_helper/domain/codex/codex_index.dart';

class CodexScreen extends ConsumerStatefulWidget {
  const CodexScreen({super.key});

  @override
  ConsumerState<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends ConsumerState<CodexScreen> {
  final _query = TextEditingController();
  CodexKind? _kind;
  List<CodexEntry> _hits = const [];
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search(String value) {
    try {
      final hits = ref.read(codexIndexProvider).search(value, kind: _kind);
      setState(() {
        _hits = hits;
        _error = null;
      });
    } on CodexUnavailable catch (error) {
      setState(() {
        _hits = const [];
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final capable =
        ref.watch(deviceProfileProvider).value?.canRunAssistant ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Look up'),
        actions: [
          if (capable)
            IconButton(
              tooltip: 'Assistant',
              icon: const Icon(Icons.chat_outlined),
              onPressed: () => context.push('/assistant'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _query,
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'Merkin, coupon, AO',
            ),
            textInputAction: TextInputAction.search,
            onChanged: _search,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _kind == null,
                onSelected: (_) => _setKind(null),
              ),
              FilterChip(
                label: const Text('Exercises'),
                selected: _kind == CodexKind.exicon,
                onSelected: (_) => _setKind(CodexKind.exicon),
              ),
              FilterChip(
                label: const Text('Terms'),
                selected: _kind == CodexKind.lexicon,
                onSelected: (_) => _setKind(CodexKind.lexicon),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "From F3 Nation's the-codex. Not cleared to ship until F3 Nation agrees.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ..._results(context),
        ],
      ),
    );
  }

  void _setKind(CodexKind? kind) {
    setState(() => _kind = kind);
    _search(_query.text);
  }

  List<Widget> _results(BuildContext context) {
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      ];
    }
    if (_query.text.trim().isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Type a word from an exercise or a term.',
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
    if (_hits.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text('Nothing matches that.', textAlign: TextAlign.center),
        ),
      ];
    }
    return [
      for (final entry in _hits) ...[
        Card(
          child: ListTile(
            minVerticalPadding: 12,
            title: Text(entry.title),
            subtitle: Text('${entry.kind.label} · ${entry.preview}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CodexEntryScreen(entry: entry),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }
}

class CodexEntryScreen extends StatelessWidget {
  const CodexEntryScreen({required this.entry, super.key});

  final CodexEntry entry;

  @override
  Widget build(BuildContext context) {
    final tags = entry.tagList;
    return Scaffold(
      appBar: AppBar(title: Text(entry.kind.label)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(entry.title, style: Theme.of(context).textTheme.headlineSmall),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(tags.join(' · ')),
          ],
          const SizedBox(height: 16),
          SelectableText(entry.body),
        ],
      ),
    );
  }
}
