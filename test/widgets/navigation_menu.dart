import 'package:actualia/models/navigation_menu.dart';
import 'package:actualia/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets('Test ActualIA bottom navigation menu',
      (WidgetTester tester) async {
    final List<Destination> destinations = [
      Destination(
          view: Views.NEWS,
          icon: Icons.newspaper,
          onPressed: (Views view) {
            expect(view, Views.NEWS);
          }),
      Destination(
          view: Views.CONTEXT,
          icon: Icons.camera_alt,
          onPressed: (Views view) {}),
      Destination(
          view: Views.FEED,
          icon: Icons.feed,
          onPressed: (Views view) {
            expect(view, Views.FEED);
          })
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: const Center(
          child: Text("test"),
        ),
        bottomNavigationBar: ActualiaBottomNavigationBar(
          destinations: destinations,
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.newspaper));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.feed));
    await tester.pump();
  });
}
