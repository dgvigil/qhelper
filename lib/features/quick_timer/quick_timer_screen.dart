import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/core/platform/cue_service.dart';
import 'package:q_helper/core/platform/wakelock_service.dart';
import 'package:q_helper/core/timer/interval_timer.dart';
import 'package:q_helper/features/live_session/interval_panel.dart';

/// Work / rest / rounds timer that needs no saved workout. Nothing is stored.
class QuickTimerScreen extends ConsumerStatefulWidget {
  const QuickTimerScreen({super.key});

  @override
  ConsumerState<QuickTimerScreen> createState() => _QuickTimerScreenState();
}

class _QuickTimerScreenState extends ConsumerState<QuickTimerScreen>
    with WidgetsBindingObserver {
  late final WakelockService _wakelock = ref.read(wakelockServiceProvider);
  late final CueService _cues = ref.read(cueServiceProvider);

  final _work = TextEditingController(text: '40');
  final _rest = TextEditingController(text: '20');
  final _rounds = TextEditingController(text: '5');

  late IntervalTimer _timer;
  final Map<String, String> _errors = {};
  bool _wakelockOn = false;
  StreamSubscription<void>? _ticks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = IntervalTimer(_config()!, ref.read(appClockProvider));
    _ticks = ref.read(tickStreamProvider).listen((_) => _tick());
    unawaited(_enableWakelock());
  }

  Future<void> _enableWakelock() async {
    final settings = await ref.read(settingsProvider.future);
    if (!mounted || !settings.keepScreenAwake) return;
    _wakelockOn = true;
    await _wakelock.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_ticks?.cancel());
    if (_wakelockOn) unawaited(_wakelock.disable());
    _work.dispose();
    _rest.dispose();
    _rounds.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  int? _positive(TextEditingController c) {
    final n = int.tryParse(c.text.trim());
    return n != null && n > 0 ? n : null;
  }

  int? _rest0() {
    final text = _rest.text.trim();
    if (text.isEmpty) return 0;
    final n = int.tryParse(text);
    return n != null && n >= 0 ? n : null;
  }

  /// The configuration in the fields, or null if any field is invalid.
  IntervalConfig? _config() {
    final work = _positive(_work);
    final rest = _rest0();
    final rounds = _positive(_rounds);
    if (work == null || rest == null || rounds == null) return null;
    return IntervalConfig(
      work: Duration(seconds: work),
      rest: Duration(seconds: rest),
      rounds: rounds,
    );
  }

  bool get _locked => _timer.read().status != IntervalStatus.idle;

  void _fieldsChanged() {
    final config = _config();
    if (config != null && !_locked) {
      setState(() {
        _errors.clear();
        _timer = IntervalTimer(config, ref.read(appClockProvider));
      });
    }
  }

  void _start() {
    final config = _config();
    if (config == null) {
      setState(() {
        _errors
          ..clear()
          ..addAll({
            if (_positive(_work) == null)
              'work': 'Enter a number greater than zero',
            if (_rest0() == null) 'rest': 'Enter a number, zero or more',
            if (_positive(_rounds) == null)
              'rounds': 'Enter a number greater than zero',
          });
      });
      return;
    }
    setState(() {
      _errors.clear();
      _timer = IntervalTimer(config, ref.read(appClockProvider))..start();
    });
    _tick();
  }

  void _run(void Function(IntervalTimer) change) {
    change(_timer);
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    final cue = _timer.observe().cue;
    if (cue != null) {
      unawaited(
        _cues.play(switch (cue) {
          IntervalCue.workStart => CueKind.workStart,
          IntervalCue.restStart => CueKind.restStart,
          IntervalCue.finished => CueKind.intervalFinished,
        }),
      );
    }
    setState(() {});
  }

  Widget _field(String key, String label, TextEditingController c) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          key: Key('quick-$key'),
          controller: c,
          enabled: !_locked,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _fieldsChanged(),
          decoration: InputDecoration(
            labelText: label,
            errorText: _errors[key],
            errorMaxLines: 3,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick timer')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('work', 'Work (sec)', _work),
                  _field('rest', 'Rest (sec)', _rest),
                  _field('rounds', 'Rounds', _rounds),
                ],
              ),
              const SizedBox(height: 16),
              IntervalPanel(
                interval: _timer,
                onStart: _start,
                onPause: () => _run((t) => t.pause()),
                onResume: () => _run((t) => t.resume()),
                onSkip: () => _run((t) => t.skipPhase()),
                onReset: () => _run((t) => t.reset()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
