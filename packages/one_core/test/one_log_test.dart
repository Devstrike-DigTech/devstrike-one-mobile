import 'package:flutter_test/flutter_test.dart';
import 'package:one_core/one_core.dart';

void main() {
  test('redacts bearer tokens and token fields', () {
    const raw =
        'GET /me Authorization: Bearer abc.def.ghi '
        '{"access_token":"s3cret","refresh_token": "r3fresh"} password=hunter2';
    final safe = OneLog.redact(raw);
    expect(safe, isNot(contains('abc.def.ghi')));
    expect(safe, isNot(contains('s3cret')));
    expect(safe, isNot(contains('r3fresh')));
    expect(safe, isNot(contains('hunter2')));
    expect(safe, contains('Bearer [redacted]'));
  });

  test('init routes records to the sink', () {
    final seen = <String>[];
    OneLog.init(level: Level.ALL, sink: (r) => seen.add(r.message));
    Logger('test').info('hello');
    expect(seen, contains('hello'));
  });
}
