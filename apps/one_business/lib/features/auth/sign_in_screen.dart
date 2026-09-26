import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_ui/one_ui.dart';

/// The only screen a signed-out owner sees.
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.onePalette;
    final session = ref.watch(sessionProvider);
    final failure = session is SignedOut ? session.failure : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OneSpaceTokens.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: OneSpaceTokens.s8),
              const OneWordmark(size: 36, product: 'Business'),
              const Spacer(),
              Text(
                'FOR OWNERS AND THEIR TEAMS',
                style: context.oneText.eyebrow,
              ),
              const SizedBox(height: OneSpaceTokens.s3),
              Semantics(
                header: true,
                child: Text(
                  'Every store you run, in one place.',
                  style: text.displayMedium,
                ),
              ),
              const SizedBox(height: OneSpaceTokens.s4),
              Text(
                'Sign in with the One ID you use for your business. Hotels, salons and '
                'whatever you add next sit side by side.',
                style: text.bodyLarge!.copyWith(color: palette.inkMuted),
              ),
              const SizedBox(height: OneSpaceTokens.s6),
              const WovenBand(height: 20, seed: 4),
              const Spacer(),
              if (failure != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    failure.message,
                    style: text.bodyMedium!.copyWith(color: palette.danger),
                  ),
                ),
                const SizedBox(height: OneSpaceTokens.s3),
              ],
              OneButton(
                label: 'Sign in with One ID',
                icon: OneIcons.signIn,
                expand: true,
                loading: session is SigningIn,
                onPressed: () =>
                    unawaited(ref.read(sessionProvider.notifier).signIn()),
              ),
              const SizedBox(height: OneSpaceTokens.s3),
              Text(
                'New to One? Your HotelOS login works once your hotel is linked.',
                style: text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
