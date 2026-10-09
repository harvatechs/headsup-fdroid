import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tap_event.dart';
import '../repository/tap_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/sensor_service.dart';
import '../../../core/services/haptics_service.dart';

// Services
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  service.initialize();
  return service;
});

final sensorServiceProvider = Provider<SensorService>((ref) {
  final service = SensorService();
  service.startListening();
  ref.onDispose(() => service.dispose());
  return service;
});

final postureStreamProvider = StreamProvider<PostureData>((ref) {
  final sensorService = ref.watch(sensorServiceProvider);
  return sensorService.postureStream;
});

// Repositories
final tapRepositoryProvider = Provider<BaseTapRepository>((ref) {
  return FirestoreTapRepository();
});

// Stream Providers
final userTapsStreamProvider = StreamProvider<List<TapEvent>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final tapRepo = ref.watch(tapRepositoryProvider);
  return tapRepo.watchUserTaps(user.uid);
});

final allTapsStreamProvider = StreamProvider<List<TapEvent>>((ref) {
  final tapRepo = ref.watch(tapRepositoryProvider);
  return tapRepo.watchAllTaps();
});

// Logger Notifier
class TapLoggerNotifier extends Notifier<AsyncValue<TapEvent?>> {
  @override
  AsyncValue<TapEvent?> build() {
    return const AsyncValue.data(null);
  }

  Future<TapEvent?> logCurrentTap({
    String gestureType = 'single_tap',
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(currentUserProvider);
      final userId = user?.uid ?? 'guest_user';

      // 1. Get GPS Location
      final locationService = ref.read(locationServiceProvider);
      final loc = await locationService.getCurrentLocation();
      final lat = loc?.latitude ?? locationService.currentCoordinates.latitude;
      final lng = loc?.longitude ?? locationService.currentCoordinates.longitude;
      final alt = loc?.altitude;
      final acc = loc?.accuracy;

      // 2. Read current posture from SensorService
      final sensorService = ref.read(sensorServiceProvider);
      final posture = sensorService.currentPosture;

      // 3. Create unique tap event
      final tapId = 'tap_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode.abs().toString().padLeft(4, '0').substring(0, 4)}';
      final tapEvent = TapEvent.create(
        id: tapId,
        userId: userId,
        latitude: lat,
        longitude: lng,
        altitude: alt,
        accuracy: acc,
        pitch: posture.pitch,
        roll: posture.roll,
        postureState: posture.label,
        gestureType: gestureType,
        note: note,
        timestamp: DateTime.now(),
      );

      // 4. Trigger Haptic Vibration
      HapticsService.lightImpact();

      // 5. Store in Repository
      final tapRepo = ref.read(tapRepositoryProvider);
      await tapRepo.recordTap(tapEvent);

      state = AsyncValue.data(tapEvent);
      return tapEvent;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      HapticsService.errorPattern();
      return null;
    }
  }

  Future<void> deleteTap(String tapId) async {
    try {
      final tapRepo = ref.read(tapRepositoryProvider);
      await tapRepo.deleteTap(tapId);
      HapticsService.lightImpact();
    } catch (_) {}
  }
}

final tapLoggerProvider =
    NotifierProvider<TapLoggerNotifier, AsyncValue<TapEvent?>>(TapLoggerNotifier.new);
