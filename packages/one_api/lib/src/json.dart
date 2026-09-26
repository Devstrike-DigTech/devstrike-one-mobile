/// Typed readers for decoded JSON. They throw [FormatException] with the
/// offending key so contract drift is easy to diagnose; the client turns
/// that into an `UnexpectedFailure`.
typedef Json = Map<String, Object?>;

/// Reads fields from a JSON object with explicit types.
extension type const JsonReader(Json json) {
  /// A required string.
  String string(String key) => switch (json[key]) {
    final String v => v,
    final Object? v => throw FormatException(
      '"$key" must be a string, got ${v.runtimeType}',
    ),
  };

  /// An optional string (null or absent is `null`).
  String? stringOrNull(String key) => switch (json[key]) {
    null => null,
    final String v => v,
    final Object v => throw FormatException(
      '"$key" must be a string, got ${v.runtimeType}',
    ),
  };

  /// A required integer. Accepts a numeric string, because 64-bit amounts
  /// (Postgres BIGINT) may be serialised as strings.
  int integer(String key) => switch (json[key]) {
    final int v => v,
    final double v when v == v.truncateToDouble() => v.toInt(),
    final String v when int.tryParse(v) != null => int.parse(v),
    final Object? v => throw FormatException(
      '"$key" must be an integer, got $v',
    ),
  };

  /// An optional integer.
  int? integerOrNull(String key) => json[key] == null ? null : integer(key);

  /// A required number.
  double number(String key) => switch (json[key]) {
    final num v => v.toDouble(),
    final String v when double.tryParse(v) != null => double.parse(v),
    final Object? v => throw FormatException('"$key" must be a number, got $v'),
  };

  /// An optional number.
  double? numberOrNull(String key) => json[key] == null ? null : number(key);

  /// A required object.
  Json object(String key) => switch (json[key]) {
    final Map<String, Object?> v => v,
    final Object? v => throw FormatException(
      '"$key" must be an object, got ${v.runtimeType}',
    ),
  };

  /// An optional object.
  Json? objectOrNull(String key) => json[key] == null ? null : object(key);

  /// A list of objects (absent is empty).
  List<Json> objects(String key) => switch (json[key]) {
    null => const [],
    final List<Object?> v => [
      for (final (i, e) in v.indexed)
        if (e is Map<String, Object?>)
          e
        else
          throw FormatException('"$key[$i]" must be an object'),
    ],
    final Object v => throw FormatException(
      '"$key" must be a list, got ${v.runtimeType}',
    ),
  };

  /// A list of strings (absent is empty).
  List<String> strings(String key) => switch (json[key]) {
    null => const [],
    final List<Object?> v => [
      for (final (i, e) in v.indexed)
        if (e is String)
          e
        else
          throw FormatException('"$key[$i]" must be a string'),
    ],
    final Object v => throw FormatException(
      '"$key" must be a list, got ${v.runtimeType}',
    ),
  };

  /// A required RFC 3339 timestamp.
  DateTime dateTime(String key) {
    final raw = string(key);
    return DateTime.tryParse(raw) ??
        (throw FormatException('"$key" is not a date-time: $raw'));
  }
}
