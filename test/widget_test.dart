import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heads_up/main.dart';
import 'package:heads_up/features/onboarding/screens/onboarding_screen.dart';
import 'package:heads_up/features/taps/models/tap_event.dart';
import 'package:heads_up/core/utils/formatters.dart';
import 'package:heads_up/core/services/sensor_service.dart';

void main() {
  group('Heads Up Widget & App Smoke Tests', () {
    testWidgets('App root boots and renders onboarding initial frame', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: HeadsUpApp(),
        ),
      );

      // Initial frame loads Onboarding screen
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Precision Geospatial Tagging'), findsOneWidget);
    });
  });

  group('TapEvent Model & Geohashing Unit Tests', () {
    test('TapEvent.create encodes precision geohash accurately', () {
      final tap = TapEvent.create(
        id: 'test_123',
        userId: 'user_abc',
        latitude: 37.7749,
        longitude: -122.4194,
        pitch: 12.5,
        roll: -3.2,
        postureState: 'Heads Up (Optimal)',
      );

      expect(tap.id, equals('test_123'));
      expect(tap.geohash.isNotEmpty, isTrue);
      expect(tap.geohash.length, equals(7)); // Default precision 7
      expect(tap.postureState, equals('Heads Up (Optimal)'));

      // Serialization round-trip
      final map = tap.toMap();
      final fromMap = TapEvent.fromMap(map, tap.id);
      expect(fromMap.latitude, closeTo(37.7749, 0.0001));
      expect(fromMap.longitude, closeTo(-122.4194, 0.0001));
      expect(fromMap.geohash, equals(tap.geohash));
    });
  });

  group('Formatters Unit Tests', () {
    test('Coordinate formatter formats cardinals correctly', () {
      final formatted = Formatters.formatCoordinates(37.7749, -122.4194);
      expect(formatted, equals('37.7749° N, 122.4194° W'));
    });

    test('Relative time formatter formats recent intervals', () {
      final now = DateTime.now();
      expect(Formatters.formatRelativeTime(now), equals('Just now'));
      expect(
        Formatters.formatRelativeTime(now.subtract(const Duration(minutes: 5))),
        equals('5 mins ago'),
      );
    });

    test('Angle formatter formats degrees', () {
      expect(Formatters.formatAngle(14.24), equals('14.2°'));
    });
  });

  group('Sensor Posture Data Unit Tests', () {
    test('PostureData initial defaults to upright optimal', () {
      final initial = PostureData.initial();
      expect(initial.category, equals(PostureCategory.headsUp));
      expect(initial.pitch, equals(0.0));
      expect(initial.roll, equals(0.0));
    });
  });
}
