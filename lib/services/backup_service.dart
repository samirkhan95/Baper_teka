import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/bank_card.dart';
import '../models/app_transaction.dart';

class BackupService {
  static final DBHelper _dbHelper = DBHelper();

  /// Export local backup JSON file
  static Future<String?> exportBackup() async {
    final cards = await _dbHelper.getCards();
    final transactions = await _dbHelper.getTransactions();

    final backupData = {
      'app': 'Baper Teka',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'cards': cards.map((c) => c.toMap()).toList(),
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    final fileName = 'BaperTeka_Backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
    final bytes = utf8.encode(jsonString);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Backup File',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (outputFile != null) {
      final file = File(outputFile);
      if (!await file.exists() || (await file.length()) == 0) {
        await file.writeAsBytes(bytes);
      }
      return outputFile;
    }

    return null;
  }

  /// Import backup JSON file
  static Future<Map<String, dynamic>?> importBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Baper Teka Backup File',
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final platformFile = result.files.single;
    String jsonString;

    if (platformFile.bytes != null) {
      jsonString = utf8.decode(platformFile.bytes!);
    } else if (platformFile.path != null) {
      final file = File(platformFile.path!);
      jsonString = await file.readAsString();
    } else {
      throw Exception('Could not read selected file');
    }

    final Map<String, dynamic> data = jsonDecode(jsonString);

    if (!data.containsKey('cards') || !data.containsKey('transactions')) {
      throw Exception('Invalid backup file format');
    }

    final List<BankCard> cards = (data['cards'] as List)
        .map((c) => BankCard.fromMap(Map<String, dynamic>.from(c)))
        .toList();

    final List<AppTransaction> transactions = (data['transactions'] as List)
        .map((t) => AppTransaction.fromMap(Map<String, dynamic>.from(t)))
        .toList();

    return {
      'cards': cards,
      'transactions': transactions,
      'exportedAt': data['exportedAt'],
    };
  }
}
