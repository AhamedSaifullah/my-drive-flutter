import 'package:flutter_test/flutter_test.dart';
import 'package:my_drive/main.dart';

void main() {
    testWidgets('redirects to the login screen without a token', (tester) async {
        await tester.pumpWidget(const MyDriveApp());
        await tester.pumpAndSettle();

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('switches to the registration screen', (tester) async {
        await tester.pumpWidget(const MyDriveApp());
        await tester.pumpAndSettle();
        await tester.tap(find.text('New to My Drive? Create an account'));
        await tester.pump();

        expect(find.text('Create your account'), findsOneWidget);
        expect(find.text('Create account'), findsOneWidget);
    });
}
