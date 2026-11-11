import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:q_helper/app/providers.dart';
import 'package:q_helper/domain/models/workout_plan.dart';
import 'package:q_helper/domain/models/workout_session.dart';
import 'package:q_helper/domain/services/live_session.dart';
import 'package:q_helper/features/live_session/end_workout_dialog.dart';
import 'package:q_helper/domain/services/plan_text_export.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(planListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q Helper'),
        actions: [
          IconButton(
            tooltip: 'Quick timer',
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => context.push('/quick'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: 'Templates',
            icon: const Icon(Icons.view_agenda_outlined),
            onPressed: () => context.push('/templates'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/builder/new'),
        icon: const Icon(Icons.add),
        label: const Text('New workout'),
      ),
      body: plans.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load your workouts.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(planListProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => Column(
          children: [
            const _ResumeBanner(),
            Expanded(
              child: list.isEmpty
                  ? const _EmptyState()
                  : _PlanList(plans: list),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No workouts yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Plan the workout. Lead the men.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push('/builder/new'),
              child: const Text('Create your first workout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanList extends ConsumerWidget {
  const _PlanList({required this.plans});

  final List<WorkoutPlan> plans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: plans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _PlanTile(plan: plans[i]),
    );
  }
}

String planSummary(WorkoutPlan plan) {
  final segments = plan.segments.length;
  final activities = plan.segments.fold<int>(
    0,
    (sum, s) => sum + s.activities.length,
  );
  return '${formatSeconds(plan.targetDurationSeconds)} · '
      '$segments ${segments == 1 ? 'segment' : 'segments'} · '
      '$activities ${activities == 1 ? 'activity' : 'activities'}';
}

enum _PlanAction { start, duplicate, share, delete }

class _PlanTile extends ConsumerWidget {
  const _PlanTile({required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        minVerticalPadding: 12,
        title: Text(plan.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(planSummary(plan)),
        onTap: () => context.push('/builder/${plan.id}'),
        trailing: PopupMenuButton<_PlanAction>(
          tooltip: 'Actions for ${plan.title}',
          onSelected: (action) => _onAction(context, ref, action),
          itemBuilder: (_) => const [
            PopupMenuItem(value: _PlanAction.start, child: Text('Start')),
            PopupMenuItem(
              value: _PlanAction.duplicate,
              child: Text('Duplicate'),
            ),
            PopupMenuItem(value: _PlanAction.share, child: Text('Share')),
            PopupMenuItem(value: _PlanAction.delete, child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _PlanAction action,
  ) async {
    switch (action) {
      case _PlanAction.start:
        await context.push('/live/${plan.id}');
        ref.invalidate(activeSessionProvider);
      case _PlanAction.duplicate:
        await ref.read(planListProvider.notifier).duplicate(plan.id);
      case _PlanAction.share:
        await ref
            .read(shareServiceProvider)
            .shareText(planToText(plan), subject: plan.title);
      case _PlanAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete "${plan.title}"?'),
            content: const Text('This cannot be undone.'),
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
        if (confirmed ?? false) {
          await ref.read(planListProvider.notifier).delete(plan.id);
        }
    }
  }
}

/// Offers Resume / End for a workout still running after a relaunch or after
/// leaving the live screen.
class _ResumeBanner extends ConsumerWidget {
  const _ResumeBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSessionProvider).value;
    if (active == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout in progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(active.workingPlan.title),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: () async {
                    await context.push('/live/resume');
                    ref.invalidate(activeSessionProvider);
                  },
                  child: const Text('Resume'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _end(context, ref),
                  child: const Text('End workout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _end(BuildContext context, WidgetRef ref) async {
    final status = await showEndWorkoutDialog(context);
    if (status == null) return;
    final live = await LiveSession.recover(
      sessions: ref.read(sessionRepositoryProvider),
      clock: ref.read(appClockProvider),
    );
    if (live != null) {
      if (status == SessionStatus.completed) {
        await live.complete();
      } else {
        await live.endEarly();
      }
    }
    await ref.read(endNotificationCoordinatorProvider).sessionEnded();
    ref.invalidate(activeSessionProvider);
  }
}
