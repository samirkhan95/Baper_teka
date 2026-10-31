import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/app_transaction.dart';
import '../models/bank_card.dart';

class PdfService {
  static Future<void> generateAndShareStatement({
    required DateTimeRange dateRange,
    required List<AppTransaction> transactions,
    required List<BankCard> cards,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'TK ', decimalDigits: 0);
    
    final totalIn = transactions
        .where((tx) => tx.type == TransactionType.cashIn || tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    
    final totalOut = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Baper Teka', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('Account Statement', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Period', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.Text(
                      '${DateFormat('dd MMM yyyy').format(dateRange.start)} - ${DateFormat('dd MMM yyyy').format(dateRange.end)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('TOTAL INCOMING', currencyFormat.format(totalIn), PdfColors.white),
                  pw.Container(width: 1, height: 30, color: PdfColors.white.withAlpha(50)),
                  _buildSummaryItem('TOTAL OUTGOING', currencyFormat.format(totalOut), PdfColors.white),
                  pw.Container(width: 1, height: 30, color: PdfColors.white.withAlpha(50)),
                  _buildSummaryItem('NET BALANCE', currencyFormat.format(totalIn - totalOut), PdfColors.white),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Table Header
            pw.Text('TRANSACTION DETAILS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            pw.SizedBox(height: 12),

            // Transactions Table
            pw.Table(
              border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Description', isHeader: true),
                    _buildTableCell('Type', isHeader: true),
                    _buildTableCell('Amount', isHeader: true, align: pw.Alignment.centerRight),
                  ],
                ),
                // Data Rows
                ...transactions.map((tx) {
                  final isExpense = tx.type == TransactionType.expense;
                  final isIncome = tx.type == TransactionType.income;
                  
                  String desc = (tx.note != null && tx.note!.trim().isNotEmpty)
                      ? tx.note!.trim()
                      : (isExpense ? 'Expense' : (isIncome ? 'From Father' : 'ATM Withdrawal'));
                  
                  // Capitalize first letter
                  if (desc.isNotEmpty) {
                    desc = desc[0].toUpperCase() + desc.substring(1);
                  }

                  if (tx.type == TransactionType.cashIn && tx.cardId != null) {
                    final card = cards.any((c) => c.id == tx.cardId) ? cards.firstWhere((c) => c.id == tx.cardId) : null;
                    if (card != null) desc += ' (via ${card.name})';
                  }

                  return pw.TableRow(
                    children: [
                      _buildTableCell(DateFormat('dd/MM/yy').format(tx.date)),
                      _buildTableCell(desc),
                      _buildTableCell(tx.type.name.toUpperCase()),
                      _buildTableCell(
                        (isExpense ? '- ' : '+ ') + currencyFormat.format(tx.amount),
                        color: isExpense ? PdfColors.red900 : PdfColors.green900,
                        align: pw.Alignment.centerRight,
                      ),
                    ],
                  );
                }),
              ],
            ),
            
            pw.SizedBox(height: 40),
            pw.Divider(color: PdfColors.grey300),
            pw.Center(
              child: pw.Text('Generated by Baper Teka App', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ),
          ];
        },
      ),
    );

    // Share or Print
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'BaperTeka_Statement.pdf');
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(color: color.withAlpha(150), fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(color: color, fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.Alignment align = pw.Alignment.centerLeft, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 9,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? (isHeader ? PdfColors.black : PdfColors.grey800),
          ),
        ),
      ),
    );
  }
}
