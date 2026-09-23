import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_alt/utils/unit_converter.dart';
import 'package:speed_alt/widgets/altitude_display.dart';
import 'package:speed_alt/widgets/speed_display.dart';
import 'package:speed_alt/widgets/stat_card.dart';

void main() {
  testWidgets('SpeedDisplay renders large speed number and unit', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpeedDisplay(
            currentSpeedMs: 20.0, // 72 km/h
            unit: SpeedUnit.kmh,
            isTracking: true,
          ),
        ),
      ),
    );

    expect(find.text('72'), findsOneWidget);
    expect(find.text('km/h'), findsOneWidget);
  });

  testWidgets('AltitudeDisplay renders altitude and unit', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AltitudeDisplay(
            altitudeMeters: 845.0,
            accuracyMeters: 4.0,
            unit: AltitudeUnit.meters,
          ),
        ),
      ),
    );

    expect(find.text('Altitude'), findsOneWidget);
    expect(find.text('845'), findsOneWidget);
    expect(find.text('m'), findsOneWidget);
  });

  testWidgets('StatCard renders label, value and unit', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCard(
            label: 'Maximum Speed',
            value: '94',
            unit: 'km/h',
            icon: Icons.trending_up,
          ),
        ),
      ),
    );

    expect(find.text('Maximum Speed'), findsOneWidget);
    expect(find.text('94'), findsOneWidget);
    expect(find.text('km/h'), findsOneWidget);
  });
}
