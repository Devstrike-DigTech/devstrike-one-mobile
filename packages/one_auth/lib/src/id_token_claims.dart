import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Claims read from an ID token, for display only.
///
/// The token came straight from the issuer over TLS during the code
/// exchange, and AppAuth checks issuer, audience and nonce; the signature is
/// not re-verified here, so never use these claims for authorisation
/// decisions (the API does that with the access token).
@immutable
class IdTokenClaims {
  /// Creates claims from a decoded payload.
  const IdTokenClaims(this.raw);

  /// Decodes the payload of a compact JWS. Returns empty claims for anything
  /// that is not a well-formed JWT.
  factory IdTokenClaims.decode(String? idToken) {
    if (idToken == null) return const IdTokenClaims({});
    final parts = idToken.split('.');
    if (parts.length != 3) return const IdTokenClaims({});
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      return IdTokenClaims(json is Map<String, Object?> ? json : const {});
    } on FormatException {
      return const IdTokenClaims({});
    }
  }

  /// All claims.
  final Map<String, Object?> raw;

  String? _string(String key) =>
      raw[key] is String ? raw[key]! as String : null;

  /// Subject: the person's One ID.
  String? get subject => _string('sub');

  /// Full name.
  String? get name => _string('name');

  /// Given name.
  String? get givenName => _string('given_name');

  /// Verified email, if shared.
  String? get email => _string('email');

  /// Verified phone number (E.164), if shared.
  String? get phoneNumber => _string('phone_number');

  /// The best short label for the signed-in person.
  String get displayName =>
      givenName ?? name ?? email ?? phoneNumber ?? 'One member';

  /// Organisation memberships (`one:orgs` scope) as `{ id, name, role }`
  /// maps; empty until One-1 issues the claim.
  List<Map<String, Object?>> get organisations => switch (raw['one_orgs']) {
    final List<Object?> list => list.whereType<Map<String, Object?>>().toList(
      growable: false,
    ),
    _ => const [],
  };
}
