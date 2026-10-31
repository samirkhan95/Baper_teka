import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const BaperTekaApp(),
    ),
  );
}

class BaperTekaApp extends StatelessWidget {
  const BaperTekaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        ThemeData theme;
        if (provider.isRetroMode) {
          theme = AppTheme.retroTheme;
        } else if (provider.isDarkMode) {
          theme = AppTheme.darkTheme;
        } else {
          theme = AppTheme.lightTheme;
        }

        return AnimatedTheme(
          data: theme,
          duration: const Duration(milliseconds: 250),
          child: MaterialApp(
            title: 'Baper Teka',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const DashboardScreen(),
          ),
        );
      },
    );
  }
}
