import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kegel_master/features/home/presentation/home_screen.dart';
import 'package:kegel_master/features/learn/presentation/learn_screen.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';
import 'package:kegel_master/features/onboarding/domain/onboarding_redirect.dart';
import 'package:kegel_master/features/onboarding/presentation/onboarding_flow_screen.dart';
import 'package:kegel_master/features/progress/presentation/progress_screen.dart';
import 'package:kegel_master/features/session/domain/session_config.dart';
import 'package:kegel_master/features/session/presentation/session_screen.dart';
import 'package:kegel_master/features/settings/presentation/settings_screen.dart';
import 'package:kegel_master/features/shell/main_navigation_shell.dart';

GoRouter createAppRouter({required OnboardingGate gate}) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: gate,
    redirect: (BuildContext context, GoRouterState state) {
      return resolveOnboardingRedirect(
        path: state.uri.path,
        snapshot: gate.snapshot,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingFlowScreen(),
      ),
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
      GoRoute(
        path: '/session',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final SessionConfig config =
              extra is SessionConfig ? extra : SessionConfig.defaults;
          return SessionScreen(config: config);
        },
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
