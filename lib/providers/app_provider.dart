import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../models/bank_card.dart';
import '../models/app_transaction.dart';

class AppProvider with ChangeNotifier {
  List<BankCard> _cards = [];
  List<AppTransaction> _transactions = [];
  ThemeMode _themeMode = ThemeMode.light;
  bool _isRetroMode = false;
  bool _isDarkMode = false;
  final DBHelper _dbHelper = DBHelper();

  List<BankCard> get cards => _cards;
  List<AppTransaction> get transactions => _transactions;
  ThemeMode get themeMode => _themeMode;
  bool get isRetroMode => _isRetroMode;
  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isRetroMode = prefs.getBool('retro_mode_enabled') ?? false;
    _isDarkMode = prefs.getBool('theme_mode_dark') ?? false;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await loadData();
  }

  Future<void> setRetroMode(bool value) async {
    _isRetroMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('retro_mode_enabled', value);
    notifyListeners();
  }

  Future<void> toggleRetroMode() async {
    await setRetroMode(!_isRetroMode);
  }

  Future<void> toggleTheme() async {
    if (_isRetroMode) return; // Overridden when in Retro Mode
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_mode_dark', _isDarkMode);
    notifyListeners();
  }

  double get totalWithdrawn {
    return _transactions
        .where((tx) => tx.type == TransactionType.cashIn || tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalSpent {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get cashOnHand => totalWithdrawn - totalSpent;

  Future<void> loadData() async {
    _cards = await _dbHelper.getCards();
    _transactions = await _dbHelper.getTransactions();
    notifyListeners();
  }

  Future<void> addCard(BankCard card) async {
    await _dbHelper.insertCard(card);
    await loadData();
  }

  Future<void> deleteCard(String id) async {
    await _dbHelper.deleteCard(id);
    await loadData();
  }

  Future<void> addTransaction(AppTransaction tx) async {
    await _dbHelper.insertTransaction(tx);
    await loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await _dbHelper.deleteTransaction(id);
    await loadData();
  }

  Future<void> restoreData(List<BankCard> cards, List<AppTransaction> transactions) async {
    await _dbHelper.restoreBackup(cards, transactions);
    await loadData();
  }

  // Monthly stats
  double getMonthlyWithdrawn(DateTime month) {
    return _transactions
        .where((tx) => (tx.type == TransactionType.cashIn || tx.type == TransactionType.income) && tx.date.month == month.month && tx.date.year == month.year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getMonthlySpent(DateTime month) {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense && tx.date.month == month.month && tx.date.year == month.year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
}
