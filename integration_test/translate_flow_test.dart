import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _stagingUrl = String.fromEnvironment('API_BASE_URL');
bool get _hasStagingUrl => _stagingUrl.isNotEmpty;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Skip all tests when no staging URL is configured
  if (!_hasStagingUrl) {
    debugPrint('Integration tests skipped: STAGING_API_URL not set.');
    return;
  }

  group('Translate Flow', () {
    testWidgets(
        'Login → navigate to Terjemah → enter text → receive translation',
        (tester) async {
      // TODO: requires staging API + valid test account
      // 1. Login with test credentials
      // 2. Tap Terjemah tab
      // 3. Enter "abah inya"
      // 4. Tap Terjemahkan
      // 5. Expect translation result card to appear
      // 6. Expect translated text present
    });
  });
}
