import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    bool beforeRestartIsDarkTheme = false;

    testWidgets('test various setting options', (tester) async {
      app.main();

      await tester.pumpAndSettle();

      // open drawer
      await tester.dragFrom(
          tester.getTopLeft(find.byType(MaterialApp)), Offset(300, 0));

      await tester.pumpAndSettle();

      final Finder themeSwitch = find.byTooltip('dark theme');
      final beforeIsDarkTheme =
          Theme.of(tester.element(themeSwitch)).brightness == Brightness.dark;
      expect(themeSwitch, findsOneWidget);
      await tester.tap(themeSwitch);
      await tester.pumpAndSettle();
      beforeRestartIsDarkTheme =
          Theme.of(tester.element(themeSwitch)).brightness == Brightness.dark;
      expect(beforeIsDarkTheme, equals(!beforeRestartIsDarkTheme),
          reason: 'test if options was applied');
    });

    testWidgets('after restart preference reading test', (tester) async {
      app.main();

      await tester.pumpAndSettle();

      // open drawer
      await tester.dragFrom(
          tester.getTopLeft(find.byType(MaterialApp)), Offset(300, 0));

      await tester.pumpAndSettle();
      final Finder themeSwitch = find.byType(AppBar);
      final afterRebootIsDarkTheme =
          Theme.of(tester.element(themeSwitch)).brightness == Brightness.dark;
      expect(afterRebootIsDarkTheme, equals(beforeRestartIsDarkTheme),
          reason: 'test if options was persistant');
    });
  });
}
