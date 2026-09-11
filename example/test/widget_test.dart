import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Animal Island Gallery App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimalIslandGalleryApp());
    await tester.pump();

    // Verify title ribbon renders
    expect(find.text('Animal Island UI'), findsOneWidget);
  });
}
