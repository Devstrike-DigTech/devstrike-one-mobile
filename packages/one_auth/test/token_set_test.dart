import 'package:flutter_test/flutter_test.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';

import 'fakes.dart';

void main() {
  final now = DateTime.utc(2026, 9, 26, 12);

  test('round-trips through storage encoding', () {
    final tokens = TokenSet(
      accessToken: 'a',
      refreshToken: 'r',
      idToken: 'i',
      expiresAt: now,
      scopes: const ['openid'],
    );
    expect(TokenSet.decode(tokens.encode()), tokens);
  });

  test('decode tolerates corrupt storage', () {
    expect(TokenSet.decode(null), isNull);
    expect(TokenSet.decode('{not json'), isNull);
    expect(TokenSet.decode('[1,2]'), isNull);
    expect(TokenSet.decode('{"accessToken": 1}'), isNull);
  });

  test('expiry uses the clock and a margin', () {
    withClock(Clock.fixed(now), () {
      final soon = TokenSet(
        accessToken: 'a',
        expiresAt: now.add(const Duration(seconds: 30)),
      );
      final later = TokenSet(
        accessToken: 'a',
        expiresAt: now.add(const Duration(minutes: 10)),
      );
      expect(soon.isExpiring(), isTrue);
      expect(later.isExpiring(), isFalse);
    });
  });

  test('refreshedWith keeps tokens the server did not rotate', () {
    final old = TokenSet(
      accessToken: 'a',
      refreshToken: 'r',
      idToken: 'i',
      expiresAt: now,
      scopes: const ['openid'],
    );
    final merged = old.refreshedWith(
      TokenSet(accessToken: 'b', expiresAt: now.add(const Duration(hours: 1))),
    );
    expect(merged.accessToken, 'b');
    expect(merged.refreshToken, 'r');
    expect(merged.idToken, 'i');
    expect(merged.scopes, ['openid']);
  });

  test('toString never prints tokens', () {
    final tokens = TokenSet(
      accessToken: 'secret-access',
      refreshToken: 'secret-refresh',
      expiresAt: now,
    );
    expect(tokens.toString(), isNot(contains('secret')));
  });

  group('IdTokenClaims', () {
    test('decodes display claims', () {
      final claims = IdTokenClaims.decode(
        fakeIdToken({
          'sub': 'p_1',
          'name': 'Adaeze Okafor',
          'given_name': 'Adaeze',
          'phone_number': '+2348030000001',
          'one_orgs': [
            {'id': 'o_1', 'name': 'Palmwine Hospitality Ltd', 'role': 'owner'},
          ],
        }),
      );
      expect(claims.subject, 'p_1');
      expect(claims.displayName, 'Adaeze');
      expect(claims.phoneNumber, '+2348030000001');
      expect(claims.organisations.single['name'], 'Palmwine Hospitality Ltd');
    });

    test('is empty for malformed tokens', () {
      expect(IdTokenClaims.decode('nope').raw, isEmpty);
      expect(IdTokenClaims.decode('a.%%%.c').raw, isEmpty);
      expect(IdTokenClaims.decode(null).displayName, 'One member');
    });
  });

  group('OneAuthConfig.forApp', () {
    test('builds redirect URIs from the scheme and allows http locally', () {
      final config = OneAuthConfig.forApp(
        config: OneConfig(
          flavor: OneFlavor.staging,
          apiBaseUrl: Uri.parse('http://10.0.2.2:4100'),
          oidcIssuer: Uri.parse('http://10.0.2.2:4100/oidc'),
        ),
        clientId: 'one-app',
        redirectScheme: 'ng.devstrike.one',
        scopes: OneAuthConfig.customerScopes,
      );
      expect(config.redirectUrl, 'ng.devstrike.one:/oauthredirect');
      expect(config.postLogoutRedirectUrl, 'ng.devstrike.one:/logout');
      expect(config.allowInsecureConnections, isTrue);
      expect(config.scopes, contains('offline_access'));
    });

    test('refuses an http issuer in production', () {
      expect(
        () => OneAuthConfig.forApp(
          config: OneConfig(
            flavor: OneFlavor.production,
            apiBaseUrl: Uri.parse('http://localhost:4100'),
            oidcIssuer: Uri.parse('http://localhost:4100/oidc'),
          ),
          clientId: 'one-app',
          redirectScheme: 'ng.devstrike.one',
          scopes: OneAuthConfig.customerScopes,
        ),
        throwsStateError,
      );
    });
  });
}
