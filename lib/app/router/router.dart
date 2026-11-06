import 'package:go_router/go_router.dart';
import 'package:q_helper/features/home/home_screen.dart';

GoRouter buildRouter() => GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
);
