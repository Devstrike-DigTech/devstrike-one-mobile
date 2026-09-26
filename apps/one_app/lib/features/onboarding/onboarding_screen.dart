import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_app/app/providers.dart';
import 'package:one_app/app/router.dart';
import 'package:one_ui/one_ui.dart';

class _Page {
  const _Page(this.eyebrow, this.title, this.body, this.seed);

  final String eyebrow;
  final String title;
  final String body;
  final int seed;
}

const _pages = [
  _Page(
    'One marketplace',
    'Hotels, salons and more, woven together.',
    'Search every business that runs on Devstrike, from a room in Lekki to a chair in Wuse II.',
    2,
  ),
  _Page(
    'Straight to the business',
    'You book with them, not with a middleman.',
    "When you find a place, One hands you to the business's own booking page. Prices and rooms come from them.",
    5,
  ),
  _Page(
    'One account',
    'Sign in once. Keep it everywhere.',
    'Your One ID works with every business on One. Signing in is optional until you want your trips in one list.',
    8,
  ),
];

/// Three short screens, skippable, shown once.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).complete();
    if (mounted) context.go(Routes.discover);
  }

  void _next() {
    if (_index == _pages.length - 1) {
      unawaited(_finish());
    } else {
      _controller.nextPage(
        duration: OneMotionTokens.slow,
        curve: OneMotionTokens.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.onePalette;
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OneSpaceTokens.s6,
                OneSpaceTokens.s2,
                OneSpaceTokens.s2,
                0,
              ),
              child: Row(
                children: [
                  const OneWordmark(size: 24),
                  const Spacer(),
                  if (!last)
                    OneButton(
                      label: 'Skip',
                      variant: OneButtonVariant.quiet,
                      onPressed: _finish,
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OneSpaceTokens.s6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        WovenBand(height: 28, seed: page.seed),
                        const SizedBox(height: OneSpaceTokens.s8),
                        Text(
                          page.eyebrow.toUpperCase(),
                          style: context.oneText.eyebrow,
                        ),
                        const SizedBox(height: OneSpaceTokens.s3),
                        Semantics(
                          header: true,
                          child: Text(page.title, style: text.displayMedium),
                        ),
                        const SizedBox(height: OneSpaceTokens.s4),
                        Text(
                          page.body,
                          style: text.bodyLarge!.copyWith(
                            color: palette.inkMuted,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(OneSpaceTokens.s6),
              child: Row(
                children: [
                  _Dots(count: _pages.length, index: _index),
                  const SizedBox(width: OneSpaceTokens.s4),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: OneButton(
                        label: last ? 'Start exploring' : 'Next',
                        trailingIcon: OneIcons.arrowRight,
                        onPressed: _next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.onePalette;
    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: OneMotionTokens.base,
              curve: OneMotionTokens.easeOut,
              margin: const EdgeInsets.only(right: 6),
              width: i == index ? 20 : 6,
              height: 4,
              color: i == index ? palette.kola : palette.colors.lineStrong,
            ),
        ],
      ),
    );
  }
}
