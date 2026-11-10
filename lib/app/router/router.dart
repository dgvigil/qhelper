import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:q_helper/features/builder/builder_screen.dart';
import 'package:q_helper/features/home/home_screen.dart';
import 'package:q_helper/features/live_session/live_screen.dart';
import 'package:q_helper/features/templates/templates_screen.dart';

GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/live/resume', builder: (_, _) => const LiveScreen()),
    GoRoute(
      path: '/live/:planId',
      builder: (_, state) => LiveScreen(planId: state.pathParameters['planId']),
    ),
    GoRoute(path: '/templates', builder: (_, _) => const TemplatesScreen()),
    GoRoute(
      path: '/builder/:id',
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        return BuilderScreen(
          key: ValueKey(state.uri.toString()),
          planId: id == 'new' ? null : id,
          templateMinutes: int.tryParse(
            state.uri.queryParameters['template'] ?? '',
          ),
        );
      },
    ),
  ],
);
