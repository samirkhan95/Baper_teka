import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/app_transaction.dart';
import '../models/bank_card.dart';
import '../theme/app_theme.dart';
import '../theme/retro_theme.dart';
import '../theme/retro_widgets.dart';
import '../services/pdf_service.dart';
import '../utils/transaction_helper.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0, locale: 'en_IN');
    final isRetro = context.watch<AppProvider>().isRetroMode;

    if (isRetro) {
      return _buildRetroStatementScreen(context, currencyFormat);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Statement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              HapticFeedback.lightImpact();
              final picked = await showDateRangePicker(
                context: context,
                initialDateRange: _dateRange,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                HapticFeedback.lightImpact();
                setState(() => _dateRange = picked);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              final provider = context.read<AppProvider>();
              final filteredTxs = provider.transactions.where((tx) {
                return tx.date.isAfter(_dateRange.start.subtract(const Duration(days: 1))) &&
                       tx.date.isBefore(_dateRange.end.add(const Duration(days: 1)));
              }).toList()..sort((a, b) => b.date.compareTo(a.date));
              _handleShare(context, filteredTxs, provider.cards);
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final filteredTxs = provider.transactions.where((tx) {
            return tx.date.isAfter(_dateRange.start.subtract(const Duration(days: 1))) &&
                   tx.date.isBefore(_dateRange.end.add(const Duration(days: 1)));
          }).toList()..sort((a, b) => b.date.compareTo(a.date));

          final totalWithdrawn = filteredTxs
              .where((tx) => tx.type == TransactionType.cashIn || tx.type == TransactionType.income)
              .fold(0.0, (sum, tx) => sum + tx.amount);
          
          final totalSpent = filteredTxs
              .where((tx) => tx.type == TransactionType.expense)
              .fold(0.0, (sum, tx) => sum + tx.amount);

          return CustomScrollView(
            slivers: [
              // Header Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statement Period',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 24),
                      _buildSummaryCard(totalWithdrawn, totalSpent, currencyFormat),
                    ],
                  ),
                ),
              ),

              // Breakdown Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'TRANSACTION DETAILS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                  ),
                ),
              ),

              // Transaction List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = filteredTxs[index];
                      return _buildStatementTile(tx, currencyFormat, provider);
                    },
                    childCount: filteredTxs.length,
                  ),
                ),
              ),
              
              if (filteredTxs.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No transactions for this period')),
                ),
                
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRetroStatementScreen(BuildContext context, NumberFormat currencyFormat) {
    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              final filteredTxs = provider.transactions.where((tx) {
                return tx.date.isAfter(_dateRange.start.subtract(const Duration(days: 1))) &&
                       tx.date.isBefore(_dateRange.end.add(const Duration(days: 1)));
              }).toList()..sort((a, b) => b.date.compareTo(a.date));

              final totalWithdrawn = filteredTxs
                  .where((tx) => tx.type == TransactionType.cashIn || tx.type == TransactionType.income)
                  .fold(0.0, (sum, tx) => sum + tx.amount);
              
              final totalSpent = filteredTxs
                  .where((tx) => tx.type == TransactionType.expense)
                  .fold(0.0, (sum, tx) => sum + tx.amount);

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
                          'STATEMENT',
                          style: RetroTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        RetroIconButton(
                          icon: Icons.date_range,
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              initialDateRange: _dateRange,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              HapticFeedback.lightImpact();
                              setState(() => _dateRange = picked);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        RetroIconButton(
                          icon: Icons.share_outlined,
                          onPressed: () => _handleShare(context, filteredTxs, provider.cards),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STATEMENT PERIOD', style: RetroTheme.monoStyle(fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}'.toUpperCase(),
                            style: RetroTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 20),

                          // Deep Green Retro Summary Card
                          RetroCard(
                            color: RetroColors.deepGreen,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('INCOMING', style: RetroTheme.monoStyle(fontSize: 10, color: Colors.white70)),
                                          const SizedBox(height: 4),
                                          Text(
                                            currencyFormat.format(totalWithdrawn),
                                            style: RetroTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1.5,
                                      height: 36,
                                      color: Colors.white38,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('OUTGOING', style: RetroTheme.monoStyle(fontSize: 10, color: Colors.white70)),
                                          const SizedBox(height: 4),
                                          Text(
                                            currencyFormat.format(totalSpent),
                                            style: RetroTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.w900, color: RetroColors.expensePastel),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(height: 1.5, color: Colors.white38),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('NET BALANCE', style: RetroTheme.monoStyle(fontSize: 11, color: Colors.white70)),
                                    Text(
                                      currencyFormat.format(totalWithdrawn - totalSpent),
                                      style: RetroTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          const RetroSectionLabel(label: 'TRANSACTION DETAILS'),

                          const SizedBox(height: 16),

                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredTxs.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tx = filteredTxs[index];
                              return _buildRetroStatementTile(tx, currencyFormat, provider);
                            },
                          ),

                          if (filteredTxs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text('NO TRANSACTIONS FOR THIS PERIOD', style: RetroTheme.monoStyle(fontSize: 11)),
                              ),
                            ),
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

  Widget _buildRetroStatementTile(AppTransaction tx, NumberFormat format, AppProvider provider) {
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

    String? subtitle;
    if (tx.type == TransactionType.cashIn && tx.cardId != null) {
      final card = provider.cards.any((c) => c.id == tx.cardId) 
          ? provider.cards.firstWhere((c) => c.id == tx.cardId) 
          : null;
      subtitle = card != null ? 'VIA ${card.name.toUpperCase()}' : 'BANK WITHDRAWAL';
    } else {
      subtitle = DateFormat('dd MMM, hh:mm a').format(tx.date).toUpperCase();
    }

    return RetroCard(
      padding: const EdgeInsets.all(14),
      shadowOffset: const Offset(3, 4),
      child: Row(
        children: [
          RetroCategoryIcon(
            icon: TransactionHelper.getIcon(tx),
            backgroundColor: bgColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: RetroTheme.monoStyle(fontSize: 10)),
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
    );
  }

  Widget _buildSummaryCard(double withdrawn, double spent, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSummaryItem('INCOMING', withdrawn, Colors.white, format, Icons.arrow_downward),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildSummaryItem('OUTGOING', spent, Colors.white.withValues(alpha: 0.8), format, Icons.arrow_upward),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NET BALANCE', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(format.format(withdrawn - spent), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, NumberFormat format, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(format.format(amount), style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildStatementTile(AppTransaction tx, NumberFormat format, AppProvider provider) {
    final isExpense = tx.type == TransactionType.expense;
    final isIncome = tx.type == TransactionType.income;
    
    String title = (() {
      final s = (tx.note != null && tx.note!.trim().isNotEmpty)
          ? tx.note!.trim()
          : (isExpense ? 'Expense' : (isIncome ? 'From Father' : 'ATM Withdrawal'));
      return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    })();

    String? subtitle;
    if (tx.type == TransactionType.cashIn && tx.cardId != null) {
      final card = provider.cards.any((c) => c.id == tx.cardId) 
          ? provider.cards.firstWhere((c) => c.id == tx.cardId) 
          : null;
      subtitle = card != null ? 'Via ${card.name}' : 'Bank Withdrawal';
    } else {
      subtitle = DateFormat('dd MMM, hh:mm a').format(tx.date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isExpense ? AppTheme.expenseColor.withValues(alpha: 0.1) : AppTheme.cashInColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              TransactionHelper.getIcon(tx),
              color: isExpense ? AppTheme.expenseColor : AppTheme.cashInColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(
            (isExpense ? '-' : '+') + format.format(tx.amount),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: isExpense ? AppTheme.expenseColor : AppTheme.cashInColor,
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context, List<AppTransaction> transactions, List<BankCard> cards) {
    HapticFeedback.heavyImpact();
    final isRetro = context.read<AppProvider>().isRetroMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isRetro ? RetroColors.paperBg : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: isRetro ? Border.all(color: RetroColors.ink, width: 2.5) : null,
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: isRetro ? RetroColors.ink : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Icon(Icons.check_circle_outline, color: isRetro ? RetroColors.brandGreen : AppTheme.cashInColor, size: 64),
            const SizedBox(height: 16),
            Text(
              'Statement Prepared',
              style: isRetro
                  ? RetroTheme.headingStyle(fontSize: 22, fontWeight: FontWeight.w900)
                  : const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction report for the selected period has been compiled and is ready to share as a PDF.',
              textAlign: TextAlign.center,
              style: isRetro
                  ? RetroTheme.monoStyle(fontSize: 12)
                  : TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: isRetro
                  ? RetroButton(
                      label: 'Share PDF Now',
                      onPressed: () async {
                        Navigator.pop(context);
                        await PdfService.generateAndShareStatement(
                          dateRange: _dateRange,
                          transactions: transactions,
                          cards: cards,
                        );
                      },
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        await PdfService.generateAndShareStatement(
                          dateRange: _dateRange,
                          transactions: transactions,
                          cards: cards,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Share PDF Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
