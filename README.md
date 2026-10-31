# 💰 Baper Teka (baper_teka)

[![Flutter](https://img.shields.io/badge/Flutter-3.11.5-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-5.0+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Provider%20%2B%20SQLite-ff69b4?style=for-the-badge)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Portfolio%20%26%20Showcase-purple?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge)](#)

> **Baper Teka** is a premium personal finance tracking and bank card reconciliation application built for Android with Flutter. Featuring a dual theme system (Modern Minimalist & Nostalgic 8-Bit Retro), interactive Monthly Money Flow Analytics, local SQLite persistence, PDF statement generation, and full offline data backup/restore capabilities.

---

## 📥 Download Release APK

Get the pre-built, production-ready Android APK directly from GitHub Releases or the repository root:

- **[Direct Release APK Download (v1.0.0)](https://github.com/samirkhan95/Baper_teka/releases/latest)**
- **[Local Repository APK](./app-release.apk)**

---

## ✨ Key Features

- 📊 **Interactive Monthly Money Flow Graph**:
  - **100% Monthly Isolation**: Independent monthly timelines carrying forward true opening balances without cross-month clutter.
  - **Density-Aware X-Axis**: Displays calendar days (1, 5, 10, 15, 20, 25, 30/31) with smart adaptive spacing for mobile screens.
  - **Dynamic Y-Axis & Monotone Curve**: Auto-scales cumulative cash-on-hand balance (৳) using shape-preserving cubic curve interpolation.
  - **Interactive Touch & Intra-Day Selector**: Tap or drag across transaction markers (Green for Money In, Red for Expenses) with same-day multi-transaction choice chips.
  - **Monthly Financial Summary**: Instant view of Opening Balance, Money Received, Total Expenses, Closing Balance, and Peak/Lowest values.
- 💳 **Bank Card & Withdrawal Management**:
  - Track multiple debit/credit/ATM cards with custom color styling and withdrawal quotas.
  - Categorized expense allocation with real-time spending percentage progress indicators.
- 🎨 **Dual-Engine Aesthetic**:
  - **Modern Theme**: Sleek Light & Dark modes with subtle shadows and clean typography.
  - **Retro Theme**: Nostalgic 8-Bit Cyber-Retro UI complete with custom retro cards, retro buttons, and custom pixel-perfect typography.
- 📄 **PDF Statement Export**:
  - Generate formatted monthly financial statements in PDF format with automated total computations.
- 💾 **Data Privacy & Backup**:
  - 100% offline local SQLite database (`sqflite`).
  - Full backup & restore via JSON export/import.

---

## 🏗️ Architecture & Project Structure

```
lib/
├── database/
│   └── db_helper.dart            # SQLite database manager & migration engine
├── models/
│   ├── app_transaction.dart      # Transaction entity model (CashIn, Expense, Income)
│   └── bank_card.dart            # Bank card entity model
├── providers/
│   └── app_provider.dart         # Global state management using Provider pattern
├── screens/
│   ├── dashboard_screen.dart     # Main dashboard with cards, balance & quick actions
│   ├── reconciliation_screen.dart# Monthly analytics & interactive graph screen
│   ├── history_screen.dart       # Searchable & filterable transaction history
│   ├── add_cash_in_screen.dart   # Record card withdrawal / cash-in transaction
│   ├── add_expense_screen.dart  # Record daily expense with category picker
│   ├── add_from_father_screen.dart # Record income / direct allowance
│   ├── cards_management_screen.dart # Manage bank cards
│   ├── statement_screen.dart     # Monthly PDF statement preview & export
│   └── backup_screen.dart        # JSON backup and restore operations
├── services/
│   ├── backup_service.dart       # JSON backup serialization & file picker
│   └── pdf_service.dart          # PDF document layout and generation engine
├── theme/
│   ├── app_theme.dart            # Modern Light & Dark Material ThemeData
│   ├── retro_theme.dart          # Retro theme colors & typography
│   └── retro_widgets.dart        # Reusable 8-bit retro styled UI components
├── utils/
│   ├── monthly_flow_calculator.dart # Isolated monthly money flow calculation engine
│   └── transaction_helper.dart  # Category icons, labels & formatting utilities
└── widgets/
    └── monthly_money_flow_graph.dart # Interactive CustomPainter money flow chart widget
```

---

## 💻 Code Highlights

### 1. Shape-Preserving Monotone Curve Interpolation
```dart
// Custom smooth curve fitting without artificial overshooting
Path computeSmoothPath(List<Offset> pts) {
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (int i = 0; i < pts.length - 1; i++) {
    final p0 = i > 0 ? pts[i - 1] : pts[i];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

    final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
    final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
    final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
    final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

    final minY = math.min(p1.dy, p2.dy);
    final maxY = math.max(p1.dy, p2.dy);
    path.cubicTo(cp1x, cp1y.clamp(minY, maxY), cp2x, cp2y.clamp(minY, maxY), p2.dx, p2.dy);
  }
  return path;
}
```

### 2. Isolated Monthly Financial Calculator
```dart
final flowData = MonthlyFlowCalculator.computeMonthlyFlow(
  allTransactions: provider.transactions,
  selectedMonth: _selectedMonth,
);
```

---

## 🛠️ Build & Setup Instructions

### Prerequisites
- Flutter SDK `^3.11.5`
- Dart SDK `^3.0.0`
- Android SDK 21+

### Installation
```bash
# Clone repository
git clone https://github.com/samirkhan95/Baper_teka.git
cd Baper_teka

# Install dependencies
flutter pub get

# Run application
flutter run

# Run unit & widget tests
flutter test

# Build release APK
flutter build apk --release
```

---

## 👨‍💻 Author

**Samir Khan**
- **GitHub**: [@samirkhan95](https://github.com/samirkhan95)
- **Role**: Software Engineer / Android & Mobile Developer

---

## 📜 License

This project is licensed under the **Portfolio & Showcase License** - see the [LICENSE](LICENSE) file for details.
