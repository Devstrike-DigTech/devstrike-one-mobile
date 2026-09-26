/// Response bodies shaped like core-api's, built from the One Listing v1
/// contract fixtures.
const Map<String, Object?> palmwineListing = {
  'id': '01926d4e-8a4b-7c3e-9f00-5a1b2c3d4e5f',
  'externalId': 'prop_palmwine',
  'productKey': 'hotel',
  'productName': 'HotelOS',
  'tenantId': '01926d4e-0000-7000-8000-000000000001',
  'storeId': '01926d4e-0000-7000-8000-000000000002',
  'category': 'lodging.hotel',
  'title': 'The Palmwine House',
  'summary': 'A quiet boutique hotel two streets from the lagoon.',
  'description': 'Twenty-four rooms, a rooftop bar and a kitchen that takes jollof seriously.',
  'location': {
    'address': '12 Admiralty Way',
    'area': 'Lekki Phase 1',
    'city': 'Lagos',
    'state': 'Lagos',
    'country': 'NG',
    'point': {'lat': 6.4474, 'lng': 3.4723},
  },
  'price': {'fromMinor': '4500000', 'currency': 'NGN', 'unit': 'night'},
  'rating': {'average': 4.6, 'count': 128},
  'images': [
    {
      'url': 'https://cdn.example.test/palmwine/lobby.jpg',
      'alt': 'Lobby with palm-frond screens',
    },
  ],
  'tags': ['rooftop', 'wifi', 'pool'],
  'actions': [
    {
      'kind': 'book',
      'label': 'Book a room',
      'url': 'https://palmwine.hotelos.ng/book',
    },
    {'kind': 'view', 'url': 'https://palmwine.hotelos.ng'},
  ],
  'attributes': {'checkIn': '14:00', 'rooms': 24, 'hourly': true},
  'status': 'active',
  'updatedAt': '2026-09-20T10:15:00.000+01:00',
};

/// A minimal listing: only the required fields.
const Map<String, Object?> minimalListing = {
  'id': '01926d4e-8a4b-7c3e-9f00-000000000009',
  'productKey': 'salon',
  'tenantId': '01926d4e-0000-7000-8000-000000000003',
  'category': 'beauty.hair_salon',
  'title': 'Kinks & Co',
  'location': {'city': 'Abuja', 'country': 'NG'},
  'price': null,
  'rating': null,
  'actions': [
    {'kind': 'book', 'url': 'https://kinks.salonos.ng/book'},
  ],
  'status': 'active',
  'updatedAt': '2026-09-21T08:00:00Z',
};
