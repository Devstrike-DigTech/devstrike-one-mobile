import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_business/features/auth/sign_in_screen.dart';
import 'package:one_business/features/home/home_screen.dart';
import 'package:one_business/features/placeholders/coming_later_screen.dart';
import 'package:one_business/features/shell/business_shell.dart';
import 'package:one_ui/one_ui.dart';

abstract final class Routes {
  static const restoring = '/';
  static const signIn = '/sign-in';
  static const home = '/home';
  static const inbox = '/inbox';
  static const books = '/books';
  static const insights = '/insights';
}

/// Everything in One Business needs a signed-in owner; the router sends
/// signed-out people to the sign-in screen and back once they are in.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<SessionState>(ref.read(sessionProvider));
  ref
    ..listen(sessionProvider, (_, next) => session.value = next)
    ..onDispose(session.dispose);

  final router = GoRouter(
    initialLocation: Routes.restoring,
    refreshListenable: session,
    redirect: (context, state) {
      final here = state.matchedLocation;
      return switch (session.value) {
        SessionRestoring() =>
          here == Routes.restoring ? null : Routes.restoring,
        SignedIn() =>
          (here == Routes.signIn || here == Routes.restoring)
              ? Routes.home
              : null,
        SignedOut() ||
        SigningIn() => here == Routes.signIn ? null : Routes.signIn,
      };
    },
    routes: [
      GoRoute(path: Routes.restoring, builder: (_, _) => const _Restoring()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => BusinessShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.inbox,
                builder: (_, _) => const ComingLaterScreen(
                  title: 'Inbox',
                  eyebrow: 'Not scheduled yet',
                  icon: OneIcons.tray,
                  message:
                      'Guest messages, WhatsApp and booking notes from every store, in one list. '
                      'It follows the notify module; it is not on the One-0 to One-2 plan.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.books,
                builder: (_, _) => const ComingLaterScreen(
                  title: 'Books',
                  eyebrow: 'Coming in One-5',
                  icon: OneIcons.bookOpen,
                  message:
                      'Profit and loss, cash book, VAT and WHT schedules, built from the ledger '
                      'that One-3 starts keeping for each store.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.insights,
                builder: (_, _) => const ComingLaterScreen(
                  title: 'Insights',
                  eyebrow: 'Coming in One-5',
                  icon: OneIcons.chartLine,
                  message:
                      'Occupancy, takings and repeat guests across your stores, with anonymised '
                      'benchmarks for your city.',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}, name: 'router');

class _Restoring extends StatelessWidget {
  const _Restoring();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: OneWordmark(size: 40, product: 'Business')),
  );
}
