# Phase 2: Build & Run Instructions

## Quick Start

### Prerequisites
```bash
# Check Flutter installation
flutter doctor

# Should show: Flutter 3.8.1+
# Android SDK: 34+
# Dart SDK: 3.3.1+
```

### Build & Run
```bash
# Navigate to project
cd e:\Study\Coding_Projects\Flutter_Projects\chatter

# Get latest dependencies
flutter pub get

# Run on connected emulator/device
flutter run

# Or specify device
flutter run -d <device-id>

# List available devices
flutter devices
```

### Build Release APK
```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build Debug APK
```bash
# Build debug APK (faster)
flutter build apk --debug

# Output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Development Testing

### Run with Logging
```bash
# Verbose logging
flutter run -v

# Shows all build steps, warnings, errors
```

### Run with Profiler
```bash
# Run with profiler
flutter run --profile

# Helps identify performance issues
```

### Hot Reload / Hot Restart
```bash
# While app is running in terminal:

# Hot Reload (keeps app state)
Press 'r'

# Hot Restart (restarts app)
Press 'R'

# Quit
Press 'q'
```

---

## Code Quality Checks

### Static Analysis
```bash
flutter analyze

# Should output:
# Analyzing chatter...
# No issues found! (ran in X.Xs)
```

### Run Tests
```bash
flutter test

# Runs all tests in test/ directory
```

### Check Dependencies
```bash
flutter pub outdated

# Shows package versions available
```

---

## Troubleshooting

### App won't build
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Clear Android build cache
flutter clean
rm -r build/
rm -r .dart_tool/
flutter pub get
flutter run
```

### Emulator issues
```bash
# List Android emulators
emulator -list-avds

# Start specific emulator
emulator -avd <emulator-name>

# Or use:
flutter emulators --launch <emulator-name>
```

### Package conflicts
```bash
# Get latest versions
flutter pub upgrade

# Or specific package
flutter pub upgrade <package-name>

# Resolve conflicts
flutter pub get
```

### Firebase issues
```bash
# Verify Firebase setup
cat android/app/google-services.json

# Check Firebase options
cat lib/firebase_options.dart

# If needed, reconfigure:
flutterfire configure
```

---

## Emulator Setup (if needed)

### Create New Emulator
```bash
# List available AVDs
emulator -list-avds

# Create new AVD (if needed)
avdmanager create avd \
  -n "sdk_gphone64_x86_64" \
  -k "system-images;android-34;google_apis;x86_64" \
  -d pixel_4

# Start emulator
emulator -avd sdk_gphone64_x86_64 -no-boot-anim
```

### Common Emulator Settings
```bash
# Start with specific settings
emulator -avd <name> \
  -no-audio \
  -no-boot-anim \
  -netspeed full \
  -netdelay none
```

---

## Testing Workflow

### Manual Testing
```bash
# 1. Build and run
flutter run

# 2. Navigate through app
# - Tap Community tab
# - View posts
# - Like a post
# - Create new post
# - Add comment
# - Logout

# 3. Check console for errors
# Watch terminal output for debugPrint() messages
```

### Automated Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
open coverage/index.html  # macOS
coverage\index.html      # Windows
```

---

## Performance Profiling

### Profile Mode Build
```bash
# Run with profiling
flutter run --profile

# Or build APK
flutter build apk --profile
```

### Memory Profiling
```bash
# In DevTools (auto-opened with flutter run):
1. Open DevTools in browser
2. Click "Memory" tab
3. Monitor memory usage
4. Take snapshots before/after actions
```

### Performance Monitor
```bash
# Enable on-screen perf overlay:
# In terminal while app running:
Press 'p'  # Toggle performance overlay

# Shows:
# - Frame rate (FPS)
# - Memory usage
# - CPU percentage
```

---

## Installation & Distribution

### Install on Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or install APK directly
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Export Build
```bash
# Create release directory
mkdir -p releases

# Build APK
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk releases/

# Build AAB (for Play Store)
flutter build appbundle --release
cp build/app/outputs/bundle/release/app-release.aab releases/
```

---

## Environment Setup

### Windows
```batch
# Add Flutter to PATH
setx PATH "%PATH%;C:\flutter\bin"

# Verify
flutter --version
dart --version

# Accept licenses
flutter doctor --android-licenses
```

### macOS/Linux
```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Add to ~/.bashrc or ~/.zshrc for persistence
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc

# Verify
flutter --version
dart --version

# Accept licenses
flutter doctor --android-licenses
```

---

## Directory Structure After Build

```
chatter/
├── build/
│   ├── app/
│   │   └── outputs/
│   │       └── flutter-apk/
│   │           ├── app-debug.apk
│   │           └── app-release.apk
│   └── ...
├── lib/
├── android/
├── ios/
├── web/
├── test/
├── pubspec.yaml
└── ...
```

---

## Common Commands Quick Reference

```bash
# Development
flutter run                      # Run in debug mode
flutter run -v                  # Run with verbose logging
flutter run --profile           # Run in profile mode
flutter run -d <id>             # Run on specific device

# Building
flutter build apk --release     # Build release APK
flutter build apk --debug       # Build debug APK
flutter build appbundle         # Build for Play Store
flutter build ios --release     # Build for iOS

# Code Quality
flutter analyze                 # Static analysis
flutter test                    # Run tests
flutter pub get                 # Get dependencies
flutter pub upgrade             # Upgrade dependencies
flutter clean                   # Clean build files

# Development Tools
flutter devices                 # List connected devices
flutter pub outdated            # Check outdated packages
flutter doctor                  # Check environment
flutter format .                # Format code
flutter --version               # Check Flutter version

# Firebase
flutterfire configure            # Configure Firebase
flutterfire config --platforms=android,ios
```

---

## Debug Tips

### Enable Logging
```dart
// In code:
import 'package:flutter/foundation.dart';

debugPrint('Debug message'); // Only in debug mode

// Check console output:
// I/flutter ( 1234): Debug message
```

### Use Breakpoints
```bash
# In VS Code:
1. Open file
2. Click line number to add breakpoint
3. Run: flutter run
4. Click Continue in debugger when breakpoint hit
```

### Monitor Network
```dart
// Add logging for API calls:
debugPrint('API Call: ${method} ${url}');
debugPrint('Response: $response');
```

---

## Release Checklist

Before building release:

- [ ] `flutter analyze` passes (0 issues)
- [ ] `flutter test` passes (all tests)
- [ ] No console warnings
- [ ] Version updated in pubspec.yaml
- [ ] Firebase configured
- [ ] All strings localized (if needed)
- [ ] No hardcoded secrets
- [ ] Performance tested
- [ ] Security reviewed

---

## Version Management

### Update Version
```yaml
# pubspec.yaml
version: 2.0.0+20  # major.minor.patch+build
```

### Build Numbers
```bash
# Build with custom version
flutter build apk --build-number=21

# Or in pubspec.yaml:
# version: 2.0.0+21
```

---

## Continuous Integration (CI/CD)

### GitHub Actions Example
```yaml
# .github/workflows/build.yml
name: Build Flutter App

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
        with:
          flutter-version: '3.8.1'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release
      - run: flutter build appbundle --release
```

---

## Support

### Get Help
```bash
# Official documentation
flutter.dev

# Channel help
flutter help

# Specific command help
flutter help run
flutter help build

# Ask community
# Stack Overflow tag: flutter
# GitHub Issues: flutter/flutter
```

### Report Issues
```bash
flutter doctor -v  # Provides environment info

# Copy output and include in issue report
```

---

**You're all set! Happy coding! 🚀**

---

## Phase 2 Build Status

✅ **Status:** Ready to Build & Run

**To start:**
```bash
cd e:\Study\Coding_Projects\Flutter_Projects\chatter
flutter run
```

**Expected output:**
- App launches on emulator
- Auth screen appears first
- Login/Signup works
- Community feed loads with posts
- All features functional

**Then test the 15 scenarios in PHASE_2_TESTING.md**

---
