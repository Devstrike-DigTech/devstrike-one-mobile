import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_core/one_core.dart';

void main() {
  group('OneFlavor.parse', () {
    test('recognises production spellings', () {
      expect(OneFlavor.parse('production'), OneFlavor.production);
      expect(OneFlavor.parse(' PROD '), OneFlavor.production);
    });

    test('falls back to staging for unknown or missing values', () {
      expect(OneFlavor.parse(null), OneFlavor.staging);
      expect(OneFlavor.parse(''), OneFlavor.staging);
      expect(OneFlavor.parse('prdouction'), OneFlavor.staging);
    });
  });

  group('OneConfig.resolve', () {
    test('uses the Android emulator host loopback when no URL is defined', () {
      final config = OneConfig.resolve(platform: TargetPlatform.android);
      expect(config.apiBaseUrl.toString(), 'http://10.0.2.2:4100');
      expect(config.oidcIssuer.toString(), 'http://10.0.2.2:4100/oidc');
      expect(config.isInsecure, isTrue);
      expect(config.flavor, OneFlavor.staging);
    });

    test('uses localhost for the iOS simulator', () {
      final config = OneConfig.resolve(platform: TargetPlatform.iOS);
      expect(config.apiBaseUrl.toString(), 'http://localhost:4100');
    });

    test('honours explicit values and trims a trailing slash', () {
      final config = OneConfig.resolve(
        platform: TargetPlatform.iOS,
        flavor: 'production',
        apiBaseUrl: 'https://api.example.test/',
      );
      expect(config.flavor, OneFlavor.production);
      expect(config.apiBaseUrl.toString(), 'https://api.example.test');
      expect(config.oidcIssuer.toString(), 'https://api.example.test/oidc');
      expect(config.isInsecure, isFalse);
    });

    test('keeps an explicit issuer', () {
      final config = OneConfig.resolve(
        platform: TargetPlatform.android,
        apiBaseUrl: 'https://api.example.test',
        oidcIssuer: 'https://id.example.test/oidc',
      );
      expect(config.oidcIssuer.toString(), 'https://id.example.test/oidc');
    });

    test('rejects a relative URL', () {
      expect(
        () => OneConfig.resolve(
          platform: TargetPlatform.android,
          apiBaseUrl: 'api.example.test',
        ),
        throwsArgumentError,
      );
    });
  });

  test('fromEnvironment works without any defines', () {
    final config = OneConfig.fromEnvironment(platform: TargetPlatform.iOS);
    expect(config.apiBaseUrl.host, 'localhost');
  });
}
