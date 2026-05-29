import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow', () {
    testWidgets('Register → verify email notice → login → logout → login again',
        (tester) async {
      // TODO: requires staging API credentials
      // 1. Launch app
      // 2. Navigate to Register
      // 3. Fill in valid credentials
      // 4. Submit → expect Verify Email Notice screen
      // 5. Navigate to Login (simulate verified email)
      // 6. Login with same credentials → expect Home screen
      // 7. Navigate to Profile → tap Keluar → expect Home (unauthenticated)
      // 8. Login again → expect Home screen
    });

    testWidgets('Forgot password screen submits without error', (tester) async {
      // TODO: requires staging API
      // 1. Navigate to Login
      // 2. Tap "Lupa kata sandi?"
      // 3. Enter any email
      // 4. Submit → expect success message shown
    });
  });
}
