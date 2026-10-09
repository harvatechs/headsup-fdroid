<div align="center">

# Heads Up 📱🧭

**Real-time Posture Tracking, Live Sensor HUD & Geospatial Activity Mapping**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Flutter-02569B?logo=flutter)](https://flutter.dev)
[![F-Droid Compatible](https://img.shields.io/badge/F--Droid-Ready-3DDC84?logo=f-droid)](metadata/com.kora.headsup.yml)
[![Offline First](https://img.shields.io/badge/Privacy-100%25%20Offline%20First-success)](#privacy--architecture)

<p align="center">
  A modern, libre mobile utility designed to detect text-neck tilt, visualize motion dynamics in real-time, and log posture check-ins over OpenStreetMap.
</p>

</div>

---

## 📖 Overview

Modern smartphone users spend hours looking downward at angles up to 60°, placing excessive strain on cervical vertebrae (often termed **"text-neck"**). 

**Heads Up** monitors your device’s orientation in three-dimensional space using native hardware accelerometer and gyroscopic sensors. It translates angles into actionable feedback, maps posture check-ins on interactive open maps, and provides granular analytics—all while keeping 100% of your telemetry private and local.

---

## ✨ Features

- 🎯 **Live Sensor HUD**: Real-time 3D pitch and roll tilt detection with instantaneous visual posture state feedback.
- 📳 **Haptic Feedback**: Optional tactile impulse alerts when you tilt downward beyond healthy thresholds.
- 🗺️ **Geospatial Activity Mapping**: Render posture events and check-in history directly on interactive **OpenStreetMap** (powered by `flutter_map` without proprietary map blobs).
- 📍 **Precision Geohashing**: Automatically groups nearby taps using compact geohash algorithms for clustered spatial exploration.
- 📊 **Activity & Posture Analytics**: Inspect hourly usage patterns, time spent in optimal vs. tilted postures, and overall posture scores.
- 🔒 **Privacy & Offline First**: Zero required tracking, telemetry harvesting, or compulsory accounts. Full guest mode functions without an internet connection.
- 📦 **Dual Flavor Architecture**:
  - **`foss`**: Completely free of Google Play Services, closed-source dependencies, and non-free endpoints for **F-Droid**.
  - **`play`**: Optional cloud sync via Firebase for Google Play Store builds.

---

## 📐 Posture Classification Logic

| Posture State | Pitch Angle | Description | Indicator |
| :--- | :--- | :--- | :--- |
| **Optimal (Heads Up)** | $\le 25^\circ$ | Device is held close to eye level; minimal neck strain. | 🟢 Emerald |
| **Neutral** | $25^\circ - 35^\circ$ | Slight angle; normal handheld posture. | 🔵 Cyan |
| **Tilted** | $35^\circ - 45^\circ$ | Moderate downward angle; text-neck warning zone. | 🟡 Amber |
| **Looking Down** | $> 45^\circ$ | Severe downward angle; high cervical stress. | 🔴 Crimson |

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.11.5`)
- **State Management**: [Riverpod 3](https://riverpod.dev)
- **Mapping & Geodata**: [flutter_map](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2) + [dart_geohash](https://pub.dev/packages/dart_geohash)
- **Hardware Interop**:
  - `sensors_plus` (Hardware accelerometer / gyroscope)
  - `location` (Android Location Services)
  - `vibration` (Android Haptics Engine)
- **Layered Architecture**: Feature-first domain modules (`features/auth`, `features/home`, `features/map`, `features/stats`, `features/taps`) backed by abstract repositories.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.20.0`)
- Android SDK (`compileSdk 35+`, `minSdk 24+`)
- Java JDK 17 or 21

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/harvatechs/headsup-fdroid.git
   cd headsup-fdroid
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run unit & widget tests**:
   ```bash
   flutter test
   ```

4. **Run the app on a connected device/emulator**:
   ```bash
   flutter run --flavor foss
   ```

---

## 📦 Building APKs

### 1. F-Droid / FOSS Release Build (Recommended)
Builds a 100% libre APK that excludes proprietary Google Play Services plugins, disables runtime font downloads, and runs completely offline:

```bash
flutter build apk --flavor foss --release
```
> **Output artifact:** `build/app/outputs/flutter-apk/app-foss-release.apk`

### 2. Google Play Build
Builds the variant configured with optional Google Services and Firebase authentication:

```bash
flutter build apk --flavor play --release
```
> **Output artifact:** `build/app/outputs/flutter-apk/app-play-release.apk`

---

## 🤖 F-Droid Inclusion Information

This repository is pre-configured for automated inclusion in the official **[fdroiddata](https://gitlab.com/fdroid/fdroiddata)** catalog:

- **Build Recipe**: [`metadata/com.kora.headsup.yml`](metadata/com.kora.headsup.yml)
- **Store Metadata**: Standard Fastlane structure under [`fastlane/metadata/android/en-US/`](fastlane/metadata/android/en-US/)
  - `title.txt`
  - `short_description.txt`
  - `full_description.txt`
  - `changelogs/1.txt`
- **Application ID**: `com.kora.headsup`
- **Build Mode**: `flutter` (flavor: `foss`)

---

## 🛡️ Permissions

| Permission | Purpose |
| :--- | :--- |
| `android.permission.ACCESS_FINE_LOCATION` | Logs geographic coordinates during manual posture check-in taps. |
| `android.permission.ACCESS_COARSE_LOCATION` | Approximate location fallback. |
| `android.permission.VIBRATE` | Provides brief haptic feedback alerts. |
| `android.permission.INTERNET` | Fetches open map raster tiles from OpenStreetMap. |

---

## 📄 License

Licensed under the **Apache License, Version 2.0**. See the [LICENSE](LICENSE) file for details.
