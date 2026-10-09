import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../constants/app_constants.dart';

enum PostureCategory {
  headsUp,
  neutral,
  tiltedDown,
  tiltedLateral,
  flat
}

class PostureData {
  final double pitch; // In degrees (-90 to +90)
  final double roll;  // In degrees (-180 to +180)
  final double x;
  final double y;
  final double z;
  final PostureCategory category;
  final String label;

  const PostureData({
    required this.pitch,
    required this.roll,
    required this.x,
    required this.y,
    required this.z,
    required this.category,
    required this.label,
  });

  factory PostureData.initial() {
    return const PostureData(
      pitch: 0.0,
      roll: 0.0,
      x: 0.0,
      y: 0.0,
      z: 9.8,
      category: PostureCategory.headsUp,
      label: 'Heads Up (Optimal)',
    );
  }
}

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  final _postureController = StreamController<PostureData>.broadcast();

  PostureData _currentPosture = PostureData.initial();
  PostureData get currentPosture => _currentPosture;

  Stream<PostureData> get postureStream => _postureController.stream;

  void startListening() {
    _accelerometerSub?.cancel();
    try {
      _accelerometerSub = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final x = event.x;
          final y = event.y;
          final z = event.z;

          // Compute Pitch and Roll angles in degrees
          // Pitch: Tilt forward/backward (device elevation)
          // Roll: Tilt left/right
          final pitchRad = atan2(y, sqrt(x * x + z * z));
          final rollRad = atan2(x, sqrt(y * y + z * z));

          final pitchDeg = pitchRad * (180.0 / pi);
          final rollDeg = rollRad * (180.0 / pi);

          // Classify posture
          PostureCategory category;
          String label;

          if (z.abs() > 8.5 && y.abs() < 3.0 && x.abs() < 3.0) {
            category = PostureCategory.flat;
            label = 'Flat / Resting';
          } else if (pitchDeg > AppConstants.lookingDownPitchThreshold) {
            category = PostureCategory.tiltedDown;
            label = 'Looking Down (Bad Angle)';
          } else if (rollDeg.abs() > AppConstants.rollTiltThreshold) {
            category = PostureCategory.tiltedLateral;
            label = rollDeg > 0 ? 'Tilted Right' : 'Tilted Left';
          } else if (pitchDeg > AppConstants.uprightPitchThreshold) {
            category = PostureCategory.neutral;
            label = 'Slight Incline';
          } else {
            category = PostureCategory.headsUp;
            label = 'Heads Up (Optimal)';
          }

          _currentPosture = PostureData(
            pitch: pitchDeg,
            roll: rollDeg,
            x: x,
            y: y,
            z: z,
            category: category,
            label: label,
          );

          if (!_postureController.isClosed) {
            _postureController.add(_currentPosture);
          }
        },
        onError: (error) {
          debugPrint('SensorService error: $error');
        },
      );
    } catch (e) {
      debugPrint('SensorService startListening exception: $e');
    }
  }

  void stopListening() {
    _accelerometerSub?.cancel();
    _accelerometerSub = null;
  }

  void dispose() {
    stopListening();
    _postureController.close();
  }
}
