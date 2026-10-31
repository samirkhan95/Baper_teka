import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bank_card.dart';
import '../models/app_transaction.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'baper_teka.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        name TEXT,
        color INTEGER,
        last4digits TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type INTEGER,
        amount REAL,
        date TEXT,
        cardId TEXT,
        category INTEGER,
        note TEXT,
        FOREIGN KEY (cardId) REFERENCES cards (id) ON DELETE SET NULL
      )
    ''');
  }

  // Card Operations
  Future<void> insertCard(BankCard card) async {
    final db = await database;
    await db.insert('cards', card.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BankCard>> getCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards');
    return List.generate(maps.length, (i) => BankCard.fromMap(maps[i]));
  }

  Future<void> deleteCard(String id) async {
    final db = await database;
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction Operations
  Future<void> insertTransaction(AppTransaction tx) async {
    final db = await database;
    await db.insert('transactions', tx.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AppTransaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => AppTransaction.fromMap(maps[i]));
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Restore data from lists
  Future<void> restoreBackup(List<BankCard> cards, List<AppTransaction> transactions) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('cards');

      for (var card in cards) {
        await txn.insert('cards', card.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var tx in transactions) {
        await txn.insert('transactions', tx.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
