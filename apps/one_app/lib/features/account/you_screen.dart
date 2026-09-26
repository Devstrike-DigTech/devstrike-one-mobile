import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_app/app/providers.dart';
import 'package:one_app/app/router.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_ui/one_ui.dart';

/// Account and settings.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final config = ref.watch(appConfigProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            OneSpaceTokens.s4,
            OneSpaceTokens.s6,
            OneSpaceTokens.s4,
            OneSpaceTokens.s8,
          ),
          children: [
            const OneSectionHeader(
              eyebrow: 'Account',
              title: 'You',
              large: true,
            ),
            const SizedBox(height: OneSpaceTokens.s5),
            switch (session) {
              SignedIn(:final claims) => OneCard(
                child: Row(
                  children: [
                    const Icon(OneIcons.userCircle, size: 36),
                    const SizedBox(width: OneSpaceTokens.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(claims.displayName, style: text.titleMedium),
                          if (claims.email ?? claims.phoneNumber
                              case final contact?)
                            Text(contact, style: text.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _ => OneCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keep your trips in one place',
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: OneSpaceTokens.s2),
                    Text(
                      'Sign in with One ID to see bookings from every business on One. '
                      'Browsing never needs an account.',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: OneSpaceTokens.s4),
                    OneButton(
                      label: 'Sign in',
                      icon: OneIcons.signIn,
                      loading: session is SessionRestoring,
                      onPressed: () => unawaited(context.push(Routes.signIn)),
                    ),
                  ],
                ),
              ),
            },
            const SizedBox(height: OneSpaceTokens.s8),
            const OneSectionHeader(title: 'Appearance'),
            const SizedBox(height: OneSpaceTokens.s4),
            const _ThemePicker(),
            const SizedBox(height: OneSpaceTokens.s8),
            const OneSectionHeader(title: 'About'),
            const SizedBox(height: OneSpaceTokens.s2),
            _AboutRow(label: 'App', value: config.appName),
            _AboutRow(label: 'Build', value: config.flavor.name),
            _AboutRow(label: 'Server', value: config.apiBaseUrl.host),
            const _AboutRow(
              label: 'Design',
              value: '${OneTokenSet.name} ${OneTokenSet.version}',
            ),
            if (session is SignedIn) ...[
              const SizedBox(height: OneSpaceTokens.s8),
              OneButton(
                label: 'Sign out',
                variant: OneButtonVariant.danger,
                icon: OneIcons.signOut,
                expand: true,
                onPressed: () =>
                    unawaited(ref.read(sessionProvider.notifier).signOut()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemePicker extends ConsumerWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(OneIcons.circleHalf, size: 18),
          label: Text('System'),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(OneIcons.sun, size: 18),
          label: Text('Light'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(OneIcons.moon, size: 18),
          label: Text('Dark'),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) =>
          unawaited(ref.read(themeModeProvider.notifier).select(s.first)),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: OneSpaceTokens.s3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.onePalette.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: context.oneText.numericSmall),
        ],
      ),
    );
  }
}
