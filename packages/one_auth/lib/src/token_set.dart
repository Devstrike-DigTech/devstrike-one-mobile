import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:one_auth/src/id_token_claims.dart';
import 'package:one_core/one_core.dart';

/// Tokens from One ID for one signed-in person.
@immutable
class TokenSet {
  /// Creates a token set.
  const TokenSet({
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
    this.idToken,
    this.scopes = const [],
  });

  /// Restores a token set saved with [toJson].
  factory TokenSet.fromJson(Map<String, Object?> json) => TokenSet(
    accessToken: json['accessToken']! as String,
    refreshToken: json['refreshToken'] as String?,
    idToken: json['idToken'] as String?,
    expiresAt: DateTime.parse(json['expiresAt']! as String),
    scopes: (json['scopes'] as List<Object?>? ?? const []).cast<String>(),
  );

  /// Decodes [encoded] (from [encode]); `null` when it is unreadable.
  static TokenSet? decode(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final json = jsonDecode(encoded);
      return json is Map<String, Object?> ? TokenSet.fromJson(json) : null;
    } on Object {
      // Corrupt storage (for example after a keystore reset): treat as
      // signed out rather than crashing on launch.
      return null;
    }
  }

  /// Bearer token for core-api.
  final String accessToken;

  /// Refresh token (requires the `offline_access` scope).
  final String? refreshToken;

  /// ID token, used for display claims and as the logout hint.
  final String? idToken;

  /// When [accessToken] expires (UTC).
  final DateTime expiresAt;

  /// Granted scopes.
  final List<String> scopes;

  /// Claims from [idToken].
  IdTokenClaims get claims => IdTokenClaims.decode(idToken);

  /// Whether the access token expires within [margin].
  bool isExpiring({Duration margin = const Duration(seconds: 60)}) =>
      OneTime.isExpiring(expiresAt, margin: margin);

  /// Whether a refresh is possible.
  bool get canRefresh => refreshToken != null && refreshToken!.isNotEmpty;

  /// A copy after a refresh; keeps the old refresh and ID tokens when the
  /// server does not rotate them.
  TokenSet refreshedWith(TokenSet next) => TokenSet(
    accessToken: next.accessToken,
    refreshToken: next.refreshToken ?? refreshToken,
    idToken: next.idToken ?? idToken,
    expiresAt: next.expiresAt,
    scopes: next.scopes.isEmpty ? scopes : next.scopes,
  );

  /// JSON for storage.
  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'scopes': scopes,
  };

  /// String form for storage.
  String encode() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      other is TokenSet &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.idToken == idToken &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode =>
      Object.hash(accessToken, refreshToken, idToken, expiresAt);

  // Never print tokens.
  @override
  String toString() =>
      'TokenSet(expiresAt: ${expiresAt.toIso8601String()}, refresh: $canRefresh)';
}
