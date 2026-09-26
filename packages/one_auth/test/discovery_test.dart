import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';

/// `test/fixtures/openid_configuration.json` was captured from the live
/// core-api (`curl localhost:4100/oidc/.well-known/openid-configuration`).
/// The same run completed a real authorization code + PKCE exchange and a
/// refresh-token rotation for both native clients (see the workspace README).
void main() {
  final discovery = jsonDecode(
    File('test/fixtures/openid_configuration.json').readAsStringSync(),
  ) as Map<String, Object?>;

  OneAuthConfig configFor(
    TargetPlatform platform, {
    required bool business,
    String? issuer,
  }) {
    final config = OneConfig.resolve(platform: platform, apiBaseUrl: issuer);
    return OneAuthConfig.forApp(
      config: config,
      clientId: business ? 'one-business' : 'one-app',
      redirectScheme: business
          ? 'ng.devstrike.one.business.staging'
          : 'ng.devstrike.one.staging',
      scopes: business
          ? OneAuthConfig.businessScopes
          : OneAuthConfig.customerScopes,
    );
  }

  test('the customer app matches One ID (iOS simulator, localhost)', () {
    expect(
      discoveryProblems(
        configFor(TargetPlatform.iOS, business: false),
        discovery,
      ),
      isEmpty,
    );
  });

  test('the business app matches One ID (iOS simulator, localhost)', () {
    expect(
      discoveryProblems(
        configFor(TargetPlatform.iOS, business: true),
        discovery,
      ),
      isEmpty,
    );
  });

  test('the Android emulator with adb reverse (localhost) matches', () {
    final config = configFor(
      TargetPlatform.android,
      business: false,
      issuer: 'http://localhost:4100',
    );
    expect(discoveryProblems(config, discovery), isEmpty);
  });

  test('the Android emulator on 10.0.2.2 hits an issuer mismatch', () {
    // core-api advertises http://localhost:4100/oidc, so from the emulator the
    // endpoints are unreachable and the ID token issuer differs. Sign-in
    // there needs `adb reverse tcp:4100 tcp:4100` and a localhost issuer.
    final problems = discoveryProblems(
      configFor(TargetPlatform.android, business: false),
      discovery,
    );
    expect(problems.first, startsWith('issuer:'));
  });

  test('flags a missing scope', () {
    final config = OneAuthConfig(
      issuer: Uri.parse('http://localhost:4100/oidc'),
      clientId: 'one-app',
      redirectUrl: 'ng.devstrike.one:/oauthredirect',
      postLogoutRedirectUrl: 'ng.devstrike.one:/logout',
      scopes: const ['openid', 'one:everything'],
      allowInsecureConnections: true,
    );
    expect(discoveryProblems(config, discovery), [
      'scope "one:everything" is not supported',
    ]);
  });
}
