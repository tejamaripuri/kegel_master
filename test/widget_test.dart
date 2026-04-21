import 'package:flutter_test/flutter_test.dart';

import 'package:kegel_master/main.dart';

void main() {
  testWidgets('App shows Kegel Master title', (WidgetTester tester) async {
    await tester.pumpWidget(const KegelMasterApp());

    expect(find.text('Kegel Master'), findsOneWidget);
  });
}
