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
import 'reconciliation_screen.dart';
import 'cards_management_screen.dart';
import 'history_screen.dart';
import 'statement_screen.dart';
import 'backup_screen.dart';
import '../utils/transaction_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedMonth = DateTime.now();

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.month == now.month && _selectedMonth.year == now.year;
  }

  void _showSettingsSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final isRetro = context.read<AppProvider>().isRetroMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isRetro ? RetroColors.paperBg : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: isRetro ? Border.all(color: RetroColors.ink, width: 2.5) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final isDark = provider.isDarkMode;
            final isRetro = provider.isRetroMode;

            Widget buildSettingsTile({
              required IconData icon,
              required String title,
              required String subtitle,
              required VoidCallback onTap,
              Color? iconBgColor,
            }) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isRetro ? RetroColors.cardSurface : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isRetro ? RetroColors.ink : AppTheme.primaryBlue.withValues(alpha: 0.05),
                        width: isRetro ? 2.5 : 1.0,
                      ),
                      boxShadow: isRetro
                          ? const [BoxShadow(color: RetroColors.ink, offset: Offset(2, 2), blurRadius: 0)]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconBgColor ?? (isRetro ? RetroColors.mint : AppTheme.primaryBlue.withValues(alpha: 0.1)),
                            shape: isRetro ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: isRetro ? BorderRadius.circular(10) : null,
                            border: isRetro ? Border.all(color: RetroColors.ink, width: 1.5) : null,
                          ),
                          child: Icon(icon, color: isRetro ? RetroColors.ink : AppTheme.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: isRetro
                                    ? RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                    : const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: isRetro
                                    ? RetroTheme.monoStyle(fontSize: 10)
                                    : TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: isRetro ? RetroColors.ink : Colors.grey[400], size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isRetro ? RetroColors.ink : Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SETTINGS',
                      style: isRetro
                          ? RetroTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.w900)
                          : const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // My Cards
                    buildSettingsTile(
                      icon: Icons.credit_card_outlined,
                      title: 'My Cards',
                      subtitle: 'Manage bank cards & limits',
                      iconBgColor: isRetro ? RetroColors.infoBluePastel : null,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsManagementScreen()));
                      },
                    ),

                    // Analytics & Balance
                    buildSettingsTile(
                      icon: Icons.pie_chart_outline,
                      title: 'Analytics & Reconciliation',
                      subtitle: 'Monthly analytics & breakdown',
                      iconBgColor: isRetro ? RetroColors.expensePastel : null,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReconciliationScreen()));
                      },
                    ),

                    // Account Statement
                    buildSettingsTile(
                      icon: Icons.summarize_outlined,
                      title: 'Account Statement',
                      subtitle: 'Monthly statements & PDF export',
                      iconBgColor: isRetro ? RetroColors.mint : null,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StatementScreen()));
                      },
                    ),

                    // Backup & Restore
                    buildSettingsTile(
                      icon: Icons.settings_backup_restore,
                      title: 'Backup & Restore',
                      subtitle: 'Export or import local JSON data',
                      iconBgColor: isRetro ? RetroColors.paperBg : null,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
                      },
                    ),

                    // Retro Mode Switch Tile
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isRetro ? RetroColors.cardSurface : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRetro ? RetroColors.ink : AppTheme.primaryBlue.withValues(alpha: 0.05),
                            width: isRetro ? 2.5 : 1.0,
                          ),
                          boxShadow: isRetro
                              ? const [BoxShadow(color: RetroColors.ink, offset: Offset(2, 2), blurRadius: 0)]
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isRetro ? RetroColors.brandGreen : AppTheme.primaryBlue.withValues(alpha: 0.1),
                              shape: isRetro ? BoxShape.rectangle : BoxShape.circle,
                              borderRadius: isRetro ? BorderRadius.circular(10) : null,
                              border: isRetro ? Border.all(color: RetroColors.ink, width: 1.5) : null,
                            ),
                            child: Icon(
                              Icons.palette_outlined,
                              color: isRetro ? RetroColors.ink : AppTheme.primaryBlue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Retro Mode',
                            style: isRetro
                                ? RetroTheme.headingStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                : const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(
                            'Old-school paper & ink look',
                            style: isRetro
                                ? RetroTheme.monoStyle(fontSize: 10)
                                : TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          trailing: RetroSwitch(
                            value: isRetro,
                            onChanged: (val) {
                              provider.setRetroMode(val);
                            },
                          ),
                        ),
                      ),
                    ),

                    // Dark Mode Switch Tile
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isRetro ? RetroColors.cardSurface.withValues(alpha: 0.6) : Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRetro ? RetroColors.ink.withValues(alpha: 0.4) : AppTheme.primaryBlue.withValues(alpha: 0.05),
                          width: isRetro ? 2.0 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        enabled: !isRetro,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.amber : AppTheme.primaryBlue).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isRetro ? Colors.grey : (isDark ? Colors.amber : AppTheme.primaryBlue),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Dark Mode',
                          style: isRetro
                              ? RetroTheme.headingStyle(fontSize: 15, color: Colors.grey)
                              : const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Text(
                          isRetro ? 'Not available in Retro Mode' : (isDark ? 'Dark theme enabled' : 'Light theme enabled'),
                          style: isRetro
                              ? RetroTheme.monoStyle(fontSize: 10, color: Colors.grey)
                              : TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        trailing: Switch(
                          value: isDark && !isRetro,
                          onChanged: isRetro
                              ? null
                              : (val) {
                                  HapticFeedback.selectionClick();
                                  provider.toggleTheme();
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0, locale: 'en_IN');
    final isRetro = context.watch<AppProvider>().isRetroMode;

    if (isRetro) {
      return _buildRetroDashboard(context, currencyFormat);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Baper Teka',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        titleSpacing: 16,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final filteredTxs = provider.transactions.where((tx) => 
            tx.date.month == _selectedMonth.month && 
            tx.date.year == _selectedMonth.year
          ).toList();

          final monthlyWithdrawn = filteredTxs
              .where((tx) => tx.type == TransactionType.cashIn || tx.type == TransactionType.income)
              .fold(0.0, (sum, tx) => sum + tx.amount);

          final monthlySpent = filteredTxs
              .where((tx) => tx.type == TransactionType.expense)
              .fold(0.0, (sum, tx) => sum + tx.amount);

          final balance = monthlyWithdrawn - monthlySpent;

          return RefreshIndicator(
            onRefresh: provider.loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Month Selector
                  Row(
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
                      if (!_isCurrentMonth) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedMonth = DateTime.now());
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Today', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Hero Card (Balance)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003366),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF003366).withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Cash on Hand',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                              child: child,
                            ),
                          ),
                          child: Text(
                            currencyFormat.format(balance),
                            key: ValueKey(balance),
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              color: balance < 0 ? const Color(0xFFFF6B6B) : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Stat Row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat(
                                'Incoming',
                                monthlyWithdrawn,
                                AppTheme.cashInColor,
                                onLongPress: () {
                                  HapticFeedback.heavyImpact();
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCashInScreen()));
                                },
                              ),
                              Container(width: 1, height: 28, color: Colors.grey.withValues(alpha: 0.2)),
                              _buildStat(
                                'Spent',
                                monthlySpent,
                                AppTheme.expenseColor,
                                onLongPress: () {
                                  HapticFeedback.heavyImpact();
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(selectedMonth: _selectedMonth)));
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  
                  // List (Filtered by Month)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTxs.length > 5 ? 5 : filteredTxs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tx = filteredTxs[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 80)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Transform.translate(
                          offset: Offset(0, 15 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        ),
                        child: _buildTransactionTile(tx, currencyFormat, provider),
                      );
                    },
                  ),
                  if (filteredTxs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text('No transactions in ${DateFormat('MMMM yyyy').format(_selectedMonth)}', style: TextStyle(color: Colors.grey[400])),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Retro Mode Dashboard
  Widget _buildRetroDashboard(BuildContext context, NumberFormat currencyFormat) {
    return Scaffold(
      body: RetroBackground(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final filteredTxs = provider.transactions.where((tx) => 
              tx.date.month == _selectedMonth.month && 
              tx.date.year == _selectedMonth.year
            ).toList();

            final monthlyWithdrawn = filteredTxs
                .where((tx) => tx.type == TransactionType.cashIn || tx.type == TransactionType.income)
                .fold(0.0, (sum, tx) => sum + tx.amount);

            final monthlySpent = filteredTxs
                .where((tx) => tx.type == TransactionType.expense)
                .fold(0.0, (sum, tx) => sum + tx.amount);

            final balance = monthlyWithdrawn - monthlySpent;

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: provider.loadData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          // Logo Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: RetroColors.brandGreen,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: RetroColors.ink, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: RetroColors.ink,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              'BAPER TEKA',
                              style: RetroTheme.headingStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: RetroColors.ink,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Retro Settings Button
                          RetroIconButton(
                            icon: Icons.settings_outlined,
                            tooltip: 'Settings',
                            onPressed: () => _showSettingsSheet(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Month Selector
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

                      const SizedBox(height: 20),

                      // Summary Card
                      RetroCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'CASH ON HAND',
                              style: RetroTheme.monoStyle(
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                currencyFormat.format(balance),
                                textAlign: TextAlign.center,
                                style: RetroTheme.headingStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: balance < 0 ? RetroColors.expenseRed : RetroColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                RetroStatTile(
                                  label: 'INCOMING',
                                  value: currencyFormat.format(monthlyWithdrawn),
                                  backgroundColor: RetroColors.cardSurface,
                                  textColor: RetroColors.deepGreen,
                                  onLongPress: () {
                                    HapticFeedback.heavyImpact();
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCashInScreen()));
                                  },
                                ),
                                const SizedBox(width: 12),
                                RetroStatTile(
                                  label: 'SPENT',
                                  value: currencyFormat.format(monthlySpent),
                                  backgroundColor: RetroColors.cardSurface,
                                  textColor: RetroColors.expenseRed,
                                  onLongPress: () {
                                    HapticFeedback.heavyImpact();
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Transactions Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: RetroColors.paperBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: RetroColors.ink, width: 2.0),
                            ),
                            child: Text(
                              'TRANSACTIONS · ${filteredTxs.length}',
                              style: RetroTheme.monoStyle(
                                fontSize: 11,
                                color: RetroColors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: RetroDivider()),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(selectedMonth: _selectedMonth)));
                            },
                            child: Text(
                              'SEE ALL',
                              style: RetroTheme.monoStyle(
                                fontSize: 11,
                                color: RetroColors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // List Items
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTxs.length > 5 ? 5 : filteredTxs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final tx = filteredTxs[index];
                          return _buildRetroTransactionTile(tx, currencyFormat, provider);
                        },
                      ),

                      if (filteredTxs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'NO TRANSACTIONS IN ${DateFormat('MMMM').format(_selectedMonth).toUpperCase()}',
                            style: RetroTheme.monoStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                    DateFormat('dd MMM').format(tx.date).toUpperCase(),
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

  Widget _buildStat(String label, double amount, Color color, {VoidCallback? onLongPress}) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0, locale: 'en_IN');
    return InkWell(
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                currencyFormat.format(amount),
                key: ValueKey(amount),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
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
            const SizedBox(width: 14),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMMM').format(tx.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Text(
              (isExpense ? '-' : '+') + format.format(tx.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
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
