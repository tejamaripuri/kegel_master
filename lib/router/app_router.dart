import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kegel_master/features/home/presentation/home_screen.dart';
import 'package:kegel_master/features/learn/presentation/learn_screen.dart';
import 'package:kegel_master/features/progress/presentation/progress_screen.dart';
import 'package:kegel_master/features/settings/presentation/settings_screen.dart';
import 'package:kegel_master/features/shell/main_navigation_shell.dart';

final GoRouter defaultAppRouter = createAppRouter();

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/home',
    redirect: (BuildContext context, GoRouterState state) {
      if (state.uri.path == '/') {
        return '/home';
      }
      return null;
    },
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MainNavigationShell(shell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/learn',
                builder: (BuildContext context, GoRouterState state) =>
                    const LearnScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/progress',
                builder: (BuildContext context, GoRouterState state) =>
                    const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No route for this location.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
