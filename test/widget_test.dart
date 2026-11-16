import 'package:flutter_test/flutter_test.dart';
import 'package:my_drive/main.dart';

void main() {
  testWidgets('shows the My Drive landing screen', (tester) async {
    await tester.pumpWidget(const MyDriveApp());

    expect(find.text('Welcome to My Drive'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('opens the registration screen', (tester) async {
    await tester.pumpWidget(const MyDriveApp());
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
