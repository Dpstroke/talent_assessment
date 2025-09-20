// This is a basic example of a Flutter integration test.
//
// Since a variety of state management approaches can be used,
// a simple approach is taken in this example using provider.

import 'package:flutter_test/flutter_test.dart';
import 'package:talent_assessment/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TalentAssessmentApp());

    // Verify that the login screen shows up
    expect(find.text('Talent Assessment'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
