# Technology Stack

**Analysis Date:** 2026-05-09

## Languages

**Primary:**
- Dart 3.11.5+ - Primary application language for Flutter framework

**Secondary:**
- Kotlin - Android native development (via Gradle)
- Swift - iOS/macOS native development
- CMake - Linux native build configuration
- HTML/CSS/JavaScript - Web platform

## Runtime

**Environment:**
- Flutter SDK (stable channel, revision 00b0c91f06209d9e4a41f71b7a512d6eb3b9c694)
- Dart SDK: >=3.11.5 <4.0.0

**Package Manager:**
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter 3.18.0+ - Cross-platform UI framework (iOS, Android, Linux, macOS, Windows, Web)

**Testing:**
- flutter_test (SDK) - Unit and widget testing

**Build/Dev:**
- flutter_lints 6.0.0 - Linting rules
- Android Gradle - Android build system
- Xcode - iOS/macOS build system

## Key Dependencies

**Critical:**
- `cupertino_icons: ^1.0.8` - iOS-style icons for Cupertino widgets

**Transitive (SDK-managed):**
- `async: 2.13.1` - Async programming utilities
- `collection: 1.19.1` - Collection utilities
- `material_color_utilities: 0.13.0` - Material color calculations
- `vector_math: 2.2.0` - Vector/matrix math for graphics
- `meta: 1.17.0` - Annotations and constants
- `path: 1.9.1` - Path manipulation

## Configuration

**Environment:**
- No `.env` files detected - Configuration currently hardcoded
- Flutter SDK version constraint in `pubspec.yaml`

**Build:**
- `analysis_options.yaml` - Dart analyzer configuration
- `android/build.gradle.kts` - Android Gradle build config
- `android/settings.gradle.kts` - Android project settings
- `web/index.html` - Web entry point

**Platform Support:**
- Android (minSdk, targetSdk defined in Gradle)
- iOS (Xcode project configured)
- Linux (CMake configuration)
- macOS (Xcode configuration)
- Windows (Visual Studio configuration)
- Web (Flutter web bootstrap)

## Platform Requirements

**Development:**
- Flutter SDK 3.18.0+
- Dart SDK >=3.11.5
- Android Studio / Xcode for native builds

**Production:**
- Android 5.0+ (API level 21+)
- iOS 12.0+
- Modern browsers for web

---

*Stack analysis: 2026-05-09*