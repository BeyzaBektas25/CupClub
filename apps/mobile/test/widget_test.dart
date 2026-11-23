import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('CupClub uygulaması açılır', (WidgetTester tester) async {
    await tester.pumpWidget(const CupClubApp());

    expect(find.byType(CupClubApp), findsOneWidget);
  });
}
