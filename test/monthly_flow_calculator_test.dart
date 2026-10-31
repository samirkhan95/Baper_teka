import 'package:flutter_test/flutter_test.dart';
import 'package:baper_teka/models/app_transaction.dart';
import 'package:baper_teka/utils/monthly_flow_calculator.dart';

void main() {
  group('MonthlyFlowCalculator - 100% Monthly Isolation & Accounting Model', () {
    test('Acceptance Tests A-D: Running balance chronologically from 0', () {
      final transactions = [
        AppTransaction(
          id: 'tx1',
          type: TransactionType.cashIn,
          amount: 15000,
          date: DateTime(2026, 10, 1, 10, 0),
        ),
        AppTransaction(
          id: 'tx2',
          type: TransactionType.expense,
          amount: 2000,
          date: DateTime(2026, 10, 5, 14, 0),
        ),
        AppTransaction(
          id: 'tx3',
          type: TransactionType.cashIn,
          amount: 2000,
          date: DateTime(2026, 10, 15, 11, 0),
        ),
        AppTransaction(
          id: 'tx4',
          type: TransactionType.expense,
          amount: 5000,
          date: DateTime(2026, 10, 20, 16, 0),
        ),
      ];

      final flow = MonthlyFlowCalculator.computeMonthlyFlow(
        allTransactions: transactions,
        selectedMonth: DateTime(2026, 10, 1),
      );

      expect(flow.openingBalance, 0.0);
      expect(flow.totalMoneyIn, 17000.0);
      expect(flow.totalExpenses, 7000.0);
      expect(flow.monthlyClosingBalance, 10000.0);

      // Point 0 is opening balance (0.0)
      expect(flow.points[0].isOpening, true);
      expect(flow.points[0].balance, 0.0);

      // Point 1: +15,000 -> 15,000 (Incoming, green)
      expect(flow.points[1].isIncoming, true);
      expect(flow.points[1].balance, 15000.0);

      // Point 2: -2,000 -> 13,000 (Expense, red)
      expect(flow.points[2].isExpense, true);
      expect(flow.points[2].balance, 13000.0);

      // Point 3: +2,000 -> 15,000 (Incoming, green)
      expect(flow.points[3].isIncoming, true);
      expect(flow.points[3].balance, 15000.0);

      // Point 4: -5,000 -> 10,000 (Expense, red)
      expect(flow.points[4].isExpense, true);
      expect(flow.points[4].balance, 10000.0);
    });

    test('Opening balance carries forward from prior months but month remains isolated', () {
      final transactions = [
        // August
        AppTransaction(
          id: 'aug1',
          type: TransactionType.cashIn,
          amount: 20000,
          date: DateTime(2026, 8, 5),
        ),
        AppTransaction(
          id: 'aug2',
          type: TransactionType.expense,
          amount: 15000,
          date: DateTime(2026, 8, 20),
        ),
        // September
        AppTransaction(
          id: 'sep1',
          type: TransactionType.cashIn,
          amount: 8000,
          date: DateTime(2026, 9, 2),
        ),
        AppTransaction(
          id: 'sep2',
          type: TransactionType.expense,
          amount: 3000,
          date: DateTime(2026, 9, 15),
        ),
      ];

      // August verification:
      final augFlow = MonthlyFlowCalculator.computeMonthlyFlow(
        allTransactions: transactions,
        selectedMonth: DateTime(2026, 8, 1),
      );
      expect(augFlow.openingBalance, 0.0);
      expect(augFlow.totalMoneyIn, 20000.0);
      expect(augFlow.totalExpenses, 15000.0);
      expect(augFlow.monthlyClosingBalance, 5000.0);

      // September verification: Carries forward August's 5,000 as opening balance
      final sepFlow = MonthlyFlowCalculator.computeMonthlyFlow(
        allTransactions: transactions,
        selectedMonth: DateTime(2026, 9, 1),
      );
      expect(sepFlow.openingBalance, 5000.0);
      expect(sepFlow.totalMoneyIn, 8000.0);
      expect(sepFlow.totalExpenses, 3000.0);
      expect(sepFlow.monthlyClosingBalance, 10000.0); // 5000 + 8000 - 3000

      // October verification: Empty month carries forward 10,000 opening balance
      final octFlow = MonthlyFlowCalculator.computeMonthlyFlow(
        allTransactions: transactions,
        selectedMonth: DateTime(2026, 10, 1),
      );
      expect(octFlow.monthTransactions.isEmpty, true);
      expect(octFlow.openingBalance, 10000.0);
      expect(octFlow.monthlyClosingBalance, 10000.0);
    });

    test('Leap year and non-leap year days calculation', () {
      final leapFlow = MonthlyFlowCalculator.computeMonthlyFlow(
        allTransactions: [],
        selectedMonth: DateTime(2024, 2, 1),
      );
      expect(leapFlow.daysInMonth, 29);

      final nonLeapFlow = MonthlyFlowCalculator.computeMonthlyFlow(
        allTransactions: [],
        selectedMonth: DateTime(2025, 2, 1),
      );
      expect(nonLeapFlow.daysInMonth, 28);
    });

    test('Negative balance calculation', () {
      final transactions = [
        AppTransaction(
          id: 'nov1',
          type: TransactionType.expense,
          amount: 4000,
          date: DateTime(2026, 11, 3),
        ),
      ];

      final flow = MonthlyFlowCalculator.computeMonthlyFlow(
        allTransactions: transactions,
        selectedMonth: DateTime(2026, 11, 1),
      );

      expect(flow.lowestBalance, -4000.0);
      expect(flow.monthlyClosingBalance, -4000.0);
    });

    test('Y-axis compact Taka formatting', () {
      expect(MonthlyFlowCalculator.formatCompactTaka(15000), '৳15K');
      expect(MonthlyFlowCalculator.formatCompactTaka(17000), '৳17K');
      expect(MonthlyFlowCalculator.formatCompactTaka(14700), '৳14.7K');
      expect(MonthlyFlowCalculator.formatCompactTaka(-6000), '-৳6K');
      expect(MonthlyFlowCalculator.formatCompactTaka(0), '৳0');
    });
  });
}
