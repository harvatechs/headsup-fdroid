import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticsService {
  static Future<void> lightImpact() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 35);
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  static Future<void> successPattern() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(pattern: [0, 40, 60, 50]);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  static Future<void> errorPattern() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(pattern: [0, 100, 100, 100]);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }
}
