import '../models/app_transaction.dart';

/// Represents a chronological point on the Monthly Money Flow Graph.
class MonthlyFlowPoint {
  final int day; // 1..31
  final DateTime dateTime;
  final double balance; // Running balance after this point
  final AppTransaction? transaction;
  final bool isOpening;

  const MonthlyFlowPoint({
    required this.day,
    required this.dateTime,
    required this.balance,
    this.transaction,
    this.isOpening = false,
  });

  bool get isIncoming =>
      transaction != null &&
      (transaction!.type == TransactionType.cashIn ||
          transaction!.type == TransactionType.income);

  bool get isExpense =>
      transaction != null && transaction!.type == TransactionType.expense;
}

/// Monthly Money Flow data structure holding strictly isolated monthly stats and points.
class MonthlyFlowData {
  final DateTime month;
  final double openingBalance;
  final double totalMoneyIn;
  final double totalExpenses;
  final double monthlyClosingBalance; // openingBalance + totalMoneyIn - totalExpenses
  final double highestBalance;
  final double lowestBalance;
  final List<MonthlyFlowPoint> points; // Monthly balance timeline points
  final List<AppTransaction> monthTransactions;

  const MonthlyFlowData({
    required this.month,
    required this.openingBalance,
    required this.totalMoneyIn,
    required this.totalExpenses,
    required this.monthlyClosingBalance,
    required this.highestBalance,
    required this.lowestBalance,
    required this.points,
    required this.monthTransactions,
  });

  int get daysInMonth {
    final nextMonthFirstDay = DateTime(month.year, month.month + 1, 1);
    final lastDayOfMonth = nextMonthFirstDay.subtract(const Duration(days: 1));
    return lastDayOfMonth.day;
  }
}

/// Pure business logic engine for calculating isolated monthly money flow.
class MonthlyFlowCalculator {
  /// Computes chronological running balance for [selectedMonth] with 100% monthly isolation.
  ///
  /// RULES:
  /// 1. The opening balance comes from the app's financial model (prior transactions before selected month).
  /// 2. Filter strictly by calendar month AND year: [selectedMonth.year, selectedMonth.month].
  /// 3. Chronological order: Incoming transactions increase running balance, expenses decrease it.
  /// 4. Each plotted point represents the balance immediately after that transaction.
  /// 5. Closing balance = openingBalance + totalMoneyIn - totalExpenses.
  /// 6. Y-axis range is dynamic with breathing room above and below.
  static MonthlyFlowData computeMonthlyFlow({
    required List<AppTransaction> allTransactions,
    required DateTime selectedMonth,
  }) {
    final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final nextMonthFirst = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    // 1. Calculate opening balance from all transactions before startOfMonth
    final priorTxs = allTransactions.where((tx) => tx.date.isBefore(startOfMonth)).toList();
    double openingBalance = 0.0;
    for (final tx in priorTxs) {
      if (tx.type == TransactionType.expense) {
        openingBalance -= tx.amount;
      } else {
        openingBalance += tx.amount;
      }
    }

    // 2. Filter transactions strictly within the selected month and year
    final monthTxs = allTransactions.where((tx) {
      return (tx.date.isAtSameMomentAs(startOfMonth) || tx.date.isAfter(startOfMonth)) &&
          tx.date.isBefore(nextMonthFirst);
    }).toList();

    // 3. Deterministic sort: chronological by date, then by ID
    monthTxs.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return a.id.compareTo(b.id);
    });

    // 4. Compute running balance and monthly statistics
    double runningBalance = openingBalance;
    double totalMoneyIn = 0.0;
    double totalExpenses = 0.0;
    double highestBalance = openingBalance;
    double lowestBalance = openingBalance;

    final List<MonthlyFlowPoint> points = [];

    // Neutral opening balance point at start of month
    points.add(MonthlyFlowPoint(
      day: 1,
      dateTime: startOfMonth,
      balance: openingBalance,
      transaction: null,
      isOpening: true,
    ));

    for (final tx in monthTxs) {
      if (tx.type == TransactionType.cashIn || tx.type == TransactionType.income) {
        runningBalance += tx.amount;
        totalMoneyIn += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        runningBalance -= tx.amount;
        totalExpenses += tx.amount;
      }

      if (runningBalance > highestBalance) highestBalance = runningBalance;
      if (runningBalance < lowestBalance) lowestBalance = runningBalance;

      points.add(MonthlyFlowPoint(
        day: tx.date.day,
        dateTime: tx.date,
        balance: runningBalance,
        transaction: tx,
        isOpening: false,
      ));
    }

    // If no transactions in the month, add end-of-month point to complete horizontal line
    if (monthTxs.isEmpty) {
      final lastDayNumber = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
      final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month, lastDayNumber, 23, 59, 59);
      points.add(MonthlyFlowPoint(
        day: lastDayNumber,
        dateTime: endOfMonth,
        balance: openingBalance,
        transaction: null,
        isOpening: true,
      ));
    }

    return MonthlyFlowData(
      month: startOfMonth,
      openingBalance: openingBalance,
      totalMoneyIn: totalMoneyIn,
      totalExpenses: totalExpenses,
      monthlyClosingBalance: runningBalance,
      highestBalance: highestBalance,
      lowestBalance: lowestBalance,
      points: points,
      monthTransactions: monthTxs,
    );
  }

  /// Compact Bangladesh Taka string representation (e.g. ৳1K, ৳5K, ৳15K, ৳100K, or ৳500)
  static String formatCompactTaka(double amount, {String symbol = '৳'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String result;
    if (absAmount >= 10000000) {
      final cr = absAmount / 10000000;
      result = '${_formatTrimmed(cr)}Cr';
    } else if (absAmount >= 100000) {
      final l = absAmount / 100000;
      result = '${_formatTrimmed(l)}L';
    } else if (absAmount >= 1000) {
      final k = absAmount / 1000;
      result = '${_formatTrimmed(k)}K';
    } else {
      result = absAmount.toStringAsFixed(0);
    }

    if (isNegative) {
      return '-$symbol$result';
    }
    return '$symbol$result';
  }

  static String _formatTrimmed(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }
}
