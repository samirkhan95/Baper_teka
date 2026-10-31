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

class AddFromFatherScreen extends StatefulWidget {
  final AppTransaction? editTransaction;
  const AddFromFatherScreen({super.key, this.editTransaction});

  @override
  State<AddFromFatherScreen> createState() => _AddFromFatherScreenState();
}

class _AddFromFatherScreenState extends State<AddFromFatherScreen> {
  late TextEditingController _amountController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.editTransaction?.date ?? DateTime.now();
    String initialAmount = widget.editTransaction != null 
        ? widget.editTransaction!.amount.toStringAsFixed(0) 
        : '';
    _amountController = TextEditingController(text: initialAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
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
      type: TransactionType.income,
      amount: amount,
      date: _selectedDate,
      note: 'From Father',
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
                        widget.editTransaction != null ? "EDIT FATHER'S MONEY" : 'FROM FATHER',
                        style: RetroTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                                    color: RetroColors.deepGreen,
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
                                      color: RetroColors.deepGreen,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: RetroTheme.headingStyle(
                                        fontSize: dynamicFontSize,
                                        color: RetroColors.deepGreen.withValues(alpha: 0.3),
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
                            style: RetroTheme.monoStyle(fontSize: 14, color: RetroColors.deepGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'MONEY RECEIVED FROM FATHER',
                    style: RetroTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 32),

                  RetroButton(
                    label: 'Save Received',
                    backgroundColor: RetroColors.brandGreen,
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
        title: Text(widget.editTransaction != null ? 'Edit Father\'s Money' : 'From Father'),
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
                        color: AppTheme.cashInColor.withValues(alpha: _amountController.text.isEmpty ? 0.3 : 1.0),
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
                        style: TextStyle(fontSize: dynamicFontSize, fontWeight: FontWeight.w900, color: AppTheme.cashInColor),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: AppTheme.cashInColor.withValues(alpha: 0.3)),
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
                  color: AppTheme.cashInColor.withValues(alpha: 0.9),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Money received from father',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cashInColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Save Received', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
