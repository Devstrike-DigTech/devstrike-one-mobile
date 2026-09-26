// Response bodies shaped like core-api's marketplace module
// (`apps/core-api/src/modules/marketplace/marketplace.service.ts`).

/// A search card.
const Map<String, Object?> palmwineCard = {
  'id': '01926d4e-8a4b-7c3e-9f00-5a1b2c3d4e5f',
  'productKey': 'hotel',
  'productName': 'HotelOS',
  'storeName': 'The Palmwine House',
  'locationId': '01926d4e-0000-7000-8000-000000000011',
  'slug': 'the-palmwine-house',
  'name': 'The Palmwine House',
  'category': 'lodging.hotel',
  'subcategories': ['lodging.boutique'],
  'summary': 'A quiet boutique hotel two streets from the lagoon.',
  'address': '12 Admiralty Way',
  'area': 'Lekki Phase 1',
  'city': 'Lagos',
  'state': 'Lagos',
  'country': 'NG',
  'geo': {'lat': 6.4474, 'lng': 3.4723},
  'priceFrom': {'amountMinor': 4500000, 'currency': 'NGN', 'unit': 'night'},
  'rating': {'average': 4.6, 'count': 128},
  'image': {
    'url': 'https://cdn.example.test/palmwine/lobby.jpg',
    'alt': 'Lobby with palm-frond screens',
  },
  'tags': ['rooftop', 'wifi', 'pool'],
  'bookingUrl': 'https://palmwine.hotelos.ng/book',
  'primaryAction': {
    'kind': 'book',
    'label': 'Book a room',
    'url': 'https://palmwine.hotelos.ng/book',
  },
  'distanceKm': null,
};

/// The detail body for [palmwineCard].
const Map<String, Object?> palmwineDetail = {
  ...palmwineCard,
  'description': 'Twenty-four rooms, a rooftop bar and a kitchen that takes jollof seriously.',
  'phone': '+2348030000001',
  'whatsapp': '+2348030000001',
  'openingHours': null,
  'images': [
    {
      'url': 'https://cdn.example.test/palmwine/lobby.jpg',
      'alt': 'Lobby with palm-frond screens',
    },
    {'url': 'https://cdn.example.test/palmwine/room.jpg', 'alt': 'Deluxe room'},
  ],
  'actions': [
    {
      'kind': 'book',
      'label': 'Book a room',
      'url': 'https://palmwine.hotelos.ng/book',
    },
    {'kind': 'view', 'url': 'https://palmwine.hotelos.ng'},
  ],
  'attributes': {'checkIn': '14:00', 'rooms': 24, 'hourly': true},
  'productSiteUrl': 'https://hotelos.ng',
  'updatedAt': '2026-09-20T10:15:00.000Z',
};

/// A card with only what core-api always sends.
const Map<String, Object?> minimalCard = {
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
  'area': null,
  'city': 'Abuja',
  'state': 'FCT',
  'country': 'NG',
  'geo': null,
  'priceFrom': null,
  'rating': null,
  'image': null,
  'tags': <Object?>[],
  'bookingUrl': null,
  'primaryAction': null,
  'distanceKm': 2.4,
};
