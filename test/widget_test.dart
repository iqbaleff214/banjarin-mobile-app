import 'package:banjarin/core/router/app_router.dart';
import 'package:banjarin/core/theme/app_theme.dart';
import 'package:banjarin/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders without errors using light theme and router',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        title: 'Banjarin',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: createRouter(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

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
}
