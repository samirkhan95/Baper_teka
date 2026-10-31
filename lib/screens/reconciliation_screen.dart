import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/retro_theme.dart';
import '../theme/retro_widgets.dart';
import '../models/app_transaction.dart';
import '../utils/transaction_helper.dart';
import '../utils/monthly_flow_calculator.dart';
import '../widgets/monthly_money_flow_graph.dart';

class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  String? _selectedCategoryFilter;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0, locale: 'en_IN');
    final isRetro = context.watch<AppProvider>().isRetroMode;

    if (isRetro) {
      return _buildRetroReconciliationScreen(context, currencyFormat);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Money Flow')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final flowData = MonthlyFlowCalculator.computeMonthlyFlow(
            allTransactions: provider.transactions,
            selectedMonth: _selectedMonth,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Selector
                _buildMonthSelector(isRetro: false),

                const SizedBox(height: 20),

                // Interactive Monthly Money Flow Graph Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Money Flow',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Empty state or Graph
                if (flowData.monthTransactions.isEmpty)
                  _buildEmptyMonthCard(flowData, currencyFormat, isRetro: false)
                else
                  MonthlyMoneyFlowGraph(
                    flowData: flowData,
                    isRetro: false,
                  ),

                const SizedBox(height: 28),

                // Category Breakdown & Interactive Filter Section
                _buildCategoryBreakdown(context, provider.transactions, currencyFormat, isRetro: false),

                const SizedBox(height: 28),

                // Withdrawal Breakdown by Card
                _buildCardBreakdown(provider, currencyFormat, isRetro: false),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRetroReconciliationScreen(BuildContext context, NumberFormat currencyFormat) {
    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              final flowData = MonthlyFlowCalculator.computeMonthlyFlow(
                allTransactions: provider.transactions,
                selectedMonth: _selectedMonth,
              );

              return Column(
                children: [
                  // Retro Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        RetroIconButton(
                          icon: Icons.arrow_back,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'MONEY FLOW ANALYTICS',
                          style: RetroTheme.headingStyle(fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Retro Month Selector
                          _buildMonthSelector(isRetro: true),

                          const SizedBox(height: 16),

                          const RetroSectionLabel(label: 'MONTHLY MONEY FLOW GRAPH'),
                          const SizedBox(height: 12),

                          if (flowData.monthTransactions.isEmpty)
                            _buildEmptyMonthCard(flowData, currencyFormat, isRetro: true)
                          else
                            MonthlyMoneyFlowGraph(
                              flowData: flowData,
                              isRetro: true,
                            ),

                          const SizedBox(height: 28),

                          // Retro Category Breakdown
                          _buildCategoryBreakdown(context, provider.transactions, currencyFormat, isRetro: true),

                          const SizedBox(height: 28),

                          const RetroSectionLabel(label: 'WITHDRAWAL BREAKDOWN'),
                          const SizedBox(height: 14),

                          _buildCardBreakdown(provider, currencyFormat, isRetro: true),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector({required bool isRetro}) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);

    if (isRetro) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RetroIconButton(
            icon: Icons.chevron_left,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));
            },
          ),
          const SizedBox(width: 16),
          Text(
            monthLabel.toUpperCase(),
            style: RetroTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 16),
          RetroIconButton(
            icon: Icons.chevron_right,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));
            },
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));
            },
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              monthLabel,
              key: ValueKey(_selectedMonth),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMonthCard(MonthlyFlowData flow, NumberFormat currencyFormat, {required bool isRetro}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isRetro ? RetroColors.cardSurface : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRetro ? RetroColors.ink : Colors.grey.shade300,
          width: isRetro ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 40,
            color: isRetro ? RetroColors.ink : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            isRetro ? 'NO TRANSACTIONS THIS MONTH' : 'No Transactions Recorded This Month',
            style: isRetro
                ? RetroTheme.headingStyle(fontSize: 14, fontWeight: FontWeight.bold)
                : const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            isRetro ? 'Transactions recorded this month will appear here.' : 'Transactions recorded this month will appear here.',
            textAlign: TextAlign.center,
            style: isRetro
                ? RetroTheme.monoStyle(fontSize: 11)
                : TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Category Breakdown List & Interactive Filter Chips
  Widget _buildCategoryBreakdown(
    BuildContext context,
    List<AppTransaction> allTxs,
    NumberFormat currencyFormat, {
    required bool isRetro,
  }) {
    final monthlyExpenses = allTxs.where((tx) =>
        tx.type == TransactionType.expense &&
        tx.date.month == _selectedMonth.month &&
        tx.date.year == _selectedMonth.year).toList();

    final totalSpent = monthlyExpenses.fold(0.0, (sum, tx) => sum + tx.amount);

    final Map<String, double> categorySums = {};
    for (var tx in monthlyExpenses) {
      final cat = TransactionHelper.getCategoryName(tx);
      categorySums[cat] = (categorySums[cat] ?? 0.0) + tx.amount;
    }

    final sortedCategories = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRetro ? 'CATEGORY FILTERS & EXPENSES' : 'Top Expenses & Category Breakdown',
              style: isRetro
                  ? RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.w800)
                  : const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_selectedCategoryFilter != null)
              GestureDetector(
                onTap: () => setState(() => _selectedCategoryFilter = null),
                child: Text(
                  isRetro ? 'CLEAR FILTER' : 'Clear Filter',
                  style: isRetro
                      ? RetroTheme.monoStyle(fontSize: 11, color: RetroColors.expenseRed, fontWeight: FontWeight.bold)
                      : const TextStyle(fontSize: 12, color: AppTheme.expenseColor, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        if (sortedCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              isRetro ? 'NO EXPENSES RECORDED' : 'No expenses recorded for this month',
              style: isRetro ? RetroTheme.monoStyle(fontSize: 11) : TextStyle(color: Colors.grey[500]),
            ),
          )
        else
          ...sortedCategories.map((entry) {
            final catName = entry.key;
            final catAmount = entry.value;
            final pct = totalSpent > 0 ? (catAmount / totalSpent) : 0.0;
            final isSelected = _selectedCategoryFilter == catName;

            final sampleTx = AppTransaction(
              id: '',
              type: TransactionType.expense,
              amount: 0,
              date: DateTime.now(),
              note: catName,
            );
            final icon = TransactionHelper.getIcon(sampleTx);

            Widget tile = Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRetro
                    ? (isSelected ? RetroColors.mint : RetroColors.cardSurface)
                    : (isSelected
                        ? AppTheme.expenseColor.withValues(alpha: 0.1)
                        : Theme.of(context).cardTheme.color),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRetro
                      ? RetroColors.ink
                      : (isSelected ? AppTheme.expenseColor : Colors.grey.withValues(alpha: 0.1)),
                  width: isRetro ? 2.5 : 1.0,
                ),
                boxShadow: isRetro
                    ? const [BoxShadow(color: RetroColors.ink, offset: Offset(3, 3), blurRadius: 0)]
                    : null,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isRetro
                              ? RetroColors.expensePastel
                              : AppTheme.expenseColor.withValues(alpha: 0.1),
                          shape: isRetro ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: isRetro ? BorderRadius.circular(12) : null,
                          border: isRetro ? Border.all(color: RetroColors.ink, width: 2.0) : null,
                        ),
                        child: Icon(icon, size: 20, color: isRetro ? RetroColors.ink : AppTheme.expenseColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              catName,
                              style: isRetro
                                  ? RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                  : const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(pct * 100).toStringAsFixed(1)}% of total spending',
                              style: isRetro
                                  ? RetroTheme.monoStyle(fontSize: 10)
                                  : TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormat.format(catAmount),
                        style: isRetro
                            ? RetroTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.w900)
                            : const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: isRetro
                          ? RetroColors.paperBg
                          : (Theme.of(context).brightness == Brightness.light ? Colors.grey[200] : Colors.grey[800]),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isRetro ? RetroColors.expenseRed : AppTheme.expenseColor,
                      ),
                    ),
                  ),
                ],
              ),
            );

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (_selectedCategoryFilter == catName) {
                    _selectedCategoryFilter = null;
                  } else {
                    _selectedCategoryFilter = catName;
                  }
                });
              },
              child: tile,
            );
          }),
      ],
    );
  }

  Widget _buildCardBreakdown(AppProvider provider, NumberFormat currencyFormat, {required bool isRetro}) {
    final withdrawn = provider.getMonthlyWithdrawn(_selectedMonth);

    if (isRetro) {
      return Column(
        children: provider.cards.map((card) {
          final cardWithdrawn = provider.transactions
              .where((tx) =>
                  tx.type == TransactionType.cashIn &&
                  tx.cardId == card.id &&
                  tx.date.month == _selectedMonth.month &&
                  tx.date.year == _selectedMonth.year)
              .fold(0.0, (sum, tx) => sum + tx.amount);

          if (cardWithdrawn == 0) return const SizedBox.shrink();

          return RetroCard(
            margin: const EdgeInsets.only(bottom: 12),
            shadowOffset: const Offset(3, 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.name.toUpperCase(),
                  style: RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormat.format(cardWithdrawn),
                  style: RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Withdrawal Breakdown",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...provider.cards.map((card) {
          final cardWithdrawn = provider.transactions
              .where((tx) =>
                  tx.type == TransactionType.cashIn &&
                  tx.cardId == card.id &&
                  tx.date.month == _selectedMonth.month &&
                  tx.date.year == _selectedMonth.year)
              .fold(0.0, (sum, tx) => sum + tx.amount);

          if (cardWithdrawn == 0) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(card.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(currencyFormat.format(cardWithdrawn)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: withdrawn > 0 ? (cardWithdrawn / withdrawn) : 0,
                  backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[200] : Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(card.color),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
