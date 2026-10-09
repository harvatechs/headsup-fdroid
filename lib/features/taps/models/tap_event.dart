import 'package:dart_geohash/dart_geohash.dart';
import '../../../core/constants/app_constants.dart';

class TapEvent {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final String geohash;
  final double pitch;
  final double roll;
  final String postureState;
  final String gestureType;
  final String? note;

  const TapEvent({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.geohash,
    required this.pitch,
    required this.roll,
    required this.postureState,
    required this.gestureType,
    this.note,
  });

  /// Factory constructor to create a new tap event with auto-generated geohash
  factory TapEvent.create({
    required String id,
    required String userId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    required double pitch,
    required double roll,
    required String postureState,
    String gestureType = 'single_tap',
    String? note,
    DateTime? timestamp,
  }) {
    String computedGeohash;
    try {
      final geoHasher = GeoHasher();
      // Note: GeoHasher.encode takes (longitude, latitude)
      computedGeohash = geoHasher.encode(
        longitude,
        latitude,
        precision: AppConstants.defaultGeohashPrecision,
      );
    } catch (_) {
      computedGeohash = 'unknown';
    }

    return TapEvent(
      id: id,
      userId: userId,
      timestamp: timestamp ?? DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      geohash: computedGeohash,
      pitch: pitch,
      roll: roll,
      postureState: postureState,
      gestureType: gestureType,
      note: note,
    );
  }

  factory TapEvent.fromMap(Map<String, dynamic> map, String id) {
    return TapEvent(
      id: id,
      userId: map['userId'] as String? ?? 'anonymous',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      altitude: (map['altitude'] as num?)?.toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      geohash: map['geohash'] as String? ?? '',
      pitch: (map['pitch'] as num?)?.toDouble() ?? 0.0,
      roll: (map['roll'] as num?)?.toDouble() ?? 0.0,
      postureState: map['postureState'] as String? ?? 'Heads Up (Optimal)',
      gestureType: map['gestureType'] as String? ?? 'single_tap',
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'geohash': geohash,
      'pitch': pitch,
      'roll': roll,
      'postureState': postureState,
      'gestureType': gestureType,
      'note': note,
    };
  }

  TapEvent copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    String? geohash,
    double? pitch,
    double? roll,
    String? postureState,
    String? gestureType,
    String? note,
  }) {
    return TapEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      geohash: geohash ?? this.geohash,
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
      postureState: postureState ?? this.postureState,
      gestureType: gestureType ?? this.gestureType,
      note: note ?? this.note,
    );
  }
}
