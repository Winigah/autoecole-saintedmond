import 'package:flutter_test/flutter_test.dart';
import 'package:candidat_mobile/main.dart';

void main() {
  testWidgets('AutoEcolePro Candidat Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AutoEcoleProCandidatApp());

    // Verify that the title is rendered
    expect(find.text('AutoÉcole Pro Candidat'), findsOneWidget);
    expect(find.text("Accéder à mon Espace"), findsOneWidget);
  });
}
