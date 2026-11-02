import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/screens/login_screen.dart';

void main() {
  testWidgets('AutoEcolePro initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoEcoleProApp(initialScreen: LoginScreen()));
    expect(find.text('AutoÉcole Pro'), findsOneWidget);
    expect(find.text('Se Connecter'), findsOneWidget);
  });
}
