import 'dart:convert';

import 'package:one_auth/one_auth.dart';

String fakeIdToken(Map<String, Object?> claims) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part(claims)}.sig';
}

final TokenSet adaezeTokens = TokenSet(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  idToken: fakeIdToken({
    'sub': 'p_1',
    'given_name': 'Adaeze',
    'email': 'ada@example.test',
  }),
  expiresAt: DateTime.utc(2030),
);

class FakeAuthenticator implements OneAuthenticator {
  int signIns = 0;
  int endSessions = 0;

  @override
  Future<TokenSet> signIn({String? loginHint}) async {
    signIns++;
    return adaezeTokens;
  }

  @override
  Future<TokenSet> refresh(TokenSet current) async => current;

  @override
  Future<void> endSession(TokenSet current) async => endSessions++;
}

const Map<String, Object?> palmwine = {
  'id': '01926d4e-8a4b-7c3e-9f00-5a1b2c3d4e5f',
  'productKey': 'hotel',
  'productName': 'HotelOS',
  'tenantId': '01926d4e-0000-7000-8000-000000000001',
  'category': 'lodging.hotel',
  'title': 'The Palmwine House',
  'summary': 'A quiet boutique hotel two streets from the lagoon.',
  'location': {'area': 'Lekki Phase 1', 'city': 'Lagos', 'country': 'NG'},
  'price': {'fromMinor': 4500000, 'currency': 'NGN', 'unit': 'night'},
  'rating': {'average': 4.6, 'count': 128},
  'tags': ['rooftop', 'pool'],
  'actions': [
    {
      'kind': 'book',
      'label': 'Book a room',
      'url': 'https://palmwine.hotelos.ng/book',
    },
  ],
  'attributes': {'checkIn': '14:00', 'hourlyStays': true},
  'status': 'active',
  'updatedAt': '2026-09-20T10:15:00Z',
};

const Map<String, Object?> kinks = {
  'id': '01926d4e-8a4b-7c3e-9f00-000000000009',
  'productKey': 'salon',
  'tenantId': '01926d4e-0000-7000-8000-000000000003',
  'category': 'beauty.hair_salon',
  'title': 'Kinks & Co',
  'location': {'area': 'Wuse II', 'city': 'Abuja', 'country': 'NG'},
  'price': null,
  'rating': null,
  'actions': [
    {'kind': 'book', 'url': 'https://kinks.salonos.ng/book'},
  ],
  'status': 'active',
  'updatedAt': '2026-09-21T08:00:00Z',
};
