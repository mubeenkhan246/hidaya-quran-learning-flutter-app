// Hidayah App Widget Tests
//
// Tests for the Hidayah Quran Learning Application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:i_app/main.dart';

void main() {
  testWidgets('App smoke test - Hidayah launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HidayahApp());
    await tester.pump();

    // Verify that the app name appears in the splash screen
    expect(find.text('Hidayah'), findsOneWidget);
    
    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
