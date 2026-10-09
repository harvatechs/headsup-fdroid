import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';

class LocationService {
  final Location _location = Location();
  bool _initialized = false;
  LocationData? _lastKnownLocation;

  LocationData? get lastKnownLocation => _lastKnownLocation;

  LatLng get currentCoordinates {
    if (_lastKnownLocation != null &&
        _lastKnownLocation!.latitude != null &&
        _lastKnownLocation!.longitude != null) {
      return LatLng(_lastKnownLocation!.latitude!, _lastKnownLocation!.longitude!);
    }
    return AppConstants.defaultLocation;
  }

  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint('LocationService: Location service disabled');
          return false;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          debugPrint('LocationService: Location permission denied');
          return false;
        }
      }

      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 3000,
        distanceFilter: 5,
      );

      _lastKnownLocation = await _location.getLocation();
      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('LocationService initialization error: $e');
      return false;
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasInit = await initialize();
      if (!hasInit) return _lastKnownLocation;

      final loc = await _location.getLocation().timeout(
        const Duration(seconds: 6),
        onTimeout: () => _lastKnownLocation ?? LocationData.fromMap({
          'latitude': AppConstants.defaultLocation.latitude,
          'longitude': AppConstants.defaultLocation.longitude,
        }),
      );
      _lastKnownLocation = loc;
      return loc;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return _lastKnownLocation;
    }
  }

  Stream<LocationData> getLocationStream() {
    return _location.onLocationChanged.handleError((error) {
      debugPrint('Location stream error: $error');
    });
  }
}
