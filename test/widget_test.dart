import 'package:flutter_test/flutter_test.dart';
import 'package:taskflutter/main.dart';

void main() {
  testWidgets('GritTracker app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GritTrackerApp());
    expect(find.text('GritTracker'), findsOneWidget);
  });
}
