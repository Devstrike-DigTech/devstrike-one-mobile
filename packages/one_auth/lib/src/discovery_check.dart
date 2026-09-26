import 'package:one_auth/src/one_auth_config.dart';

/// Compares an app's [config] with One ID's discovery document
/// (`<issuer>/.well-known/openid-configuration`) and lists every mismatch
/// that would make sign-in fail on a device. Empty means compatible.
///
/// Used by the tests against a captured live document, and handy in a debug
/// build to explain an AppAuth error before it happens.
List<String> discoveryProblems(
  OneAuthConfig config,
  Map<String, Object?> discovery,
) {
  final problems = <String>[];
  List<String> list(String key) => switch (discovery[key]) {
    final List<Object?> l => l.whereType<String>().toList(),
    _ => const [],
  };

  final issuer = discovery['issuer'];
  if (issuer != config.issuer.toString()) {
    problems.add(
      'issuer: One ID says "$issuer" but the app uses "${config.issuer}". AppAuth rejects ID tokens '
      'from another issuer, and the endpoints in the document point at that host. On the Android '
      'emulator use `adb reverse tcp:4100 tcp:4100` with a localhost issuer.',
    );
  }
  for (final endpoint in [
    'authorization_endpoint',
    'token_endpoint',
    'end_session_endpoint',
  ]) {
    final value = discovery[endpoint];
    if (value is! String) {
      problems.add('$endpoint: missing');
    } else if (Uri.parse(value).host != config.issuer.host) {
      problems.add(
        '$endpoint: "$value" is not on the app\'s issuer host ${config.issuer.host}',
      );
    }
  }
  if (!list('code_challenge_methods_supported').contains('S256')) {
    problems.add('PKCE S256 is not supported');
  }
  if (!list('token_endpoint_auth_methods_supported').contains('none')) {
    problems.add(
      'public clients (token_endpoint_auth_method "none") are not supported',
    );
  }
  if (!list('grant_types_supported').contains('refresh_token')) {
    problems.add('refresh_token grant is not supported');
  }
  final scopes = list('scopes_supported');
  for (final scope in config.scopes) {
    if (!scopes.contains(scope)) {
      problems.add('scope "$scope" is not supported');
    }
  }
  if (!config.allowInsecureConnections && config.issuer.scheme != 'https') {
    problems.add(
      'issuer is not https but insecure connections are not allowed',
    );
  }
  return problems;
}
