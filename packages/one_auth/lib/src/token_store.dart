import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:one_auth/src/token_set.dart';

/// Persists the [TokenSet] between launches.
abstract interface class TokenStore {
  /// The saved tokens, or `null`.
  Future<TokenSet?> read();

  /// Saves [tokens], replacing any previous set.
  Future<void> write(TokenSet tokens);

  /// Forgets the tokens.
  Future<void> clear();
}

/// Keychain (iOS) / Keystore-backed (Android) storage.
///
/// iOS items are `first_unlock_this_device`: available to background refresh
/// after the first unlock, never synced to iCloud or restored onto another
/// device.
class SecureTokenStore implements TokenStore {
  /// Creates a store. [key] separates apps sharing a keychain group.
  const SecureTokenStore({
    this.key = 'one.session.tokens',
    this._storage = const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  });

  /// Storage key.
  final String key;
  final FlutterSecureStorage _storage;

  @override
  Future<TokenSet?> read() async =>
      TokenSet.decode(await _storage.read(key: key));

  @override
  Future<void> write(TokenSet tokens) =>
      _storage.write(key: key, value: tokens.encode());

  @override
  Future<void> clear() => _storage.delete(key: key);
}

/// Keeps tokens in memory only (tests, previews).
class InMemoryTokenStore implements TokenStore {
  /// Creates a store, optionally pre-filled.
  InMemoryTokenStore([this._tokens]);

  TokenSet? _tokens;

  /// Number of writes, for tests.
  int writes = 0;

  @override
  Future<TokenSet?> read() async => _tokens;

  @override
  Future<void> write(TokenSet tokens) async {
    writes++;
    _tokens = tokens;
  }

  @override
  Future<void> clear() async => _tokens = null;
}
