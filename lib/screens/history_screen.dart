import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/app_transaction.dart';
import '../theme/app_theme.dart';
import '../theme/retro_theme.dart';
import '../theme/retro_widgets.dart';
import 'add_expense_screen.dart';
import 'add_cash_in_screen.dart';
import 'add_from_father_screen.dart';
import '../utils/transaction_helper.dart';

class HistoryScreen extends StatefulWidget {
  final DateTime? selectedMonth;
  const HistoryScreen({super.key, this.selectedMonth});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionType? _filterType;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.selectedMonth ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0, locale: 'en_IN');
    final isRetro = context.watch<AppProvider>().isRetroMode;

    if (isRetro) {
      return _buildRetroHistoryScreen(context, currencyFormat);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          PopupMenuButton<TransactionType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              HapticFeedback.selectionClick();
              setState(() => _filterType = type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(value: TransactionType.cashIn, child: Text('Cash In')),
              const PopupMenuItem(value: TransactionType.expense, child: Text('Expense')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    key: ValueKey(_selectedMonth),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final filteredTxs = provider.transactions.where((tx) {
                  final matchesMonth = tx.date.month == _selectedMonth.month && tx.date.year == _selectedMonth.year;
                  final matchesType = _filterType == null || tx.type == _filterType;
                  return matchesMonth && matchesType;
                }).toList();

                if (filteredTxs.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions in ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredTxs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = filteredTxs[index];
                    return _buildTransactionTile(tx, currencyFormat, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroHistoryScreen(BuildContext context, NumberFormat currencyFormat) {
    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Retro App Bar
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
                      'HISTORY',
                      style: RetroTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Retro Month Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RetroIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase(),
                    style: RetroTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 16),
                  RetroIconButton(
                    icon: Icons.chevron_right,
                    onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Retro Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    RetroChip(
                      label: 'All',
                      isSelected: _filterType == null,
                      onTap: () => setState(() => _filterType = null),
                    ),
                    const SizedBox(width: 8),
                    RetroChip(
                      label: 'Cash In',
                      isSelected: _filterType == TransactionType.cashIn,
                      onTap: () => setState(() => _filterType = TransactionType.cashIn),
                    ),
                    const SizedBox(width: 8),
                    RetroChip(
                      label: 'Expense',
                      isSelected: _filterType == TransactionType.expense,
                      onTap: () => setState(() => _filterType = TransactionType.expense),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    final filteredTxs = provider.transactions.where((tx) {
                      final matchesMonth = tx.date.month == _selectedMonth.month && tx.date.year == _selectedMonth.year;
                      final matchesType = _filterType == null || tx.type == _filterType;
                      return matchesMonth && matchesType;
                    }).toList();

                    if (filteredTxs.isEmpty) {
                      return Center(
                        child: Text(
                          'NO TRANSACTIONS IN ${DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase()}',
                          style: RetroTheme.monoStyle(fontSize: 12),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredTxs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = filteredTxs[index];
                        return _buildRetroTransactionTile(tx, currencyFormat, provider);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetroTransactionTile(AppTransaction tx, NumberFormat format, AppProvider provider) {
    final isExpense = tx.type == TransactionType.expense;
    final isIncome = tx.type == TransactionType.income;

    final bgColor = isExpense
        ? RetroColors.expensePastel
        : (isIncome ? RetroColors.mint : RetroColors.infoBluePastel);

    String title = (() {
      final s = (tx.note != null && tx.note!.trim().isNotEmpty)
          ? tx.note!.trim()
          : (isExpense ? 'Expense' : (isIncome ? 'From Father' : 'ATM Withdrawal'));
      return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    })();

    void navigateToEdit() {
      HapticFeedback.lightImpact();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            if (isExpense) return AddExpenseScreen(editTransaction: tx);
            if (isIncome) return AddFromFatherScreen(editTransaction: tx);
            return AddCashInScreen(editTransaction: tx);
          },
        ),
      );
    }

    return RetroSlidableTile(
      key: Key(tx.id),
      onEdit: navigateToEdit,
      onDelete: () async {
        final confirmed = await _showDeleteConfirmation(context);
        if (confirmed) {
          provider.deleteTransaction(tx.id);
        }
      },
      child: RetroCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        radius: 18,
        shadowOffset: const Offset(3, 3.5),
        child: Row(
          children: [
            RetroCategoryIcon(
              icon: TransactionHelper.getIcon(tx),
              backgroundColor: bgColor,
              size: 38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    DateFormat('dd MMMM yyyy').format(tx.date).toUpperCase(),
                    style: RetroTheme.monoStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            Text(
              (isExpense ? '-' : '+') + format.format(tx.amount),
              style: RetroTheme.headingStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isExpense ? RetroColors.expenseRed : RetroColors.deepGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(AppTransaction tx, NumberFormat format, AppProvider provider) {
    final isExpense = tx.type == TransactionType.expense;
    final isIncome = tx.type == TransactionType.income;

    void navigateToEdit() {
      HapticFeedback.lightImpact();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            if (isExpense) return AddExpenseScreen(editTransaction: tx);
            if (isIncome) return AddFromFatherScreen(editTransaction: tx);
            return AddCashInScreen(editTransaction: tx);
          },
        ),
      );
    }

    return RetroSlidableTile(
      key: Key(tx.id),
      onEdit: navigateToEdit,
      onDelete: () async {
        final confirmed = await _showDeleteConfirmation(context);
        if (confirmed) {
          provider.deleteTransaction(tx.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isExpense 
                  ? AppTheme.expenseColor.withValues(alpha: 0.1)
                  : (isIncome 
                      ? AppTheme.cashInColor.withValues(alpha: 0.1)
                      : (provider.cards.any((c) => c.id == tx.cardId) 
                          ? provider.cards.firstWhere((c) => c.id == tx.cardId).color.withValues(alpha: 0.2)
                          : AppTheme.cashInColor.withValues(alpha: 0.1))),
              child: Icon(
                TransactionHelper.getIcon(tx),
                color: isExpense 
                    ? AppTheme.expenseColor 
                    : (isIncome 
                        ? AppTheme.cashInColor 
                        : (provider.cards.any((c) => c.id == tx.cardId) 
                            ? provider.cards.firstWhere((c) => c.id == tx.cardId).color 
                            : AppTheme.cashInColor)),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (() {
                      final s = (tx.note != null && tx.note!.trim().isNotEmpty)
                          ? tx.note!.trim()
                          : (isExpense ? 'Expense' : (isIncome ? 'From Father' : 'ATM Withdrawal'));
                      return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
                    })(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy').format(tx.date),
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Text(
              (isExpense ? '-' : '+') + format.format(tx.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? AppTheme.expenseColor : AppTheme.cashInColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
}
