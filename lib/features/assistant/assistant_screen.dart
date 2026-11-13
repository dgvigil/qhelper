import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/domain/assistant/answer_text.dart';
import 'package:q_helper/domain/assistant/local_assistant.dart';
import 'package:q_helper/domain/assistant/assistant_model.dart';
import 'package:q_helper/domain/assistant/model_download.dart';
import 'package:q_helper/domain/codex/codex_entry.dart';
import 'package:q_helper/domain/codex/rag_prompt.dart';

class _Turn {
  _Turn({required this.question, required this.sources});

  final String question;
  final List<CodexEntry> sources;
  String answer = '';
}

/// On-device questions. Phones that are not capable never get past the
/// explanation, and a missing model never blocks lookup.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _question = TextEditingController();
  final _turns = <_Turn>[];
  late final LocalAssistant _assistant;
  var _checkingModel = true;
  var _installed = false;
  var _downloading = false;
  var _percent = 0;
  var _asking = false;
  String? _message;

  static const _examples = <String>[
    'What is a Merkin?',
    'Build a 45-minute beatdown with a coupon',
  ];

  @override
  void initState() {
    super.initState();
    _assistant = ref.read(localAssistantProvider);
    _loadModel();
  }

  @override
  void dispose() {
    _question.dispose();
    unawaited(_assistant.release());
    super.dispose();
  }

  Future<void> _loadModel() async {
    final profile = await ref.read(deviceProfileProvider.future);
    if (!profile.canRunAssistant) {
      if (mounted) setState(() => _checkingModel = false);
      return;
    }
    try {
      final installed = await ref.read(modelStoreProvider).isInstalled();
      if (!mounted) return;
      setState(() {
        _installed = installed;
        _checkingModel = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checkingModel = false;
        _message = 'The assistant could not be checked. Lookup still works.';
      });
    }
  }

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _percent = 0;
      _message = null;
    });
    try {
      await ref
          .read(modelStoreProvider)
          .download(
            onProgress: (percent) {
              if (mounted) setState(() => _percent = percent);
            },
          );
      if (!mounted) return;
      setState(() {
        _installed = true;
        _downloading = false;
      });
    } on AssistantDownloadException catch (error) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _message = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _message = 'The download failed. Lookup still works.';
      });
    }
  }

  Future<void> _ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || _asking) return;
    final sources = ref
        .read(codexIndexProvider)
        .search(trimmed, limit: ragEntryLimit);
    final turn = _Turn(question: trimmed, sources: sources);
    setState(() {
      _asking = true;
      _message = null;
      _turns.add(turn);
    });
    try {
      final raw = await _assistant.complete(
        ragUserMessage(trimmed, sources),
        onToken: (token) {
          if (!mounted) return;
          setState(() => turn.answer = stripReasoning('${turn.answer}$token'));
        },
      );
      if (!mounted) return;
      setState(() {
        turn.answer = stripReasoning(raw);
        if (turn.answer.isEmpty) {
          turn.answer = 'The assistant did not return an answer.';
        }
        _asking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _asking = false;
        turn.answer = 'The assistant could not answer. Lookup still works.';
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete the assistant download?'),
        content: const Text(
          'The model is removed from this phone. Lookup is unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(modelStoreProvider).delete();
    await _assistant.release();
    if (!mounted) return;
    setState(() {
      _installed = false;
      _turns.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = ref.watch(deviceProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          if (_installed)
            IconButton(
              tooltip: 'Delete download',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: device.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _BlockedMessage(
          text: 'This phone could not be checked for the assistant. Lookup still works.',
        ),
        data: (profile) {
          if (!profile.canRunAssistant) {
            return const _BlockedMessage(
              text: 'This phone does not have enough memory for the on-device assistant. About 8 GB is needed. Lookup still works.',
            );
          }
          if (_checkingModel) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_installed) return _downloadBody();
          return _chatBody();
        },
      ),
    );
  }

  Widget _downloadBody() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Ask from the exercise list',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'The assistant runs on this phone. A question is not sent anywhere. '
          'The download is about ${AssistantModel.approximateSize} and starts only on Wi-Fi. '
          'Keep this screen open until it finishes.',
        ),
        const SizedBox(height: 12),
        const Text(
          'The model is webAI TwIL-LM3-Pro. Its license is non-commercial research only, and it is not part of the GPL app. This is a prototype.',
        ),
        const SizedBox(height: 24),
        if (_downloading) ...[
          LinearProgressIndicator(value: _percent / 100),
          const SizedBox(height: 8),
          Text('Downloading… $_percent%'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => ref.read(modelStoreProvider).cancel(),
            child: const Text('Cancel'),
          ),
        ] else
          FilledButton(
            onPressed: _download,
            child: const Text('Download on Wi-Fi'),
          ),
        if (_message != null) ...[const SizedBox(height: 16), Text(_message!)],
      ],
    );
  }

  Widget _chatBody() {
    return Column(
      children: [
        Expanded(
          child: _turns.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Ask about an exercise or a workout. Answers use the list on this phone.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _turns.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final turn = _turns[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turn.question,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          turn.answer.isEmpty && _asking
                              ? 'Working…'
                              : turn.answer,
                        ),
                        if (turn.sources.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'From the list: ${turn.sources.map((e) => e.title).join(', ')}',
                          ),
                        ],
                      ],
                    );
                  },
                ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.45,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final example in _examples)
                      ActionChip(
                        label: Text(example),
                        onPressed: _asking ? null : () => _ask(example),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _question,
                  decoration: const InputDecoration(labelText: 'Question'),
                  textInputAction: TextInputAction.send,
                  onSubmitted: _asking ? null : _ask,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _asking ? null : () => _ask(_question.text),
                  child: const Text('Ask'),
                ),
              ],
            ),
          ),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(_message!),
          ),
      ],
    );
  }
}

class _BlockedMessage extends StatelessWidget {
  const _BlockedMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
