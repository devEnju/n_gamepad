import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:n_gamepad_example/main.dart';

void main() {
  testWidgets('Verify Platform', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data!.startsWith('Last'),
      ),
      findsOneWidget,
    );
  });
}
