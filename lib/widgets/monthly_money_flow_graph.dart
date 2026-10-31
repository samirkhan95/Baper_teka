import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/app_transaction.dart';
import '../theme/retro_theme.dart';
import '../utils/transaction_helper.dart';
import '../utils/monthly_flow_calculator.dart';

/// Interactive Monthly Money Flow Graph Component with Density-Aware Adaptive X-Axis,
/// Monotone Curve Interpolation, Dynamic Y-Axis, and Monthly Financial Summary.
class MonthlyMoneyFlowGraph extends StatefulWidget {
  final MonthlyFlowData flowData;
  final bool isRetro;

  const MonthlyMoneyFlowGraph({
    super.key,
    required this.flowData,
    this.isRetro = false,
  });

  @override
  State<MonthlyMoneyFlowGraph> createState() => _MonthlyMoneyFlowGraphState();
}

class _MonthlyMoneyFlowGraphState extends State<MonthlyMoneyFlowGraph> {
  int? _activePointIndex;

  @override
  void didUpdateWidget(covariant MonthlyMoneyFlowGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flowData.month != widget.flowData.month) {
      _activePointIndex = null;
    } else if (_activePointIndex != null &&
        _activePointIndex! >= widget.flowData.points.length) {
      _activePointIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0, locale: 'en_IN');
    final flow = widget.flowData;
    final totalDays = flow.daysInMonth;
    final isRetro = widget.isRetro;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Dynamic Y-axis Bounds strictly for this month:
    final double actualMax = flow.highestBalance;
    final double actualMin = flow.lowestBalance;

    final double rawMinY = (actualMin < 0) ? actualMin : 0.0;
    final double rawMaxY = actualMax > rawMinY ? actualMax : (rawMinY + 1000.0);

    final double range = rawMaxY - rawMinY;
    final double padding = range * 0.12;

    final double maxY = rawMaxY + padding;
    final double minY = rawMinY < 0 ? (rawMinY - padding) : 0.0;

    MonthlyFlowPoint? activePoint;
    if (_activePointIndex != null &&
        _activePointIndex! >= 0 &&
        _activePointIndex! < flow.points.length) {
      activePoint = flow.points[_activePointIndex!];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Monthly Summary Block (Requirement 10)
        _buildMonthlySummaryCard(context, flow, currencyFormat, isRetro, isDark),

        const SizedBox(height: 14),

        // Graph Container with touch-and-hold / drag / tap interaction
        Container(
          height: 250,
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          decoration: BoxDecoration(
            color: isRetro
                ? RetroColors.cardSurface
                : (isDark ? const Color(0xFF1E222D) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRetro
                  ? RetroColors.ink
                  : (isDark ? Colors.white12 : Colors.grey.shade200),
              width: isRetro ? 2.5 : 1,
            ),
            boxShadow: isRetro
                ? const [BoxShadow(color: RetroColors.ink, offset: Offset(4, 4), blurRadius: 0)]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              _updateActivePoint(details.localPosition, totalDays, minY, maxY);
            },
            onPanDown: (details) {
              _updateActivePoint(details.localPosition, totalDays, minY, maxY);
            },
            onPanStart: (details) {
              _updateActivePoint(details.localPosition, totalDays, minY, maxY);
            },
            onPanUpdate: (details) {
              _updateActivePoint(details.localPosition, totalDays, minY, maxY);
            },

            child: CustomPaint(
              painter: _FlowChartPainter(
                points: flow.points,
                totalDays: totalDays,
                minY: minY,
                maxY: maxY,
                isRetro: isRetro,
                isDark: isDark,
                selectedIndex: _activePointIndex,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Detail Card: visible when a point is selected; otherwise shows hint
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: activePoint != null
              ? Column(
                  key: ValueKey('active_${activePoint.transaction?.id ?? _activePointIndex}'),
                  children: [
                    _buildPointDetailCard(context, activePoint, currencyFormat, isRetro),
                    _buildSameDaySelector(flow, activePoint, isRetro),
                  ],
                )
              : _buildHintBar(context, isRetro),
        ),
      ],
    );
  }

  /// Builds Monthly Financial Summary (Requirement 10)
  Widget _buildMonthlySummaryCard(
    BuildContext context,
    MonthlyFlowData flow,
    NumberFormat currencyFormat,
    bool isRetro,
    bool isDark,
  ) {
    final cardBg = isRetro
        ? RetroColors.paperBg
        : (isDark ? const Color(0xFF1E222D) : Colors.grey.shade50);
    final borderColor = isRetro
        ? RetroColors.ink
        : (isDark ? Colors.white12 : Colors.grey.shade200);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isRetro ? 2 : 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  label: 'Opening Balance',
                  amount: currencyFormat.format(flow.openingBalance),
                  color: isRetro ? RetroColors.ink : Colors.blueGrey,
                  isRetro: isRetro,
                  isDark: isDark,
                ),
              ),
              Container(width: 1, height: 32, color: borderColor),
              Expanded(
                child: _buildSummaryTile(
                  label: 'Money Received',
                  amount: '+${currencyFormat.format(flow.totalMoneyIn)}',
                  color: const Color(0xFF22C55E),
                  isRetro: isRetro,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const Divider(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  label: 'Total Expenses',
                  amount: '-${currencyFormat.format(flow.totalExpenses)}',
                  color: const Color(0xFFEF4444),
                  isRetro: isRetro,
                  isDark: isDark,
                ),
              ),
              Container(width: 1, height: 32, color: borderColor),
              Expanded(
                child: _buildSummaryTile(
                  label: 'Closing Balance',
                  amount: currencyFormat.format(flow.monthlyClosingBalance),
                  color: isRetro
                      ? RetroColors.ink
                      : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
                  isBold: true,
                  isRetro: isRetro,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peak: ${MonthlyFlowCalculator.formatCompactTaka(flow.highestBalance)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isRetro ? RetroColors.ink : Colors.grey.shade600,
                ),
              ),
              Text(
                'Lowest: ${MonthlyFlowCalculator.formatCompactTaka(flow.lowestBalance)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isRetro ? RetroColors.ink : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required String label,
    required String amount,
    required Color color,
    required bool isRetro,
    required bool isDark,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isRetro ? RetroColors.ink : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 13 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _updateActivePoint(Offset localPosition, int totalDays, double minY, double maxY) {
    const leftPadding = 52.0;
    const rightPadding = 12.0;
    const topPadding = 16.0;
    const bottomPadding = 26.0;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final chartWidth = box.size.width;
    final plotWidth = chartWidth - leftPadding - rightPadding;
    final plotHeight = 250 - topPadding - bottomPadding;

    if (plotWidth <= 0 || plotHeight <= 0 || widget.flowData.points.isEmpty) return;

    int? closestIndex;
    double minDistance = double.infinity;
    const touchRadius = 40.0;

    final dayOffsets = _FlowChartPainter.computeIntraDayOffsets(widget.flowData.points);

    for (int i = 0; i < widget.flowData.points.length; i++) {
      final pt = widget.flowData.points[i];
      final intraOffset = dayOffsets[i];

      final dayValue = (pt.dateTime.day - 1.0) +
          (pt.dateTime.hour / 24.0) +
          (pt.dateTime.minute / 1440.0) +
          intraOffset;

      final normX = (dayValue / (totalDays - 1).clamp(1, 31)).clamp(0.0, 1.0);
      final px = leftPadding + normX * plotWidth;

      final normY = (pt.balance - minY) / (maxY - minY);
      final py = topPadding + (1.0 - normY) * plotHeight;

      final dist = (Offset(px, py) - localPosition).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    if (minDistance <= touchRadius && closestIndex != null) {
      if (_activePointIndex != closestIndex) {
        HapticFeedback.selectionClick();
        setState(() {
          _activePointIndex = closestIndex;
        });
      }
    } else {
      if (_activePointIndex != null) {
        setState(() {
          _activePointIndex = null;
        });
      }
    }
  }

  Widget _buildHintBar(BuildContext context, bool isRetro) {
    return Container(
      key: const ValueKey('hint'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isRetro ? RetroColors.paperBg : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRetro ? RetroColors.ink : Colors.transparent,
          width: isRetro ? 1.5 : 0,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, size: 16, color: isRetro ? RetroColors.ink : Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tap or drag across points to inspect date, type, amount & balance',
              style: isRetro
                  ? RetroTheme.monoStyle(fontSize: 11)
                  : TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSameDaySelector(MonthlyFlowData flow, MonthlyFlowPoint currentPt, bool isRetro) {
    final sameDayIndices = <int>[];
    for (int i = 0; i < flow.points.length; i++) {
      if (flow.points[i].day == currentPt.day && !flow.points[i].isOpening) {
        sameDayIndices.add(i);
      }
    }

    if (sameDayIndices.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(
            'Day ${currentPt.day} txs (${sameDayIndices.length}): ',
            style: isRetro
                ? RetroTheme.monoStyle(fontSize: 10, fontWeight: FontWeight.bold)
                : TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sameDayIndices.map((idx) {
                  final pt = flow.points[idx];
                  final isSelected = idx == _activePointIndex;
                  final label = pt.isExpense
                      ? '-৳${pt.transaction!.amount.toInt()}'
                      : '+৳${pt.transaction!.amount.toInt()}';

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      selectedColor: pt.isExpense ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                      onSelected: (val) {
                        if (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _activePointIndex = idx);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointDetailCard(
    BuildContext context,
    MonthlyFlowPoint pt,
    NumberFormat currencyFormat,
    bool isRetro,
  ) {
    final dateFormat = DateFormat('d MMMM yyyy');
    final formattedDate = dateFormat.format(pt.dateTime);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (pt.isOpening) {
      return Container(
        key: const ValueKey('pt_opening'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRetro
              ? RetroColors.mint
              : (isDark ? const Color(0xFF262C38) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRetro ? RetroColors.ink : Colors.blueGrey.withValues(alpha: 0.5),
            width: isRetro ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flag_outlined, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opening Balance',
                    style: isRetro
                        ? RetroTheme.headingStyle(fontSize: 14, fontWeight: FontWeight.bold)
                        : const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Starting Balance',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  currencyFormat.format(pt.balance),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final tx = pt.transaction!;
    final isExpense = tx.type == TransactionType.expense;
    final color = isExpense ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    final typeLabel = isExpense
        ? 'Expense'
        : (tx.type == TransactionType.income ? 'From Father' : 'Cash In / Withdrawal');
    final categoryName = TransactionHelper.getCategoryName(tx);
    final amountSign = isExpense ? '-' : '+';

    return Container(
      key: ValueKey('pt_${tx.id}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRetro
            ? (isExpense ? RetroColors.expensePastel : RetroColors.mint)
            : (isDark ? const Color(0xFF262C38) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRetro ? RetroColors.ink : color.withValues(alpha: 0.5),
          width: isRetro ? 2.5 : 1.5,
        ),
        boxShadow: isRetro
            ? const [BoxShadow(color: RetroColors.ink, offset: Offset(3, 3))]
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: isRetro ? Border.all(color: RetroColors.ink, width: 1.5) : null,
                ),
                child: Icon(
                  isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isRetro
                                ? RetroTheme.headingStyle(fontSize: 14, fontWeight: FontWeight.bold)
                                : TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isRetro
                                ? RetroTheme.monoStyle(fontSize: 9)
                                : const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: isRetro
                          ? RetroTheme.monoStyle(fontSize: 10)
                          : TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tx.note != null && tx.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Note: ${tx.note}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isRetro ? RetroColors.ink : Colors.grey.shade700,
                ),
              ),
            ),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isExpense ? 'Expense Amount' : 'Money In Amount',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isRetro ? RetroColors.ink : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$amountSign${currencyFormat.format(tx.amount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining Balance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isRetro ? RetroColors.ink : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      currencyFormat.format(pt.balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isRetro ? RetroColors.ink : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for the smooth Monthly Money Flow Graph.
class _FlowChartPainter extends CustomPainter {
  final List<MonthlyFlowPoint> points;
  final int totalDays;
  final double minY;
  final double maxY;
  final bool isRetro;
  final bool isDark;
  final int? selectedIndex;

  _FlowChartPainter({
    required this.points,
    required this.totalDays,
    required this.minY,
    required this.maxY,
    required this.isRetro,
    required this.isDark,
    this.selectedIndex,
  });

  /// Computes deterministic intra-day fractional offsets [-0.20 .. +0.20]
  /// for multiple transactions occurring on the same calendar day so they never collide.
  static List<double> computeIntraDayOffsets(List<MonthlyFlowPoint> points) {
    final List<double> offsets = List.filled(points.length, 0.0);
    final Map<int, List<int>> dayMap = {};

    for (int i = 0; i < points.length; i++) {
      if (!points[i].isOpening) {
        dayMap.putIfAbsent(points[i].day, () => []).add(i);
      }
    }

    for (final indices in dayMap.values) {
      final count = indices.length;
      if (count > 1) {
        for (int rank = 0; rank < count; rank++) {
          final frac = (rank / (count - 1)) * 0.40 - 0.20;
          offsets[indices[rank]] = frac;
        }
      }
    }

    return offsets;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 52.0;
    const rightPadding = 12.0;
    const topPadding = 16.0;
    const bottomPadding = 26.0;

    final plotWidth = size.width - leftPadding - rightPadding;
    final plotHeight = size.height - topPadding - bottomPadding;

    if (plotWidth <= 0 || plotHeight <= 0) return;

    final dayOffsets = computeIntraDayOffsets(points);

    double xForDayValue(double dayValue) {
      final normX = (dayValue / (totalDays - 1).clamp(1, 31)).clamp(0.0, 1.0);
      return leftPadding + normX * plotWidth;
    }

    double yForBalance(double balance) {
      final normY = (balance - minY) / (maxY - minY);
      return topPadding + (1.0 - normY) * plotHeight;
    }

    // 1. Draw Grid Lines and Y-Axis Labels
    _drawYAxis(canvas, size, leftPadding, rightPadding, topPadding, plotHeight);

    // 2. Draw Adaptive X-Axis Calendar Day Labels (Requirement 3)
    _drawAdaptiveXAxis(canvas, size, leftPadding, plotWidth, topPadding, plotHeight, (day) => xForDayValue(day - 1.0));

    // 3. Connect balance points with Monotone / Shape-preserving smooth curved line (Requirement 7)
    if (points.isNotEmpty) {
      final List<Offset> pixelPoints = [];
      for (int i = 0; i < points.length; i++) {
        final pt = points[i];
        final intraOffset = dayOffsets[i];

        final dayValue = (pt.dateTime.day - 1.0) +
            (pt.dateTime.hour / 24.0) +
            (pt.dateTime.minute / 1440.0) +
            intraOffset;

        pixelPoints.add(Offset(xForDayValue(dayValue), yForBalance(pt.balance)));
      }

      _drawAreaFill(canvas, pixelPoints, leftPadding, plotWidth, topPadding, plotHeight);
      _drawSmoothLine(canvas, pixelPoints);

      // 4. Draw Markers for each point (Requirement 5 & 8)
      for (int i = 0; i < points.length; i++) {
        final pt = points[i];
        final center = pixelPoints[i];
        final isSelected = (i == selectedIndex);

        _drawMarker(canvas, center, pt, isSelected);
      }
    }
  }

  void _drawYAxis(
    Canvas canvas,
    Size size,
    double leftPadding,
    double rightPadding,
    double topPadding,
    double plotHeight,
  ) {
    final gridPaint = Paint()
      ..color = isRetro
          ? RetroColors.ink.withValues(alpha: 0.15)
          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06))
      ..strokeWidth = isRetro ? 1.5 : 1.0;

    final List<double> tickValues = [];
    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      tickValues.add(minY + (maxY - minY) * (i / steps));
    }

    for (final yVal in tickValues) {
      final ratio = (yVal - minY) / (maxY - minY);
      final py = topPadding + (1.0 - ratio) * plotHeight;

      canvas.drawLine(
        Offset(leftPadding, py),
        Offset(size.width - rightPadding, py),
        gridPaint,
      );

      final textSpan = TextSpan(
        text: MonthlyFlowCalculator.formatCompactTaka(yVal),
        style: TextStyle(
          fontSize: 10,
          fontFamily: isRetro ? 'Courier' : null,
          fontWeight: isRetro ? FontWeight.bold : FontWeight.w500,
          color: isRetro
              ? RetroColors.ink
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, py - textPainter.height / 2),
      );
    }
  }

  void _drawAdaptiveXAxis(
    Canvas canvas,
    Size size,
    double leftPadding,
    double plotWidth,
    double topPadding,
    double plotHeight,
    double Function(int) xForDay,
  ) {
    final axisY = topPadding + plotHeight;
    final tickDays = _computeAdaptiveTickDays(plotWidth);

    for (final day in tickDays) {
      final px = xForDay(day);

      final tickPaint = Paint()
        ..color = isRetro ? RetroColors.ink : (isDark ? Colors.white24 : Colors.grey.shade400)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(px, axisY), Offset(px, axisY + 4), tickPaint);

      final textSpan = TextSpan(
        text: '$day',
        style: TextStyle(
          fontSize: 10,
          fontFamily: isRetro ? 'Courier' : null,
          fontWeight: isRetro ? FontWeight.bold : FontWeight.w500,
          color: isRetro
              ? RetroColors.ink
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(px - textPainter.width / 2, axisY + 6),
      );
    }
  }

  List<int> _computeAdaptiveTickDays(double plotWidth) {
    final Set<int> standardSet = {1, 5, 10, 15, 20, 25, totalDays};

    // If screen width is very small, drop 5, 15, 25 to avoid overlap
    if (plotWidth < 280) {
      return [1, 10, 20, totalDays].where((d) => d <= totalDays).toList();
    }

    final list = standardSet.where((d) => d <= totalDays).toList();
    list.sort();
    return list;
  }

  void _drawSmoothLine(Canvas canvas, List<Offset> points) {
    if (points.isEmpty) return;
    if (points.length == 1) return;

    final path = _computeSmoothPath(points);

    final linePaint = Paint()
      ..color = isRetro
          ? RetroColors.ink
          : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
      ..strokeWidth = isRetro ? 3.0 : 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  void _drawAreaFill(
    Canvas canvas,
    List<Offset> points,
    double leftPadding,
    double plotWidth,
    double topPadding,
    double plotHeight,
  ) {
    if (points.isEmpty || isRetro) return;

    final baselineY = topPadding + plotHeight;
    final path = _computeSmoothPath(points);

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, baselineY)
      ..lineTo(points.first.dx, baselineY)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)).withValues(alpha: 0.22),
          (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight));

    canvas.drawPath(fillPath, fillPaint);
  }

  Path _computeSmoothPath(List<Offset> pts) {
    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);

    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return path;
    }

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;

      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      // Monotone interpolation constraint
      final minY = math.min(p1.dy, p2.dy);
      final maxY = math.max(p1.dy, p2.dy);
      final clampedCp1y = cp1y.clamp(minY, maxY);
      final clampedCp2y = cp2y.clamp(minY, maxY);

      path.cubicTo(cp1x, clampedCp1y, cp2x, clampedCp2y, p2.dx, p2.dy);
    }

    return path;
  }

  void _drawMarker(Canvas canvas, Offset center, MonthlyFlowPoint pt, bool isSelected) {
    Color markerColor;
    if (pt.isOpening) {
      markerColor = isRetro ? RetroColors.ink : Colors.blueGrey;
    } else if (pt.isIncoming) {
      markerColor = const Color(0xFF22C55E); // Green
    } else {
      markerColor = const Color(0xFFEF4444); // Red
    }

    final double radius = isSelected ? 6.5 : (pt.isOpening ? 4.0 : 5.0);

    if (isSelected) {
      final glowPaint = Paint()
        ..color = markerColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + 5, glowPaint);
    }

    final borderPaint = Paint()
      ..color = isRetro ? RetroColors.ink : Colors.white
      ..strokeWidth = isRetro ? 2.0 : 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = markerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _FlowChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY ||
        oldDelegate.isRetro != isRetro ||
        oldDelegate.isDark != isDark;
  }
}
