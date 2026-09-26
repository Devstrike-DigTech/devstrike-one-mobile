import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_app/app/router.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_ui/one_ui.dart';

/// Explains One ID in two lines and hands off to the system browser.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.onePalette;
    final session = ref.watch(sessionProvider);

    ref.listen(sessionProvider, (previous, next) {
      if (next is SignedIn && previous is! SignedIn) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(Routes.you);
        }
      }
    });

    final failure = session is SignedOut ? session.failure : null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(OneIcons.x),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.discover),
        ),
        shape: const Border(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OneSpaceTokens.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OneWordmark(size: 40),
              const SizedBox(height: OneSpaceTokens.s8),
              Semantics(
                header: true,
                child: Text('Sign in with One ID', style: text.displaySmall),
              ),
              const SizedBox(height: OneSpaceTokens.s3),
              Text(
                'One account for every business on One. We will open a secure page where you '
                'confirm your phone number or email.',
                style: text.bodyLarge!.copyWith(color: palette.inkMuted),
              ),
              if (failure != null) ...[
                const SizedBox(height: OneSpaceTokens.s5),
                _FailureNote(message: failure.message),
              ],
              const Spacer(),
              OneButton(
                label: 'Continue with One ID',
                icon: OneIcons.signIn,
                expand: true,
                loading: session is SigningIn || session is SessionRestoring,
                onPressed: () =>
                    unawaited(ref.read(sessionProvider.notifier).signIn()),
              ),
              const SizedBox(height: OneSpaceTokens.s3),
              Row(
                children: [
                  Icon(OneIcons.shieldCheck, size: 16, color: palette.river),
                  const SizedBox(width: OneSpaceTokens.s2),
                  Expanded(
                    child: Text(
                      'Your password never passes through this app.',
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FailureNote extends StatelessWidget {
  const _FailureNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.onePalette.colors;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.dangerWash,
          borderRadius: BorderRadius.circular(OneRadiusTokens.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(OneSpaceTokens.s3),
          child: Row(
            children: [
              Icon(OneIcons.warningCircle, size: 18, color: c.danger),
              const SizedBox(width: OneSpaceTokens.s2),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(color: c.danger),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
