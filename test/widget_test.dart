import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:login_system/main.dart';

void main() {
  testWidgets('VangtiChai app initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const VangtiChaiApp());
    expect(find.text('VangtiChai - Change Calculator'), findsOneWidget);
    
    expect(find.textContaining('৳ 0'), findsOneWidget);
    
    // Verify Taka label exists
    expect(find.text('Taka:'), findsOneWidget);
  });

  testWidgets('Digit buttons append correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const VangtiChaiApp());

    // Tap digit 2
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(find.textContaining('৳ 2'), findsOneWidget);

    // Tap digit 3
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.textContaining('৳ 23'), findsOneWidget);

    // Tap digit 4
    await tester.tap(find.text('4'));
    await tester.pump();
    expect(find.textContaining('৳ 234'), findsOneWidget);
  });

  testWidgets('Clear button resets amount', (WidgetTester tester) async {
    await tester.pumpWidget(const VangtiChaiApp());

    // Enter some digits
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();

    // Verify amount is 500
    expect(find.textContaining('৳ 500'), findsOneWidget);

    // Tap clear button
    await tester.tap(find.text('C'));
    await tester.pump();

    // Verify amount is reset to 0
    expect(find.textContaining('৳ 0'), findsOneWidget);
  });

  testWidgets('Backspace button removes last digit', (WidgetTester tester) async {
    await tester.pumpWidget(const VangtiChaiApp());

    // Enter 123
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.textContaining('৳ 123'), findsOneWidget);

    // Tap backspace
    await tester.tap(find.text('⌫'));
    await tester.pump();
    expect(find.textContaining('৳ 12'), findsOneWidget);

    // Tap backspace again
    await tester.tap(find.text('⌫'));
    await tester.pump();
    expect(find.textContaining('৳ 1'), findsOneWidget);
  });

  testWidgets('Change calculation displays correct denominations', (WidgetTester tester) async {
    await tester.pumpWidget(const VangtiChaiApp());

    // Enter 788
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('8'));
    await tester.pump();

    // Wait for widget to update
    await tester.pumpAndSettle();

    // Verify change breakdown is shown
    expect(find.text('Change Breakdown'), findsOneWidget);
    
    // Verify denomination labels exist
    expect(find.textContaining('৳ 500'), findsWidgets);
    expect(find.textContaining('৳ 100'), findsWidgets);
  });

  testWidgets('All keypad buttons are present', (WidgetTester tester) async {
    await tester.pumpWidget(const VangtiChaiApp());

    // Check for all digit buttons
    for (int i = 0; i <= 9; i++) {
      expect(find.text(i.toString()), findsOneWidget);
    }

    // Check for special buttons
    expect(find.text('C'), findsOneWidget);
    expect(find.text('⌫'), findsOneWidget);
  });

  testWidgets('Total notes counter updates correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const VangtiChaiApp());

    // Enter 500
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Should show "Total Notes: 1" for 500 taka
    expect(find.text('Total Notes: 1'), findsOneWidget);
  });
}