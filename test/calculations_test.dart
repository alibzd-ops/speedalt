import 'package:flutter_test/flutter_test.dart';
import 'package:speed_alt/utils/formatters.dart';
import 'package:speed_alt/utils/unit_converter.dart';

void main() {
  group('UnitConverter Tests', () {
    test('Converts m/s to km/h correctly', () {
      expect(UnitConverter.msToKmh(0.0), closeTo(0.0, 0.001));
      expect(UnitConverter.msToKmh(20.0), closeTo(72.0, 0.001));
      expect(UnitConverter.msToKmh(27.7778), closeTo(100.0, 0.01));
      expect(UnitConverter.msToKmh(-5.0), equals(0.0));
    });

    test('Converts m/s to mph correctly', () {
      expect(UnitConverter.msToMph(0.0), closeTo(0.0, 0.001));
      expect(UnitConverter.msToMph(10.0), closeTo(22.369, 0.01));
      expect(UnitConverter.msToMph(26.8224), closeTo(60.0, 0.01));
      expect(UnitConverter.msToMph(-2.0), equals(0.0));
    });

    test('Converts meters to feet and vice versa correctly', () {
      expect(UnitConverter.metersToFeet(0.0), closeTo(0.0, 0.001));
      expect(UnitConverter.metersToFeet(100.0), closeTo(328.084, 0.01));
      expect(UnitConverter.metersToFeet(845.0), closeTo(2772.31, 0.1));

      expect(UnitConverter.feetToMeters(328.084), closeTo(100.0, 0.01));
    });

    test('Converts distance between kilometers and miles correctly', () {
      expect(UnitConverter.kmToMiles(0.0), closeTo(0.0, 0.001));
      expect(UnitConverter.kmToMiles(100.0), closeTo(62.137, 0.01));
      expect(UnitConverter.milesToKm(62.1371), closeTo(100.0, 0.01));

      expect(UnitConverter.metersToKm(28400.0), closeTo(28.4, 0.01));
      expect(UnitConverter.metersToMiles(1609.34), closeTo(1.0, 0.01));
    });

    test('convertSpeed enum method works as expected', () {
      expect(UnitConverter.convertSpeed(20.0, SpeedUnit.kmh), closeTo(72.0, 0.01));
      expect(UnitConverter.convertSpeed(26.8224, SpeedUnit.mph), closeTo(60.0, 0.01));
    });

    test('convertAltitude enum method works as expected', () {
      expect(UnitConverter.convertAltitude(845.0, AltitudeUnit.meters), equals(845.0));
      expect(UnitConverter.convertAltitude(100.0, AltitudeUnit.feet), closeTo(328.084, 0.01));
    });

    test('convertDistance enum method works as expected', () {
      expect(UnitConverter.convertDistance(1500.0, DistanceUnit.kilometers), closeTo(1.5, 0.01));
      expect(UnitConverter.convertDistance(1609.34, DistanceUnit.miles), closeTo(1.0, 0.01));
    });
  });

  group('Formatters Tests', () {
    test('Formats duration as HH:MM:SS', () {
      expect(Formatters.formatDuration(Duration.zero), equals('00:00:00'));
      expect(
        Formatters.formatDuration(const Duration(hours: 0, minutes: 34, seconds: 18)),
        equals('00:34:18'),
      );
      expect(
        Formatters.formatDuration(const Duration(hours: 2, minutes: 5, seconds: 9)),
        equals('02:05:09'),
      );
    });

    test('Formats dashboard speed properly', () {
      expect(Formatters.formatSpeed(0.0), equals('0'));
      expect(Formatters.formatSpeed(-1.0), equals('0'));
      expect(Formatters.formatSpeed(71.8), equals('72'));
      expect(Formatters.formatSpeed(72.2), equals('72'));
    });

    test('Formats statistic speed with 1 decimal', () {
      expect(Formatters.formatStatSpeed(0.0), equals('0'));
      expect(Formatters.formatStatSpeed(61.38), equals('61.4'));
      expect(Formatters.formatStatSpeed(94.0), equals('94.0'));
    });

    test('Formats altitude', () {
      expect(Formatters.formatAltitude(null), equals('--'));
      expect(Formatters.formatAltitude(845.4), equals('845'));
      expect(Formatters.formatAltitude(-12.8), equals('-13'));
    });

    test('Formats distance with 1 decimal', () {
      expect(Formatters.formatDistance(0.0), equals('0.0'));
      expect(Formatters.formatDistance(28.42), equals('28.4'));
      expect(Formatters.formatDistance(100.0), equals('100.0'));
    });

    test('Formats GPS accuracy string', () {
      expect(Formatters.formatAccuracy(null, AltitudeUnit.meters), equals('±--'));
      expect(Formatters.formatAccuracy(5.2, AltitudeUnit.meters), equals('±5 m'));
      expect(Formatters.formatAccuracy(5.0, AltitudeUnit.feet), equals('±16 ft'));
    });

    test('Formats coordinates with correct direction', () {
      expect(Formatters.formatLatitude(41.0082), equals('41.0082° N'));
      expect(Formatters.formatLatitude(-33.8688), equals('33.8688° S'));
      expect(Formatters.formatLatitude(null), equals('--'));

      expect(Formatters.formatLongitude(28.9784), equals('28.9784° E'));
      expect(Formatters.formatLongitude(-74.0060), equals('74.0060° W'));
      expect(Formatters.formatLongitude(null), equals('--'));
    });
  });
}
