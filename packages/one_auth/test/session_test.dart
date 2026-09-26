import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';

import 'fakes.dart';

void main() {
  late FakeAuthenticator auth;
  late InMemoryTokenStore store;

  ProviderContainer container() => ProviderContainer.test(
    overrides: [
      authenticatorProvider.overrideWithValue(auth),
      tokenStoreProvider.overrideWithValue(store),
    ],
  );

  Future<SessionState> settled(ProviderContainer c) async {
    c.read(sessionProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    final state = c.read(sessionProvider);
    return state;
  }

  setUp(() {
    auth = FakeAuthenticator();
    store = InMemoryTokenStore();
  });

  test('restores to signed out with nothing stored', () async {
    final c = container();
    expect(c.read(sessionProvider), isA<SessionRestoring>());
    expect(await settled(c), isA<SignedOut>());
  });

  test('restores a stored session', () async {
    await store.write(auth.next);
    final state = await settled(container());
    expect(state, isA<SignedIn>());
    expect((state as SignedIn).claims.displayName, 'Adaeze');
  });

  test('refreshes an expiring stored session on restore', () async {
    await store.write(
      TokenSet(
        accessToken: 'old',
        refreshToken: 'r',
        expiresAt: DateTime.utc(2000),
      ),
    );
    final c = container();
    await settled(c);
    await Future<void>.delayed(Duration.zero);
    final state = c.read(sessionProvider) as SignedIn;
    expect(auth.refreshes, 1);
    expect(state.tokens.accessToken, 'access-refreshed-1');
    expect(state.tokens.refreshToken, 'r');
  });

  test('sign in stores tokens and signs in', () async {
    final c = container();
    await settled(c);
    await c.read(sessionProvider.notifier).signIn();
    expect(c.read(sessionProvider), isA<SignedIn>());
    expect(await store.read(), auth.next);
  });

  test('a cancelled sign in returns quietly to signed out', () async {
    auth.signInFailure = const CancelledFailure();
    final c = container();
    await settled(c);
    await c.read(sessionProvider.notifier).signIn();
    final state = c.read(sessionProvider) as SignedOut;
    expect(state.failure, isNull);
  });

  test('a failed sign in keeps the reason', () async {
    auth.signInFailure = const NetworkFailure();
    final c = container();
    await settled(c);
    await c.read(sessionProvider.notifier).signIn();
    expect(
      (c.read(sessionProvider) as SignedOut).failure,
      isA<NetworkFailure>(),
    );
  });

  test('accessToken refreshes once for concurrent callers', () async {
    await store.write(
      TokenSet(
        accessToken: 'old',
        refreshToken: 'r',
        expiresAt: DateTime.utc(2030),
      ),
    );
    final c = container();
    await settled(c);
    // Make the stored token look expired now.
    await store.write(
      TokenSet(
        accessToken: 'old',
        refreshToken: 'r',
        expiresAt: DateTime.utc(2000),
      ),
    );
    await c.read(sessionProvider.notifier).restore();
    auth
      ..refreshes = 0
      ..refreshDelay = const Duration(milliseconds: 10);
    // restore() already refreshed; expire again to exercise accessToken().
    c.read(sessionProvider.notifier).state = SignedIn(
      TokenSet(
        accessToken: 'old',
        refreshToken: 'r',
        expiresAt: DateTime.utc(2000),
      ),
    );
    final tokens = await Future.wait([
      c.read(sessionProvider.notifier).accessToken(),
      c.read(sessionProvider.notifier).accessToken(),
      c.read(sessionProvider.notifier).accessToken(),
    ]);
    expect(auth.refreshes, 1);
    expect(tokens.toSet(), {'access-refreshed-1'});
  });

  test('a dead refresh token signs out and clears storage', () async {
    auth.refreshFailure = const UnauthorizedFailure();
    await store.write(
      TokenSet(
        accessToken: 'old',
        refreshToken: 'r',
        expiresAt: DateTime.utc(2000),
      ),
    );
    final c = container();
    await settled(c);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(sessionProvider), isA<SignedOut>());
    expect(await store.read(), isNull);
  });

  test('an offline refresh keeps the session', () async {
    auth.refreshFailure = const NetworkFailure();
    await store.write(
      TokenSet(
        accessToken: 'old',
        refreshToken: 'r',
        expiresAt: DateTime.utc(2000),
      ),
    );
    final c = container();
    await settled(c);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(sessionProvider), isA<SignedIn>());
    expect(await store.read(), isNotNull);
  });

  test('sign out clears storage and ends the browser session', () async {
    await store.write(auth.next);
    final c = container();
    await settled(c);
    await c.read(sessionProvider.notifier).signOut();
    expect(c.read(sessionProvider), isA<SignedOut>());
    expect(await store.read(), isNull);
    expect(auth.endSessions, 1);
  });

  test('accessToken is null when signed out', () async {
    final c = container();
    await settled(c);
    expect(await c.read(sessionProvider.notifier).accessToken(), isNull);
  });
}
