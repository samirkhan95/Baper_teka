import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/bank_card.dart';
import '../providers/app_provider.dart';
import '../theme/retro_theme.dart';
import '../theme/retro_widgets.dart';

class CardsManagementScreen extends StatelessWidget {
  const CardsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRetro = context.watch<AppProvider>().isRetroMode;

    if (isRetro) {
      return _buildRetroCardsScreen(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Cards')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No cards added yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Add your bank cards to track withdrawals', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.cards.length,
            itemBuilder: (context, index) {
              final card = provider.cards[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [card.color, card.color.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: card.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.credit_card, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              card.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final confirm = await _showDeleteConfirmation(context, card.name);
                            if (confirm == true) {
                              provider.deleteCard(card.id);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card.last4digits != null && card.last4digits!.isNotEmpty
                              ? '•••• •••• •••• ${card.last4digits}'
                              : '•••• •••• •••• ••••',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const Icon(Icons.contactless, color: Colors.white70, size: 24),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAddCardDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }

  Widget _buildRetroCardsScreen(BuildContext context) {
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
                      'MY CARDS',
                      style: RetroTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    RetroIconButton(
                      icon: Icons.add,
                      onPressed: () => _showAddCardDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    if (provider.cards.isEmpty) {
                      return Center(
                        child: Text(
                          'NO CARDS ADDED YET',
                          style: RetroTheme.monoStyle(fontSize: 12),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.cards.length,
                      itemBuilder: (context, index) {
                        final card = provider.cards[index];
                        return RetroCard(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: card.color,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.credit_card, color: Colors.white, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        card.name.toUpperCase(),
                                        style: RetroTheme.headingStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                                    onPressed: () async {
                                      HapticFeedback.mediumImpact();
                                      final confirm = await _showDeleteConfirmation(context, card.name);
                                      if (confirm == true) {
                                        provider.deleteCard(card.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    card.last4digits != null && card.last4digits!.isNotEmpty
                                        ? '•••• •••• •••• ${card.last4digits}'
                                        : '•••• •••• •••• ••••',
                                    style: RetroTheme.monoStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const Icon(Icons.contactless, color: Colors.white, size: 24),
                                ],
                              ),
                            ],
                          ),
                        );
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

  Future<bool?> _showDeleteConfirmation(BuildContext context, String cardName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete "$cardName"?'),
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
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final nameController = TextEditingController();
    final last4Controller = TextEditingController();
    Color selectedColor = Colors.indigo;

    final presetColors = [
      Colors.indigo,
      const Color(0xFF003366),
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
      Colors.pink,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Add Bank Card'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Name',
                        hintText: 'e.g. City Bank, Dutch-Bangla',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: last4Controller,
                      decoration: const InputDecoration(
                        labelText: 'Last 4 Digits (Optional)',
                        hintText: '1234',
                        counterText: "",
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 20),
                    const Text('Card Theme Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: presetColors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setDialogState(() => selectedColor = color);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (nameController.text.trim().isEmpty) return;
                    final card = BankCard(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      color: selectedColor,
                      last4digits: last4Controller.text.trim().isNotEmpty ? last4Controller.text.trim() : null,
                    );
                    context.read<AppProvider>().addCard(card);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Card'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
