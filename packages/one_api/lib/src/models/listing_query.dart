import 'package:meta/meta.dart';

/// Parameters for `GET /api/v1/marketplace/search`.
@immutable
class ListingQuery {
  /// Creates a query.
  const ListingQuery({
    this.text = '',
    this.category,
    this.city,
    this.page = 1,
    this.pageSize = 20,
  }) : assert(page >= 1, 'page is 1-based'),
       assert(pageSize > 0 && pageSize <= 100, 'pageSize is 1..100');

  /// Free text ("rooftop bar Lekki").
  final String text;

  /// Category prefix (`lodging`, `lodging.hotel`).
  final String? category;

  /// City filter.
  final String? city;

  /// 1-based page.
  final int page;

  /// Results per page.
  final int pageSize;

  /// Query parameters, omitting empty values.
  Map<String, Object> toQueryParameters() => {
    if (text.trim().isNotEmpty) 'q': text.trim(),
    if (category != null && category!.isNotEmpty) 'category': category!,
    if (city != null && city!.isNotEmpty) 'city': city!,
    'page': page,
    'pageSize': pageSize,
  };

  /// A copy with changes.
  ListingQuery copyWith({
    String? text,
    String? category,
    String? city,
    int? page,
    int? pageSize,
  }) => ListingQuery(
    text: text ?? this.text,
    category: category ?? this.category,
    city: city ?? this.city,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  bool operator ==(Object other) =>
      other is ListingQuery &&
      other.text == text &&
      other.category == category &&
      other.city == city &&
      other.page == page &&
      other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(text, category, city, page, pageSize);

  @override
  String toString() => 'ListingQuery(${toQueryParameters()})';
}
