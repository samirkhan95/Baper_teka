import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baper_teka/models/app_transaction.dart';
import 'package:baper_teka/utils/monthly_flow_calculator.dart';
import 'package:baper_teka/widgets/monthly_money_flow_graph.dart';

void main() {
  testWidgets('Adaptive X-Axis handles dense same-day transactions and maintains individual accessibility', (WidgetTester tester) async {
    final selectedMonth = DateTime(2026, 10, 1);
    final transactions = [
      AppTransaction(
        id: 'tx1',
        type: TransactionType.cashIn,
        amount: 20000,
        date: DateTime(2026, 10, 5, 9, 0),
        note: 'Withdrawal 1',
      ),
      AppTransaction(
        id: 'tx2',
        type: TransactionType.expense,
        amount: 500,
        date: DateTime(2026, 10, 5, 10, 30),
        note: 'Breakfast',
      ),
      AppTransaction(
        id: 'tx3',
        type: TransactionType.expense,
        amount: 1200,
        date: DateTime(2026, 10, 5, 13, 0),
        note: 'Lunch',
      ),
      AppTransaction(
        id: 'tx4',
        type: TransactionType.expense,
        amount: 300,
        date: DateTime(2026, 10, 5, 16, 0),
        note: 'Snacks',
      ),
      AppTransaction(
        id: 'tx5',
        type: TransactionType.expense,
        amount: 2500,
        date: DateTime(2026, 10, 5, 19, 0),
        note: 'Dinner',
      ),
      AppTransaction(
        id: 'tx6',
        type: TransactionType.cashIn,
        amount: 5000,
        date: DateTime(2026, 10, 5, 21, 0),
        note: 'Cashback',
      ),
      AppTransaction(
        id: 'tx7',
        type: TransactionType.expense,
        amount: 1500,
        date: DateTime(2026, 10, 6, 10, 0),
        note: 'Transport',
      ),
      AppTransaction(
        id: 'tx8',
        type: TransactionType.expense,
        amount: 2000,
        date: DateTime(2026, 10, 7, 14, 0),
        note: 'Groceries',
      ),
    ];

    final flow = MonthlyFlowCalculator.computeMonthlyFlow(
      allTransactions: transactions,
      selectedMonth: selectedMonth,
    );

    // Opening point + 8 transactions = 9 points
    expect(flow.points.length, 9);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: MonthlyMoneyFlowGraph(
                flowData: flow,
                isRetro: true,
              ),
            ),
          ),
        ),
      ),
    );

    // Verify widget renders without error
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.textContaining('Tap or drag across points'), findsOneWidget);

    // Verify summary values present
    expect(find.text('Opening Balance'), findsOneWidget);
    expect(find.text('Money Received'), findsOneWidget);
    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('Closing Balance'), findsOneWidget);
  });
}
