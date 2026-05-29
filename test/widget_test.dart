import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders selectable app text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SelectionArea(
            child: Text('MyBand'),
          ),
        ),
      ),
    );

    expect(find.text('MyBand'), findsOneWidget);
  });
}
