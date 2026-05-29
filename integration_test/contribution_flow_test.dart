import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Contribution Flow', () {
    testWidgets(
        'Login → open word detail → FAB → submit new definition → check My Contributions',
        (tester) async {
      // TODO: requires staging API + verified test account
      // 1. Login with verified test account
      // 2. Open a word detail (e.g., "abah")
      // 3. Tap the FAB
      // 4. Select "Tambah definisi"
      // 5. Enter a definition in the form
      // 6. Submit
      // 7. Navigate to Profil → Kontribusiku
      // 8. Expect the submitted contribution visible with "Menunggu" status
    });
  });
}
