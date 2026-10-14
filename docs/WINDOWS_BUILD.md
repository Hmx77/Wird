# Build Wird on Windows

This guide builds the supplied source. GitHub Actions has passed analysis, all 22 tests, Android debug compilation and unsigned iOS compilation/simulator launch; see BUILD_STATUS_2026-10-14.md for exact revisions and remaining device gates. The included PowerShell script stops at the first failed command. Do not run `flutter create .` over this project: its native widget, notification and signing configuration is already included.

## 1. Install the project toolchain

Use your Windows computer (not a cloud shell containing service credentials). Install Git for Windows, Python 3 with `python` on PATH, Android Studio, and a Java 17 JDK. Download the **Windows Flutter 3.35.7** SDK from the official archive: https://docs.flutter.dev/install/archive. This is the source project's pinned baseline, not a claim that it is the newest SDK. Extract it to `C:\src\flutter`. Extract the app archive to `C:\src\wird_flutter_starter` (the directory containing `pubspec.yaml`).

In Android Studio's SDK Manager install Android SDK Platform 36, SDK Build-Tools 35.0.0, Android SDK Platform-Tools and Android SDK Command-line Tools (latest). Install the Android Emulator if you do not use a physical phone. Gradle may download the Flutter-selected NDK on its first build. Dependency downloads require internet; the resulting app's core reading and tracking work offline.

Open a new PowerShell window. Adjust the JDK path below to your actual Java 17 installation:

```powershell
$env:Path = "C:\src\flutter\bin;$env:Path"
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-17'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
Set-Location C:\src\wird_flutter_starter
flutter config --no-analytics
dart --disable-analytics
flutter config --jdk-dir "$env:JAVA_HOME"
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
flutter doctor --android-licenses
flutter doctor -v
```

Accept the Android SDK licenses only after reading them. Resolve Android toolchain errors reported by `doctor` before proceeding. A missing Visual Studio Windows-desktop toolchain does not block this Android project. Do not paste private paths or credentials from local diagnostics into public issues.

## 2. Analyze, test and build a test APK

```powershell
.\tool\build-windows.ps1 -Mode Debug
```

If your personal machine blocks downloaded scripts, review this project's script and use `Unblock-File .\tool\build-windows.ps1`. Do not override an organization-managed execution policy. The exact equivalent commands can also be run individually; stop if any fails:

```powershell
flutter --version
flutter pub get
dart tool/content_check.dart
flutter test tool/brand_assets_test.dart
python tool/static_check.py
flutter analyze
flutter test
flutter build apk --debug
```

Keep the generated `pubspec.lock` with the project once dependency installation succeeds. It was not fabricated in this package. Output: `build\app\outputs\flutter-apk\app-debug.apk`.

Enable USB debugging on your Android phone, connect it, and approve its debugging prompt; or start an Android emulator:

```powershell
flutter devices
flutter run
```

If multiple devices appear, use `flutter run -d DEVICE_ID`, replacing `DEVICE_ID` with the listed Android device ID. Test the cases in `docs/RELEASE_READINESS.md`, especially airplane-mode use, counters across midnight, Arabic text scaling, reminders, share cards and widget refresh.

## 3. Build signed release APK and AAB

Create an upload keystore once, outside the project. Keep a secure backup. Do not overwrite an existing production key. This command prompts for passwords instead of placing them in command history:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\wird-signing"
keytool -genkeypair -v -keystore "$env:USERPROFILE\wird-signing\upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
Copy-Item android\key.properties.example android\key.properties
notepad android\key.properties
```

In that local properties file set `storePassword` and `keyPassword` to your real values, `keyAlias=upload`, and `storeFile=C:/Users/YOUR_WINDOWS_USER/wird-signing/upload-keystore.jks`. Use forward slashes in the absolute path; Java properties interprets backslashes as escapes. Do not quote values. Follow Java properties escaping rules if a password contains backslashes. The file and keystores are ignored by Git; exclude them from any manually created archive as well. Never send them to ChatGPT.

```powershell
.\tool\build-windows.ps1 -Mode Release
```

This reruns validation, analysis and tests, then runs `flutter build apk --release` and `flutter build appbundle --release`. Outputs:

- `build\app\outputs\flutter-apk\app-release.apk`
- `build\app\outputs\bundle\release\app-release.aab`

No Play account is needed to build locally. Distribution requires your signing/account setup and current store compliance. The project's SDK baseline is not a guarantee of current store eligibility. Source: https://docs.flutter.dev/deployment/android.

## 4. Prepare iOS on a Mac

Windows cannot compile this iOS project. Copy source and the generated lockfile to a Mac with the same Flutter baseline, a compatible Xcode installation and CocoaPods. Follow https://docs.flutter.dev/platform-integration/ios/setup for the installed Xcode version, then:

```sh
flutter doctor -v
flutter pub get
flutter test tool/brand_assets_test.dart
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

In Xcode select your Apple signing team for **Runner** and **WirdWidget**. Confirm ownership of `ae.wird.app`, `ae.wird.app.WirdWidget` and `group.ae.wird.app`; change bundle IDs, entitlements and the App Group strings in Dart/Swift together if needed. Enable and provision the matching App Group on both targets. An unsigned compilation check is `flutter build ios --release --no-codesign`; a provisioned archive is `flutter build ipa --release`. Test the widget on an actual iPhone. Source: https://docs.flutter.dev/deployment/ios.

## Content and audio release gates

The archive preserves the exact source logo and ten themes. Do not bypass the reviewed-content filter or audio rights checks to fill missing material. The current source-checked corpus still needs independent qualified Arabic/religious proofreading before public release. There are no bundled recordings; add only recordings with documented redistribution rights, matching hashes and Arabic review, as specified in `docs/AUDIO_PERMISSIONS.md`.
