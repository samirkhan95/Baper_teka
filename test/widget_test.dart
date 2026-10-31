import 'package:flutter_test/flutter_test.dart';
import 'package:baper_teka/main.dart';
import 'package:provider/provider.dart';
import 'package:baper_teka/providers/app_provider.dart';

void main() {
  testWidgets('App starts and shows Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const BaperTekaApp(),
      ),
    );

    expect(find.text('Baper Teka'), findsOneWidget);
    expect(find.text('Cash on Hand'), findsOneWidget);
  });
}
