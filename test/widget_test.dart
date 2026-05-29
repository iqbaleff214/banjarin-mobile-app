import 'package:banjarin/core/theme/app_colors.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Router integration test removed — requires full DI which is wired in main().
  // Router structure is covered by individual page widget tests.

  test('Light theme uses correct primary color', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppColors.primary);
  });

  test('Dark theme uses correct primary color', () {
    final theme = AppTheme.dark;
    expect(theme.colorScheme.primary, AppColors.primaryLight);
  });

  test('Light theme error color is correct', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.error, AppColors.error);
  });

  test('Dark theme scaffold background is dark', () {
    final theme = AppTheme.dark;
    expect(theme.scaffoldBackgroundColor, AppColors.backgroundDark);
  });

  testWidgets('MaterialApp renders with light theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('Banjarin')),
      ),
    );
    expect(find.text('Banjarin'), findsOneWidget);
  });
}
