import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_app/app/providers.dart';
import 'package:one_app/app/router.dart';
import 'package:one_ui/one_ui.dart';

/// First frame after the native launch screen: the cloth weaves itself under
/// the wordmark, then the app moves on. Under a second; instant with reduced
/// motion.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// How long the weave takes.
  static const Duration weave = Duration(milliseconds: 900);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashScreen.weave,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _controller.value = 1;
      scheduleMicrotask(_next);
    } else {
      unawaited(_controller.forward().whenComplete(_next));
    }
  }

  void _next() {
    if (!mounted) return;
    final seen = ref.read(onboardingSeenProvider);
    context.go(seen ? Routes.discover : Routes.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: OneMotionTokens.easeOut,
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OneSpaceTokens.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: curve,
                child: const OneWordmark(size: 56),
              ),
              const SizedBox(height: OneSpaceTokens.s4),
              FadeTransition(
                opacity: curve,
                child: Text(
                  'Every Devstrike business, in one place.',
                  style: text.bodyLarge,
                ),
              ),
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: curve,
                builder: (_, _) => WovenBand(
                  height: 36,
                  seed: 11,
                  progress: curve.value.clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(height: OneSpaceTokens.s6),
            ],
          ),
        ),
      ),
    );
  }
}
