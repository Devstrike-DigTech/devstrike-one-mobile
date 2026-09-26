import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_auth/src/authenticator.dart';
import 'package:one_auth/src/id_token_claims.dart';
import 'package:one_auth/src/providers.dart';
import 'package:one_auth/src/token_set.dart';
import 'package:one_auth/src/token_store.dart';
import 'package:one_core/one_core.dart';

/// Where the person is in the sign-in lifecycle.
@immutable
sealed class SessionState {
  const SessionState();

  /// Whether someone is signed in.
  bool get isSignedIn => this is SignedIn;
}

/// Stored tokens are being read at launch.
final class SessionRestoring extends SessionState {
  /// Creates the state.
  const SessionRestoring();
}

/// No one is signed in. [failure] explains the last failed attempt, if any.
final class SignedOut extends SessionState {
  /// Creates the state.
  const SignedOut({this.failure});

  /// Why the last sign-in or refresh failed (not set for cancellations).
  final OneFailure? failure;
}

/// The browser sign-in is in progress.
final class SigningIn extends SessionState {
  /// Creates the state.
  const SigningIn();
}

/// Someone is signed in.
final class SignedIn extends SessionState {
  /// Creates the state.
  const SignedIn(this.tokens);

  /// Current tokens.
  final TokenSet tokens;

  /// Display claims.
  IdTokenClaims get claims => tokens.claims;
}

/// Owns the session: restore at launch, sign in, refresh, sign out.
///
/// Refreshes are single-flight: concurrent API calls that find the access
/// token expiring share one refresh request.
///
/// Dependencies come from [authenticatorProvider] and [tokenStoreProvider],
/// so tests override those two providers.
class SessionNotifier extends Notifier<SessionState> {
  Future<TokenSet?>? _refreshing;

  /// The One ID client.
  @protected
  OneAuthenticator authenticator() => ref.read(authenticatorProvider);

  /// Token persistence.
  @protected
  TokenStore store() => ref.read(tokenStoreProvider);

  static final Logger _log = Logger('one_auth.session');

  @override
  SessionState build() {
    unawaited(Future<void>.microtask(restore));
    return const SessionRestoring();
  }

  /// Reads stored tokens; refreshes them if they are about to expire.
  Future<void> restore() async {
    final saved = await store().read();
    if (!ref.mounted) return;
    if (saved == null) {
      state = const SignedOut();
      return;
    }
    state = SignedIn(saved);
    if (saved.isExpiring()) await _refresh(saved);
  }

  /// Opens One ID in the browser.
  Future<void> signIn({String? loginHint}) async {
    if (state is SigningIn) return;
    state = const SigningIn();
    try {
      final tokens = await authenticator().signIn(loginHint: loginHint);
      await store().write(tokens);
      if (ref.mounted) state = SignedIn(tokens);
    } on CancelledFailure {
      if (ref.mounted) state = const SignedOut();
    } on OneFailure catch (f) {
      if (ref.mounted) state = SignedOut(failure: f);
    }
  }

  /// Signs out locally and ends the One ID browser session.
  Future<void> signOut() async {
    final current = state;
    await store().clear();
    state = const SignedOut();
    if (current is SignedIn) {
      await authenticator().endSession(current.tokens);
    }
  }

  /// A valid access token for an API call, refreshing first if needed;
  /// `null` when signed out.
  Future<String?> accessToken() async {
    final current = state;
    if (current is! SignedIn) return null;
    if (!current.tokens.isExpiring()) return current.tokens.accessToken;
    final refreshed = await _refresh(current.tokens);
    return refreshed?.accessToken;
  }

  Future<TokenSet?> _refresh(TokenSet tokens) {
    return _refreshing ??= () async {
      try {
        final next = await authenticator().refresh(tokens);
        await store().write(next);
        if (ref.mounted) state = SignedIn(next);
        return next;
      } on UnauthorizedFailure catch (f) {
        // The refresh token is dead (revoked, expired, password changed).
        await store().clear();
        if (ref.mounted) state = SignedOut(failure: f);
        return null;
      } on OneFailure catch (f) {
        // Offline or One ID down: keep the session; the API will answer 401
        // if the old token is really unusable, and we try again next call.
        _log.info('Refresh deferred: ${f.code}');
        return tokens;
      } finally {
        _refreshing = null;
      }
    }();
  }
}
