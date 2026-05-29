import 'dart:convert';

import 'package:banjarin/core/storage/hive_local_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;
  late HiveLocalCache cache;

  setUp(() {
    mockBox = MockBox();
    cache = HiveLocalCache(mockBox);
  });

  group('HiveLocalCache.get', () {
    test('returns data before TTL expires', () async {
      final futureExpiry = DateTime.now()
          .add(const Duration(minutes: 10))
          .millisecondsSinceEpoch;

      when(() => mockBox.get('words__expiry')).thenReturn(futureExpiry);
      when(() => mockBox.get('words')).thenReturn('"hello"');

      final result = await cache.get<String>('words');

      expect(result, 'hello');
    });

    test('returns null and invalidates when TTL elapsed', () async {
      final pastExpiry = DateTime.now()
          .subtract(const Duration(seconds: 1))
          .millisecondsSinceEpoch;

      when(() => mockBox.get('words__expiry')).thenReturn(pastExpiry);
      when(() => mockBox.delete('words')).thenAnswer((_) async {});
      when(() => mockBox.delete('words__expiry')).thenAnswer((_) async {});

      final result = await cache.get<String>('words');

      expect(result, isNull);
      verify(() => mockBox.delete('words')).called(1);
      verify(() => mockBox.delete('words__expiry')).called(1);
    });

    test('returns null when expiry key is absent', () async {
      when(() => mockBox.get('words__expiry')).thenReturn(null);

      final result = await cache.get<String>('words');

      expect(result, isNull);
    });

    test('returns null when value is absent despite valid expiry', () async {
      final futureExpiry = DateTime.now()
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;

      when(() => mockBox.get('words__expiry')).thenReturn(futureExpiry);
      when(() => mockBox.get('words')).thenReturn(null);

      final result = await cache.get<String>('words');

      expect(result, isNull);
    });

    test('returns Map when a JSON object is stored', () async {
      final futureExpiry = DateTime.now()
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      final encoded = jsonEncode({'id': '1', 'banjar': 'abah'});

      when(() => mockBox.get('word_detail__expiry')).thenReturn(futureExpiry);
      when(() => mockBox.get('word_detail')).thenReturn(encoded);

      final result = await cache.get<Map<String, dynamic>>('word_detail');

      expect(result, isA<Map<String, dynamic>>());
      expect(result!['banjar'], 'abah');
    });
  });

  group('HiveLocalCache.put', () {
    test('stores JSON-encoded value and expiry key', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await cache.put('words', {'data': 'value'});

      verify(() => mockBox.put('words', any())).called(1);
      verify(() => mockBox.put('words__expiry', any())).called(1);
    });

    test('uses custom TTL when provided', () async {
      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      final before = DateTime.now()
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      await cache.put('words', 'test', ttl: const Duration(minutes: 5));
      final after = DateTime.now()
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;

      final captured = verify(
        () => mockBox.put('words__expiry', captureAny()),
      ).captured;

      final storedExpiry = captured.first as int;
      expect(storedExpiry, greaterThanOrEqualTo(before));
      expect(storedExpiry, lessThanOrEqualTo(after));
    });
  });

  group('HiveLocalCache.invalidate', () {
    test('deletes value and expiry key', () async {
      when(() => mockBox.delete('words')).thenAnswer((_) async {});
      when(() => mockBox.delete('words__expiry')).thenAnswer((_) async {});

      await cache.invalidate('words');

      verify(() => mockBox.delete('words')).called(1);
      verify(() => mockBox.delete('words__expiry')).called(1);
    });
  });
}
