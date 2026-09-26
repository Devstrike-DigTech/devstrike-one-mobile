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

/// Marketplace bodies shaped like core-api's (search card and detail).
const Map<String, Object?> palmwine = {
  'id': '01926d4e-8a4b-7c3e-9f00-5a1b2c3d4e5f',
  'productKey': 'hotel',
  'productName': 'HotelOS',
  'storeName': 'The Palmwine House',
  'slug': 'the-palmwine-house',
  'name': 'The Palmwine House',
  'category': 'lodging.hotel',
  'subcategories': <Object?>[],
  'summary': 'A quiet boutique hotel two streets from the lagoon.',
  'address': '12 Admiralty Way',
  'area': 'Lekki Phase 1',
  'city': 'Lagos',
  'state': 'Lagos',
  'country': 'NG',
  'geo': null,
  'priceFrom': {'amountMinor': 4500000, 'currency': 'NGN', 'unit': 'night'},
  'rating': {'average': 4.6, 'count': 128},
  'image': null,
  'tags': ['rooftop', 'pool'],
  'bookingUrl': 'https://palmwine.hotelos.ng/book',
  'primaryAction': {
    'kind': 'book',
    'label': 'Book a room',
    'url': 'https://palmwine.hotelos.ng/book',
  },
  'distanceKm': null,
};

const Map<String, Object?> palmwineDetail = {
  ...palmwine,
  'description': 'Twenty-four rooms, a rooftop bar and a kitchen that takes jollof seriously.',
  'images': <Object?>[],
  'actions': [
    {
      'kind': 'book',
      'label': 'Book a room',
      'url': 'https://palmwine.hotelos.ng/book',
    },
  ],
  'attributes': {'checkIn': '14:00', 'hourlyStays': true},
  'updatedAt': '2026-09-20T10:15:00Z',
};

const Map<String, Object?> kinks = {
  'id': '01926d4e-8a4b-7c3e-9f00-000000000009',
  'productKey': 'salon',
  'productName': null,
  'storeName': 'Kinks & Co',
  'slug': 'kinks-and-co',
  'name': 'Kinks & Co',
  'category': 'beauty.hair_salon',
  'subcategories': <Object?>[],
  'summary': null,
  'address': 'Plot 4 Aminu Kano Crescent',
  'area': 'Wuse II',
  'city': 'Abuja',
  'state': 'FCT',
  'country': 'NG',
  'geo': null,
  'priceFrom': null,
  'rating': null,
  'image': null,
  'tags': <Object?>[],
  'bookingUrl': 'https://kinks.salonos.ng/book',
  'primaryAction': {
    'kind': 'view',
    'label': null,
    'url': 'https://kinks.salonos.ng/book',
  },
  'distanceKm': null,
};
