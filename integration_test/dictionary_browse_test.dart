import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dictionary Browse', () {
    testWidgets('Open app → scroll word list → tap word → read detail',
        (tester) async {
      // TODO: requires staging API
      // 1. Launch app
      // 2. Expect Beranda page with word list
      // 3. Scroll down to load more words
      // 4. Tap first word card
      // 5. Expect Word Detail page with Banjar word title
      // 6. Switch to Definisi tab → expect definitions
      // 7. Switch to Contoh tab → expect examples
    });

    testWidgets('Search for "abah" → tap result → read definition',
        (tester) async {
      // TODO: requires staging API
      // 1. Launch app
      // 2. Tap search icon or Cari tab
      // 3. Type "abah"
      // 4. Wait for results
      // 5. Tap first result
      // 6. Expect Word Detail for "abah"
      // 7. Expect "ayah" in definitions
    });
  });
}
