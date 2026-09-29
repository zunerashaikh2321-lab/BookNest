import 'package:flutter_test/flutter_test.dart';
import 'package:booknest/main.dart';

void main() {
  testWidgets('BookNest app loads successfully', (WidgetTester tester) async {
    // Build the BookNest app.
    await tester.pumpWidget(const BookNestApp());

    // Allow the first frame to render.
    await tester.pumpAndSettle();

    // Basic smoke test:
    // Verify that the app builds without crashing.
    expect(find.byType(BookNestApp), findsOneWidget);
  });
}