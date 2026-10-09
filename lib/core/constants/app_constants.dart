import 'package:latlong2/latlong.dart';

class AppConstants {
  // App Info
  static const String appName = 'Heads Up';
  static const String appTagline = 'Real-time Geospatial & Sensor Tracking';

  // Firestore Collections
  static const String tapsCollection = 'taps';
  static const String usersCollection = 'users';

  // Geohash Precision
  static const int defaultGeohashPrecision = 7; // ~150m x 150m resolution

  // Default Map Coordinates (San Francisco / Default fallback if GPS unavailable)
  static const LatLng defaultLocation = LatLng(37.7749, -122.4194);
  static const double defaultZoom = 15.0;

  // Map Tile Providers (Free OpenStreetMap & CartoDB)
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String cartoDarkTileUrl = 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  static const String cartoLightTileUrl = 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
  static const String mapUserAgent = 'com.kora.headsup/1.0.0';

  // Posture Angle Thresholds (Degrees)
  // Pitch: Angle from vertical (0° = upright, >35° = looking down)
  static const double uprightPitchThreshold = 25.0;
  static const double lookingDownPitchThreshold = 45.0;
  static const double rollTiltThreshold = 30.0;
}
