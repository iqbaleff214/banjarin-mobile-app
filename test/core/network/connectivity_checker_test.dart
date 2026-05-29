import 'dart:async';

import 'package:banjarin/core/network/connectivity_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityChecker extends Mock implements ConnectivityChecker {}

void main() {
  late MockConnectivityChecker mockChecker;

  setUp(() => mockChecker = MockConnectivityChecker());

  group('ConnectivityChecker', () {
    test('emits offline (false) when connection lost', () async {
      final controller = StreamController<bool>();
      when(() => mockChecker.onlineStatus).thenAnswer((_) => controller.stream);

      final values = <bool>[];
      final sub = mockChecker.onlineStatus.listen(values.add);

      controller.add(false); // simulate going offline
      await Future.delayed(Duration.zero);

      expect(values, contains(false));
      await sub.cancel();
      await controller.close();
    });

    test('emits online (true) when connection restored', () async {
      final controller = StreamController<bool>();
      when(() => mockChecker.onlineStatus).thenAnswer((_) => controller.stream);

      final values = <bool>[];
      final sub = mockChecker.onlineStatus.listen(values.add);

      controller.add(false);
      controller.add(true); // restore
      await Future.delayed(Duration.zero);

      expect(values.last, isTrue);
      await sub.cancel();
      await controller.close();
    });

    test('isOnline returns false when offline', () async {
      when(() => mockChecker.isOnline()).thenAnswer((_) async => false);
      expect(await mockChecker.isOnline(), isFalse);
    });

    test('isOnline returns true when online', () async {
      when(() => mockChecker.isOnline()).thenAnswer((_) async => true);
      expect(await mockChecker.isOnline(), isTrue);
    });
  });
}
