# SpeedAlt — GPS Speedometer & Altimeter

A clean, modern, privacy-first GPS Speedometer and Altimeter mobile application built with **Flutter** for **Android** and **iOS**.

---

## 🎯 App Purpose

SpeedAlt turns your mobile device into a high-precision, glanceable digital instrument cluster for driving, cycling, boating, hiking, or walking. It computes your current speed, altitude, distance, and trip statistics in real time using your phone's built-in GPS hardware.

**Core Philosophy:** 100% offline, zero data collection, zero battery drain from unnecessary background tasks, and zero third-party cloud tracking.

---

## 🚀 Key Features

* **⚡ High-Visibility Speedometer:**
  * Ultra-large, high-contrast digital speed readout optimized for quick glanceability while in motion.
  * Native GPS speed extraction with adaptive stationary filtering (stabilizes at `0` to prevent 1–3 km/h standing jitter).
  * Physics-based spike rejection (suppresses unrealistic GPS jumps and teleportation errors from polluting maximum speed).
* **⛰️ Real-Time Altimeter:**
  * Displays elevation from satellite telemetry in meters or feet.
  * Vertical accuracy tracking with visual indicator when accuracy is low.
  * Modular architecture with pluggable `IAltimeterSource` for future barometric pressure sensor integration.
* **📊 Comprehensive Trip Computer:**
  * **Average Speed:** Computed from valid movement data, filtering stationary stops.
  * **Maximum Speed:** Peak speed recorded during the active session.
  * **Travelled Distance:** Geodesic distance calculation with stationary drift suppression.
  * **Duration:** Accurate `HH:MM:SS` active trip timer.
* **🛰️ Live GPS Telemetry:**
  * Continuous satellite accuracy reporting (`±X m` / `±X ft`).
  * Live Latitude and Longitude coordinate formatting.
  * Distinct status indicators: `GPS Ready`, `Searching for GPS...`, `Poor GPS Signal`, and `Location Disabled`.
* **🎮 Intuitive Trip Controls:**
  * **START** → Launches tracking session and starts duration timer.
  * **PAUSE / RESUME** → Temporarily halts trip accumulation (e.g. during a rest stop).
  * **STOP** → Concludes tracking and freezes final session statistics on screen.
  * **RESET** → Clears session metrics back to zero following a confirmation dialog.
* **🎨 Modern Material 3 UI & Themes:**
  * **Dark Mode:** Deep slate/OLED black with vibrant cyan accents for glare-free night driving.
  * **Light Mode:** Crisp, clean styling with clear contrast.
  * **System Mode:** Follows OS appearance automatically.
* **🔒 Keep Screen Awake:**
  * Optional wakelock prevents your display from dimming or sleeping while a trip is active.
* **📐 Flexible Units:**
  * Speed: `km/h` or `mph`
  * Altitude: `meters` or `feet`
  * Distance: `kilometers` or `miles`
  * Preferences are persisted locally on the device using `SharedPreferences`.

---

## 🛡️ Privacy & Security Guarantee

SpeedAlt takes user privacy seriously:
* ❌ **No User Accounts or Login:** No signup, email, or credentials required.
* ❌ **No Cloud Backend or Firebase:** Zero remote servers or external databases.
* ❌ **No Analytics or Trackers:** No Google Analytics, Mixpanel, Segment, or telemetry SDKs.
* ❌ **No Advertisements:** Zero ad networks or tracking identifiers (IDFA / GAID).
* ❌ **No Location Uploads:** All calculations happen 100% locally on your device. Your coordinates never leave your phone.

---

## 📋 Permissions

SpeedAlt requests only the minimum permissions necessary for its core functionality:

### Android (`android/app/src/main/AndroidManifest.xml`)
* `android.permission.ACCESS_FINE_LOCATION`: Required to access high-precision GPS satellite telemetry for speed and altitude.
* `android.permission.ACCESS_COARSE_LOCATION`: Required as a standard Android location fallback.

### iOS (`ios/Runner/Info.plist`)
* `NSLocationWhenInUseUsageDescription`:
  > *"SpeedAlt uses your location to calculate speed, altitude and travelled distance."*

> [!NOTE]
> SpeedAlt intentionally does **NOT** request background location permissions. Tracking operates exclusively while the app is active in the foreground.

---

## 🛠️ Prerequisites & Requirements

* **Flutter SDK:** Version `3.19.0` or higher (tested with Flutter `3.47.5` / Dart `3.13.4`)
* **Android:** Android SDK 21 (Lollipop) or higher
* **iOS:** iOS 12.0 or higher / Xcode 15 or higher

---

## 💻 How to Run Locally

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/speed_alt.git
   cd speed_alt
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run unit & widget tests:**
   ```bash
   flutter test
   ```

4. **Launch on connected device or emulator:**
   ```bash
   flutter run
   ```

---

## 📦 Building for Production

### Android (AAB / APK)

To build a release Android App Bundle (AAB) for Google Play:
```bash
flutter build appbundle --release
```
The output file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`

To build a standalone release APK:
```bash
flutter build apk --release
```

### iOS (IPA)

To build a release iOS package for App Store distribution (requires macOS with Xcode):
```bash
flutter build ipa --release
```
The output archive will be placed under:
`build/ios/archive/Runner.xcarchive` and `build/ios/ipa`

---

## ☁️ Codemagic Build

SpeedAlt is architected for seamless Continuous Integration and Continuous Delivery (CI/CD) on [Codemagic](https://codemagic.io/):

1. **Repository Setup:**
   * Push this repository to GitHub, GitLab, or Bitbucket.
   * Connect your Git repository in the Codemagic Dashboard.
2. **Build Workflows:**
   * Select **Flutter App** as the project type.
   * **Android Workflow:**
     * Flutter version: `Channel: stable`
     * Build step command: `flutter build appbundle --release`
     * Artifacts to archive: `build/app/outputs/bundle/release/*.aab`
   * **iOS Workflow:**
     * Xcode version: `Latest stable`
     * CocoaPods: Automatically managed
     * Build step command: `flutter build ipa --release`
     * Artifacts to archive: `build/ios/ipa/*.ipa`
3. **No External Dependencies:**
   * The repository does not contain hardcoded machine paths or external local tools.
   * Signing identities and provisioning profiles can be securely added via Codemagic's environment variables without checking private keys into git.

A ready-to-use [`codemagic.yaml`](codemagic.yaml) template is included in the project root.

---

## ⚙️ Pre-Release Checklist (Before Store Publishing)

Before publishing to the Google Play Store or Apple App Store:

1. **Application / Bundle ID:**
   * Update `applicationId` in `android/app/build.gradle.kts` from `com.example.speed_alt` to your organization's unique domain (e.g. `com.yourcompany.speedalt`).
   * Update `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj` to match your Apple Developer App ID.
2. **Signing Credentials:**
   * **Android:** Create an upload keystore (`key.jks`) and configure `signingConfigs` in `android/app/build.gradle.kts`.
   * **iOS:** Select your Apple Developer Team in Xcode and configure automatic or manual code signing.
3. **App Icons & Splash:**
   * Use `flutter_launcher_icons` to replace default launcher icons in `android/app/src/main/res/` and `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
4. **Store URLs:**
   * Update `privacyPolicyUrl` and `termsOfUseUrl` in `lib/screens/about_screen.dart` to link to your hosted legal pages if required by store review guidelines.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
