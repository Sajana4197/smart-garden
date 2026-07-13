import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_garden_ai/features/weather/domain/entities/current_weather.dart';
import 'package:smart_garden_ai/features/weather/presentation/widgets/animated_weather_icon.dart';

void main() {
  for (final condition in WeatherCondition.values) {
    testWidgets('renders and animates without throwing for $condition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedWeatherIcon(condition: condition),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disposes cleanly when removed mid-animation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnimatedWeatherIcon(condition: WeatherCondition.rain)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
