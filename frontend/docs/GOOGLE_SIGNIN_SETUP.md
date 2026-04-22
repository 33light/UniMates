# Google Sign-In Configuration Guide

## Android Configuration

### Step 1: Get SHA-1 Fingerprint
Run the following command in your Android project directory to get your debug SHA-1 fingerprint:

**On Windows:**
```bash
cd android
.\gradlew signingReport
```

Look for the SHA-1 value in the output under "debugAndroidTest" or "debug".

Alternatively, if the above doesn't work, use keytool:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Step 2: Add SHA-1 to Firebase Console
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: **chatter-via-flutter**
3. Go to Project Settings → Your Apps → Android app
4. Click on "Add Fingerprint"
5. Paste your SHA-1 fingerprint
6. Download the updated `google-services.json` and place it in `android/app/`

### Step 3: Update Android Manifest (if needed)
The `google_sign_in` package should automatically handle Android configuration. No manual AndroidManifest.xml changes are required for the current setup.

---

## iOS Configuration

### Step 1: Get Reverse Client ID
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: **chatter-via-flutter**
3. Go to Project Settings → Your Apps → iOS app
4. Copy the **Reverse Client ID** (looks like: `com.googleusercontent.apps.123456789-xxx`)

### Step 2: Add URL Schemes to Info.plist
Edit `ios/Runner/Info.plist` and add the URL schemes:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSE_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Replace `YOUR_REVERSE_CLIENT_ID` with your actual Reverse Client ID.

### Step 3: Update GIDSignInScopes (if custom scopes needed)
The current implementation uses default scopes. For custom scopes, modify `lib/screens/auth.dart` and add:

```dart
_googleSignIn = GoogleSignIn(
  scopes: ['profile', 'email'],
);
```

---

## Testing Authentication

### Email/Password Authentication
1. Launch the app
2. On the auth screen, enter an email and password (min 8 characters)
3. Click "Sign Up" to create a new account
4. Log out and try "Login" with the same credentials

### Google Sign-In
1. Ensure your device/emulator has Google Play Services installed
2. Click "Sign in with Google" button
3. Select your Google account
4. You should be redirected to the home screen

---

## Troubleshooting

### Android Issues
- **"Google Play Services not available"**: Install Google Play Services on your emulator or use a physical device
- **"SHA-1 mismatch"**: Ensure you added the correct SHA-1 to Firebase Console
- **"Web Client ID missing"**: The app doesn't require Web Client ID for Android Google Sign-In, but you need the SHA-1

### iOS Issues
- **"URL scheme not registered"**: Make sure you added the reverse client ID to Info.plist correctly
- **"Sign-in cancelled"**: User might have cancelled. Allow retry.
- **"Web view errors"**: Make sure iOS build is in Release mode or properly configured for debug

### General
- **dependencies error**: Run `flutter pub get` after updating pubspec.yaml
- **Firebase not initialized**: Ensure `FirebaseCore` initialization completes before showing auth screen
- **Sign-in hangs**: Check internet connection and Firebase project is properly configured
