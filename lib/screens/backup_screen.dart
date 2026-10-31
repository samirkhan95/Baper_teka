import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../services/backup_service.dart';
import '../models/bank_card.dart';
import '../models/app_transaction.dart';
import '../theme/app_theme.dart';
import '../theme/retro_theme.dart';
import '../theme/retro_widgets.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;

  Future<void> _handleExport() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final savedPath = await BackupService.exportBackup();
      if (!mounted) return;
      
      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved successfully!\nLocation: $savedPath'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export backup: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestore() async {
    HapticFeedback.lightImpact();

    try {
      final backupData = await BackupService.importBackup();
      if (backupData == null || !mounted) return;

      final List<BankCard> cards = backupData['cards'];
      final List<AppTransaction> transactions = backupData['transactions'];
      final String? exportedAtStr = backupData['exportedAt'];

      DateTime? exportedAt;
      if (exportedAtStr != null) {
        exportedAt = DateTime.tryParse(exportedAtStr);
      }

      final confirmed = await _showRestoreConfirmation(
        cardsCount: cards.length,
        txCount: transactions.length,
        exportedAt: exportedAt,
      );

      if (confirmed == true && mounted) {
        setState(() => _isLoading = true);
        await context.read<AppProvider>().restoreData(cards, transactions);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data restored successfully (${transactions.length} transactions, ${cards.length} cards)!'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore backup: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showRestoreConfirmation({
    required int cardsCount,
    required int txCount,
    DateTime? exportedAt,
  }) {
    final dateStr = exportedAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(exportedAt) : 'Unknown date';

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restoring will replace all current app data with the selected backup file.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text('• Backup Date: $dateStr'),
            Text('• Transactions: $txCount'),
            Text('• Bank Cards: $cardsCount'),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to proceed?',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Restore & Overwrite'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRetro = context.watch<AppProvider>().isRetroMode;

    if (isRetro) {
      return _buildRetroBackupScreen(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.shield_outlined, size: 48, color: AppTheme.primaryBlue),
                        const SizedBox(height: 12),
                        const Text(
                          '100% Offline Local Backup',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Keep your financial data safe on your device storage without any cloud or internet connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Export Option
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0x1F2196F3),
                              child: Icon(Icons.upload_file_rounded, color: Colors.blue),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Export Backup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  Text('Save a JSON backup file to phone storage', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Save your cards and transactions to your Downloads or Documents folder before uninstalling or changing phones.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleExport,
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Export Backup File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Restore Option
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0x1F4CAF50),
                              child: Icon(Icons.restore_page_rounded, color: Colors.green),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Restore Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  Text('Import transactions & cards from a backup file', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a previously saved backup file (.json) to restore your data after reinstalling the app.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _handleRestore,
                            icon: const Icon(Icons.folder_open_rounded),
                            label: const Text('Select Backup & Restore'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.green[700]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRetroBackupScreen(BuildContext context) {
    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Column(
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
                      'BACKUP & RESTORE',
                      style: RetroTheme.headingStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: RetroColors.ink))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Banner
                            RetroCard(
                              color: RetroColors.mint,
                              child: Column(
                                children: [
                                  const Icon(Icons.shield_outlined, size: 48, color: RetroColors.ink),
                                  const SizedBox(height: 12),
                                  Text(
                                    '100% OFFLINE BACKUP',
                                    style: RetroTheme.headingStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Keep your financial data safe on your device storage without any cloud or internet connection.',
                                    textAlign: TextAlign.center,
                                    style: RetroTheme.monoStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Export Retro Card
                            RetroCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('EXPORT BACKUP', style: RetroTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Save your cards and transactions to a JSON file in your Downloads folder.',
                                    style: RetroTheme.monoStyle(fontSize: 11),
                                  ),
                                  const SizedBox(height: 16),
                                  RetroButton(
                                    label: 'Export Backup File',
                                    onPressed: _handleExport,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Restore Retro Card
                            RetroCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('RESTORE DATA', style: RetroTheme.headingStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Select a previously saved backup file (.json) to restore your data.',
                                    style: RetroTheme.monoStyle(fontSize: 11),
                                  ),
                                  const SizedBox(height: 16),
                                  RetroButton(
                                    label: 'Select Backup & Restore',
                                    backgroundColor: RetroColors.cardSurface,
                                    onPressed: _handleRestore,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
