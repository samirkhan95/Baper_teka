enum TransactionType { cashIn, expense, income }

enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.food: return 'Food';
      case ExpenseCategory.transport: return 'Transport';
      case ExpenseCategory.shopping: return 'Shopping';
      case ExpenseCategory.bills: return 'Bills';
      case ExpenseCategory.other: return 'Other';
    }
  }
}

class AppTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? cardId; // Only for cashIn
  final ExpenseCategory? category; // Only for expense
  final String? note;

  AppTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.cardId,
    this.category,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'date': date.toIso8601String(),
      'cardId': cardId,
      'category': category?.index,
      'note': note,
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    return AppTransaction(
      id: map['id'],
      type: TransactionType.values[map['type']],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      cardId: map['cardId'],
      category: map['category'] != null ? ExpenseCategory.values[map['category']] : null,
      note: map['note'],
    );
  }
}
