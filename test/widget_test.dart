import 'package:flutter_test/flutter_test.dart';
import 'package:picstools/main.dart';
import 'package:picstools/core/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PicsToolsApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    await initServiceLocator();

    await tester.pumpWidget(const PicsToolsApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PICS'), findsOneWidget);
    expect(find.text('TOOLS'), findsOneWidget);

    // Fast-forward pending timers to settle splash transition
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
