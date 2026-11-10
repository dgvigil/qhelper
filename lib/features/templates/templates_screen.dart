import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:q_helper/domain/services/plan_text_export.dart';
import 'package:q_helper/domain/services/templates.dart';

/// Two editable structural templates: segment names and times only.
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'A starting structure with segment names and times. '
            'Add your own exercises and change anything.',
          ),
          const SizedBox(height: 16),
          for (final minutes in templateMinutes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  minVerticalPadding: 16,
                  title: Text('$minutes-minute workout'),
                  subtitle: Text(_outline(minutes)),
                  onTap: () =>
                      context.pushReplacement('/builder/new?template=$minutes'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _outline(int minutes) {
    var n = 0;
    final plan = templatePlan(
      minutes,
      newId: () => 't${n++}',
      now: DateTime.utc(2026),
    );
    return [
      for (final s in plan.segments)
        '${s.title} ${formatSeconds(s.estimatedDurationSeconds!)}',
    ].join(' · ');
  }
}
