import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/app_transaction.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/retro_theme.dart';
import '../theme/retro_widgets.dart';

class AddExpenseScreen extends StatefulWidget {
  final AppTransaction? editTransaction;
  const AddExpenseScreen({super.key, this.editTransaction});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.editTransaction?.date ?? DateTime.now();
    String initialAmount = widget.editTransaction != null 
        ? widget.editTransaction!.amount.toStringAsFixed(0) 
        : '';
    _amountController = TextEditingController(text: initialAmount);
    _noteController = TextEditingController(text: widget.editTransaction?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double _calculateTotalAmount(String text) {
    if (text.trim().isEmpty) return 0.0;
    final cleanText = text.replaceAll('+', ',');
    final parts = cleanText.split(',');
    double sum = 0.0;
    for (var part in parts) {
      final parsed = double.tryParse(part.trim());
      if (parsed != null && parsed > 0) {
        sum += parsed;
      }
    }
    return sum;
  }

  Future<void> _save() async {
    final double amount = _calculateTotalAmount(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    final tx = AppTransaction(
      id: widget.editTransaction?.id ?? const Uuid().v4(),
      type: TransactionType.expense,
      amount: amount,
      date: _selectedDate,
      category: null,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    HapticFeedback.mediumImpact();
    await context.read<AppProvider>().addTransaction(tx);
    if (mounted) Navigator.pop(context);
  }

  double _getFontSize(String text) {
    final len = text.length;
    if (len <= 4) return 56.0;
    if (len <= 8) return 42.0;
    if (len <= 12) return 32.0;
    if (len <= 16) return 26.0;
    return 20.0;
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotalAmount(_amountController.text);
    final hasMultipleAmounts = _amountController.text.contains(',') || _amountController.text.contains('+');
    final dynamicFontSize = _getFontSize(_amountController.text);
    final isRetro = context.watch<AppProvider>().isRetroMode;

    if (isRetro) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: RetroBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      RetroIconButton(
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.editTransaction != null ? 'EDIT EXPENSE' : 'ADD EXPENSE',
                        style: RetroTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      RetroChip(
                        label: DateFormat('dd MMM').format(_selectedDate),
                        isSelected: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  RetroCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '৳',
                                  style: RetroTheme.headingStyle(
                                    fontSize: dynamicFontSize,
                                    fontWeight: FontWeight.w900,
                                    color: RetroColors.expenseRed,
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: TextField(
                                    controller: _amountController,
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[\d,.+]')),
                                    ],
                                    style: RetroTheme.headingStyle(
                                      fontSize: dynamicFontSize,
                                      fontWeight: FontWeight.w900,
                                      color: RetroColors.expenseRed,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: RetroTheme.headingStyle(
                                        fontSize: dynamicFontSize,
                                        color: RetroColors.expenseRed.withValues(alpha: 0.3),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (val) => setState(() {}),
                                    onSubmitted: (_) => _save(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (hasMultipleAmounts) ...[
                          const SizedBox(height: 8),
                          Text(
                            'TOTAL: ৳${NumberFormat('#,##0.00', 'en_IN').format(totalAmount)}',
                            style: RetroTheme.monoStyle(fontSize: 14, color: RetroColors.expenseRed, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  RetroTextField(
                    controller: _noteController,
                    label: 'WHAT WAS THIS FOR?',
                  ),

                  const SizedBox(height: 32),

                  RetroButton(
                    label: 'Save Expense',
                    backgroundColor: RetroColors.expenseRed,
                    textColor: Colors.white,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTransaction != null ? 'Edit Expense' : 'Add Expense'),
        actions: [
          TextButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                HapticFeedback.lightImpact();
                setState(() => _selectedDate = picked);
              }
            },
            child: Text(
              DateFormat('dd MMM').format(_selectedDate),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Amount Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '৳',
                      style: TextStyle(
                        fontSize: dynamicFontSize,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.expenseColor.withValues(alpha: _amountController.text.isEmpty ? 0.3 : 1.0),
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d,.+]')),
                        ],
                        style: TextStyle(fontSize: dynamicFontSize, fontWeight: FontWeight.w900, color: AppTheme.expenseColor),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: AppTheme.expenseColor.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onChanged: (val) => setState(() {}),
                        onSubmitted: (_) => _save(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasMultipleAmounts) ...[
              const SizedBox(height: 8),
              Text(
                'Total: ৳${NumberFormat('#,##0.00', 'en_IN').format(totalAmount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.expenseColor.withValues(alpha: 0.9),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Note field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E232A)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF323842)
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _noteController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What was this for?',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Save Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.expenseColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Save Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
