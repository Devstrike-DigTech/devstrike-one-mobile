import 'package:flutter/foundation.dart';
import 'package:one_core/one_core.dart';

/// How an app signs in with One ID.
@immutable
class OneAuthConfig {
  /// Creates a configuration.
  const OneAuthConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUrl,
    required this.postLogoutRedirectUrl,
    required this.scopes,
    this.allowInsecureConnections = false,
  });

  /// Derives the configuration from the app's [OneConfig].
  ///
  /// [redirectScheme] is the app's private-use URI scheme (reverse domain,
  /// per RFC 8252), registered with One ID as `<scheme>:/oauthredirect`
  /// and `<scheme>:/logout`. Plain-HTTP issuers (local core-api) are only
  /// allowed outside the production flavour.
  factory OneAuthConfig.forApp({
    required OneConfig config,
    required String clientId,
    required String redirectScheme,
    required List<String> scopes,
  }) {
    final insecure = config.oidcIssuer.scheme == 'http';
    if (insecure && config.flavor.isProduction) {
      throw StateError('Production builds must use an https One ID issuer.');
    }
    return OneAuthConfig(
      issuer: config.oidcIssuer,
      clientId: clientId,
      redirectUrl: '$redirectScheme:/oauthredirect',
      postLogoutRedirectUrl: '$redirectScheme:/logout',
      scopes: scopes,
      allowInsecureConnections: insecure,
    );
  }

  /// One ID issuer (`<core-api>/oidc`); discovery is at
  /// `<issuer>/.well-known/openid-configuration`.
  final Uri issuer;

  /// Public OIDC client id registered for this app.
  final String clientId;

  /// Redirect URI after sign-in.
  final String redirectUrl;

  /// Redirect URI after sign-out.
  final String postLogoutRedirectUrl;

  /// Requested scopes.
  final List<String> scopes;

  /// Allow `http://` (local development against 10.0.2.2 / localhost only).
  final bool allowInsecureConnections;

  /// Scopes for the customer app (One).
  static const List<String> customerScopes = [
    'openid',
    'profile',
    'email',
    'phone',
    'offline_access',
    'one:customer',
  ];

  /// Scopes for the owner app (One Business).
  static const List<String> businessScopes = [
    'openid',
    'profile',
    'email',
    'phone',
    'offline_access',
    'one:orgs',
  ];
}
