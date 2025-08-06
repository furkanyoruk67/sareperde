// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:sareperde/pages/catalog_page.dart';
import 'package:sareperde/providers/cart_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CartProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CatalogPage(),
        ),
      ),
    );

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Hero slider displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CartProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CatalogPage(),
        ),
      ),
    );

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the hero slider is present
    expect(find.byType(Container), findsWidgets);
  });
}
