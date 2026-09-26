import 'package:one_api/one_api.dart';

/// Presentation helpers shared by the search list and the detail screen.
extension ListingFormatting on Listing {
  /// "₦45,000", or null when the product publishes no price.
  String? get priceLabel => price?.from.format();

  /// "HOTEL · HOTELOS" style eyebrow.
  String get eyebrow => '$categoryLabel · $productLabel';

  /// Label for the button that leaves One: "Continue on HotelOS".
  String get continueLabel => 'Continue on $productLabel';
}
