import 'dart:convert';

import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';

String fakeIdToken(Map<String, Object?> claims) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part(claims)}.sig';
}

final TokenSet ownerTokens = TokenSet(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  idToken: fakeIdToken({
    'sub': 'p_2',
    'given_name': 'Tunde',
    'email': 'tunde@palmwine.test',
    'one_orgs': [
      {'id': 'o_1', 'name': 'Palmwine Hospitality', 'role': 'owner'},
    ],
  }),
  expiresAt: DateTime.utc(2030),
);

class FakeAuthenticator implements OneAuthenticator {
  OneFailure? failure;
  int endSessions = 0;

  @override
  Future<TokenSet> signIn({String? loginHint}) async {
    if (failure != null) throw failure!;
    return ownerTokens;
  }

  @override
  Future<TokenSet> refresh(TokenSet current) async => current;

  @override
  Future<void> endSession(TokenSet current) async => endSessions++;
}
