import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_shikhi/main.dart';

void main() {
  testWidgets('Chinese Shikhi app starts successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ChineseShikhiApp());

    expect(find.byType(ChineseShikhiApp), findsOneWidget);
  });
}
