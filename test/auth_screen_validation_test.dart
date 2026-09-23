import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/screens/auth_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'dummy-key-for-testing-1234567890',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        pkceAsyncStorage: EmptyGotrueAsyncStorage(),
      ),
    );
  });

  testWidgets('password validator enforces minimum length of 8 characters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);
    final submitButton = find.byType(FilledButton);

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, '1234567'); // 7 characters
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);

    await tester.enterText(passwordField, '12345678'); // 8 characters
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsNothing);
  });
}

class EmptyGotrueAsyncStorage extends GotrueAsyncStorage {
  const EmptyGotrueAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> setItem({required String key, required String value}) async {}

  @override
  Future<void> removeItem({required String key}) async {}
}
