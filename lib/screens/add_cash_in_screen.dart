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
import 'cards_management_screen.dart';

class AddCashInScreen extends StatefulWidget {
  final AppTransaction? editTransaction;
  const AddCashInScreen({super.key, this.editTransaction});

  @override
  State<AddCashInScreen> createState() => _AddCashInScreenState();
}

class _AddCashInScreenState extends State<AddCashInScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _selectedCardId;
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
    _selectedCardId = widget.editTransaction?.cardId;
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

    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a card')));
      return;
    }

    final tx = AppTransaction(
      id: widget.editTransaction?.id ?? const Uuid().v4(),
      type: TransactionType.cashIn,
      amount: amount,
      date: _selectedDate,
      cardId: _selectedCardId,
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
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RetroIconButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            widget.editTransaction != null ? 'EDIT CASH IN' : 'ADD CASH IN',
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

                      RetroTextField(
                        controller: _noteController,
                        label: 'WHAT WAS THIS FOR?',
                      ),

                      const SizedBox(height: 24),

                      Text('SELECT BANK CARD', style: RetroTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      if (provider.cards.isEmpty)
                        RetroCard(
                          child: Column(
                            children: [
                              Text('NO CARDS ADDED YET', style: RetroTheme.monoStyle(fontSize: 12)),
                              const SizedBox(height: 12),
                              RetroButton(
                                label: 'Add Card',
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsManagementScreen())),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.cards.length,
                            itemBuilder: (context, index) {
                              final card = provider.cards[index];
                              final isSelected = _selectedCardId == card.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: RetroChip(
                                  label: card.name,
                                  isSelected: isSelected,
                                  onTap: () => setState(() => _selectedCardId = card.id),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 32),

                      RetroSlideToSave(
                        label: 'SLIDE TO SAVE WITHDRAWAL',
                        onSave: _save,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTransaction != null ? 'Edit Cash In' : 'Add Cash In'),
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
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No cards added yet'),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsManagementScreen()));
                    },
                    child: const Text('Add a Card'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
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
                            textAlign: TextAlign.center,
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
                
                // Card Selector
                const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Select Bank Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.cards.length,
                      itemBuilder: (context, index) {
                        final card = provider.cards[index];
                        final isSelected = _selectedCardId == card.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCardId = card.id);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? card.color : card.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? card.color : card.color.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                card.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : card.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
                        backgroundColor: AppTheme.cashInColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Save Withdrawal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
