import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:lingua/main.dart';

void main() {
  testWidgets('Lingua auth screen renders', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const LinguaApp());

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });
}
