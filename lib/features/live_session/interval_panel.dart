import 'package:flutter/material.dart';
import 'package:q_helper/core/timer/interval_timer.dart';
import 'package:q_helper/features/live_session/clock_format.dart';

/// Work / rest / rounds display with Start, Pause, Resume, Skip, and Reset.
/// Shared by the live workout screen and the quick timer.
class IntervalPanel extends StatelessWidget {
  const IntervalPanel({
    super.key,
    required this.interval,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onSkip,
    required this.onReset,
  });

  final IntervalTimer interval;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = interval.read();
    final phase = switch ((r.status, r.phase)) {
      (IntervalStatus.finished, _) => 'DONE',
      (IntervalStatus.idle, _) => 'READY',
      (_, IntervalPhase.work) => 'WORK',
      _ => 'REST',
    };
    final round = r.round ?? r.rounds;

    return Container(
      key: const Key('interval-panel'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interval timer', style: theme.textTheme.labelLarge),
              if (r.status == IntervalStatus.paused) const Text('Paused'),
            ],
          ),
          Text(
            phase,
            key: const Key('interval-phase'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          Text(
            formatCountdown(r.remainingInPhase),
            key: const Key('interval-time'),
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            'Round $round of ${r.rounds}',
            key: const Key('interval-round'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (r.status == IntervalStatus.idle)
                FilledButton(onPressed: onStart, child: const Text('Start')),
              if (r.status == IntervalStatus.running)
                OutlinedButton(onPressed: onPause, child: const Text('Pause')),
              if (r.status == IntervalStatus.paused)
                FilledButton(onPressed: onResume, child: const Text('Resume')),
              if (r.status == IntervalStatus.running ||
                  r.status == IntervalStatus.paused)
                OutlinedButton(onPressed: onSkip, child: const Text('Skip')),
              if (r.status != IntervalStatus.idle)
                OutlinedButton(onPressed: onReset, child: const Text('Reset')),
            ],
          ),
        ],
      ),
    );
  }
}
