import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_band/features/auth/views/login_screen.dart';

void main() {
  testWidgets('shows the MyBand brand mark above the login title', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    final logo = find.byKey(const Key('login-brand-logo'));
    final title = find.text('MyBand');

    expect(logo, findsOneWidget);
    expect(title, findsOneWidget);
    expect(tester.getTopLeft(logo).dy, lessThan(tester.getTopLeft(title).dy));
  });
}
