import 'package:flutter_test/flutter_test.dart';
import 'package:my_drive/main.dart';

void main() {
    testWidgets('shows the welcome screen without a token', (tester) async {
        await tester.pumpWidget(const MyDriveApp());
        await tester.pumpAndSettle();

        expect(find.text('Welcome to My Drive'), findsOneWidget);
        expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('get started opens the registration screen', (tester) async {
        await tester.pumpWidget(const MyDriveApp());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        expect(find.text('Create your account'), findsOneWidget);
        expect(find.text('Create account'), findsOneWidget);
    });
}
