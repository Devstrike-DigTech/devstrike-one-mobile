import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_app/features/account/sign_in_screen.dart';
import 'package:one_app/features/account/you_screen.dart';
import 'package:one_app/features/marketplace/listing_detail_screen.dart';
import 'package:one_app/features/marketplace/search_screen.dart';
import 'package:one_app/features/onboarding/onboarding_screen.dart';
import 'package:one_app/features/splash/splash_screen.dart';
import 'package:one_ui/one_ui.dart';

/// Route locations, so screens never hard-code strings.
abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/welcome';
  static const discover = '/discover';
  static String listing(String id) =>
      '/discover/listing/${Uri.encodeComponent(id)}';
  static const you = '/you';
  static const signIn = '/sign-in';
}

/// The app router.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        pageBuilder: (_, _) =>
            const MaterialPage(fullscreenDialog: true, child: SignInScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.discover,
                builder: (_, _) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'listing/:id',
                    builder: (_, state) =>
                        ListingDetailScreen(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.you, builder: (_, _) => const YouScreen()),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}, name: 'router');

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.onePalette.line)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(OneIcons.compass),
              selectedIcon: Icon(OneIcons.compassFill),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(OneIcons.userCircle),
              selectedIcon: Icon(OneIcons.userCircleFill),
              label: 'You',
            ),
          ],
        ),
      ),
    );
  }
}
