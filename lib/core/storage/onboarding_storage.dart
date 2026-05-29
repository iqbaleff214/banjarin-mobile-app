import 'package:hive_flutter/hive_flutter.dart';

class OnboardingStorage {
  static const _boxName = 'onboarding';
  static const _seenKey = 'seen';

  Future<bool> hasSeenOnboarding() async {
    final box = await Hive.openBox<bool>(_boxName);
    return box.get(_seenKey, defaultValue: false) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final box = await Hive.openBox<bool>(_boxName);
    await box.put(_seenKey, true);
  }
}
