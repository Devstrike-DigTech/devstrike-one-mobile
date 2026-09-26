import 'dart:convert';

import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';

/// Builds an unsigned JWT with [claims] (tests only).
String fakeIdToken(Map<String, Object?> claims) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part(claims)}.sig';
}

/// A controllable [OneAuthenticator].
class FakeAuthenticator implements OneAuthenticator {
  OneFailure? signInFailure;
  OneFailure? refreshFailure;
  int signIns = 0;
  int refreshes = 0;
  int endSessions = 0;
  Duration refreshDelay = Duration.zero;

  TokenSet next = TokenSet(
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
    idToken: fakeIdToken({
      'sub': 'p_1',
      'given_name': 'Adaeze',
      'email': 'ada@example.test',
    }),
    expiresAt: DateTime.utc(2030),
  );

  @override
  Future<TokenSet> signIn({String? loginHint}) async {
    signIns++;
    if (signInFailure != null) throw signInFailure!;
    return next;
  }

  @override
  Future<TokenSet> refresh(TokenSet current) async {
    refreshes++;
    await Future<void>.delayed(refreshDelay);
    if (refreshFailure != null) throw refreshFailure!;
    return current.refreshedWith(
      TokenSet(
        accessToken: 'access-refreshed-$refreshes',
        expiresAt: OneTime.nowUtc().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<void> endSession(TokenSet current) async => endSessions++;
}
