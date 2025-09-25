# Development Setup Guide

This guide will help you set up the development environment for the Payment Management Flutter App.

## Prerequisites

### Required Software

1. **Flutter SDK**
   - Version: 3.13.9 or higher
   - Channel: Stable
   - Download: [Flutter Official Website](https://flutter.dev/docs/get-started/install)

2. **Dart SDK**
   - Version: >=3.0.6 <4.0.0
   - Usually bundled with Flutter

3. **Git**
   - For version control and repository management

4. **Code Editor**
   - **Recommended**: Visual Studio Code with Flutter/Dart extensions
   - **Alternative**: Android Studio with Flutter plugin

### Platform-Specific Requirements

#### For Web Development
- **Chrome Browser**: For testing and debugging
- **Firebase CLI**: For hosting deployment
  ```bash
  npm install -g firebase-tools
  ```

#### For Android Development
- **Android Studio**: Latest stable version
- **Android SDK**: API level 21 or higher
- **Java JDK**: Version 11 or higher

#### For iOS Development (macOS only)
- **Xcode**: Latest stable version (14.0+)
- **iOS Simulator**: For testing
- **CocoaPods**: For dependency management
  ```bash
  sudo gem install cocoapods
  ```

#### For Windows Desktop Development
- **Visual Studio**: 2022 or later with C++ development tools
- **Windows 10/11 SDK**: Latest version
- **CMake**: Version 3.14 or higher

#### For macOS Desktop Development
- **Xcode**: Latest stable version
- **macOS SDK**: Latest version

#### For Linux Desktop Development
- **Build essentials**: GCC, Make, CMake
  ```bash
  sudo apt-get update
  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
  ```

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/vansaodai-ichi/untitled.git
cd untitled
```

### 2. Verify Flutter Installation

```bash
flutter doctor
```

This command will check your Flutter installation and highlight any missing dependencies.

### 3. Install Dependencies

```bash
flutter pub get
```

This will download all the required packages listed in `pubspec.yaml`.

### 4. Firebase Setup

#### Option A: Use Existing Configuration (Recommended for Development)
The project includes a pre-configured Firebase setup in `lib/firebase_options.dart`. This is suitable for development and testing.

#### Option B: Set Up Your Own Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing one
3. Enable Firestore Database
4. Add your platforms (Web, Android, iOS as needed)
5. Download configuration files:
   - Web: Configuration is in `lib/firebase_options.dart`
   - Android: `google-services.json` goes in `android/app/`
   - iOS: `GoogleService-Info.plist` goes in `ios/Runner/`

#### Firestore Database Structure
Create these collections in your Firestore:

```
payments_confirmations/
├── document_id (auto-generated)
│   ├── applicationNumber: string
│   ├── billNumber: string  
│   ├── createdAt: string
│   ├── createdBy: string
│   ├── currency: string
│   ├── hasPopup: boolean
│   ├── paidAmount: number
│   ├── source: string
│   ├── success: boolean
│   └── testMessage: string (optional)
```

## Running the Application

### Web Development
```bash
# Run in debug mode
flutter run -d chrome

# Run in release mode
flutter run -d chrome --release

# Build for production
flutter build web --release
```

### Android Development
```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run -d android

# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS Development (macOS only)
```bash
# Run on iOS simulator
flutter run -d ios

# Build for iOS
flutter build ios --release
```

### Desktop Development

#### Windows
```bash
# Run Windows app
flutter run -d windows

# Build Windows app
flutter build windows --release
```

#### macOS
```bash
# Run macOS app
flutter run -d macos

# Build macOS app
flutter build macos --release
```

#### Linux
```bash
# Run Linux app
flutter run -d linux

# Build Linux app
flutter build linux --release
```

## Development Workflow

### 1. Code Quality

#### Linting
```bash
# Analyze code for issues
flutter analyze

# Fix common issues automatically
dart fix --apply
```

#### Formatting
```bash
# Format all Dart files
dart format .
```

### 2. Testing

#### Run Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

#### Widget Testing
The project includes widget tests in the `test/` directory. Add new tests for:
- UI component behavior
- Language switching functionality
- Payment filtering logic

### 3. Localization Development

#### Adding New Translations
1. Edit translation files:
   - `i18n/en-US.json` for English
   - `i18n/km-KM.json` for Khmer

2. Use translations in code:
   ```dart
   // Method 1: Using tr() extension
   Text('payment_confirmations'.tr())
   
   // Method 2: Using OmniText widget (recommended)
   OmniText(text: 'payment_confirmations')
   ```

3. Regenerate localization files:
   ```bash
   flutter pub get
   # Restart the app to see changes
   ```

#### Testing Translations
1. Use the language toggle button in the app
2. Verify both English and Khmer text display correctly
3. Check font rendering for Khmer characters

### 4. Firebase Development

#### Local Firestore Emulator (Optional)
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Start Firestore emulator
firebase emulators:start --only firestore
```

#### Testing Firebase Connection
1. Check Firebase connection status in the app header
2. Add test payment data through Firebase Console
3. Verify real-time updates in the app

## Debugging

### Flutter Inspector
Use Flutter Inspector in your IDE to:
- Examine widget tree
- Debug layout issues
- Monitor performance

### Common Debug Commands
```bash
# Enable debug logging
flutter run --verbose

# Debug with specific device
flutter run -d chrome --debug

# Profile performance
flutter run --profile

# Debug network issues
flutter run --enable-impeller  # For performance debugging
```

### Platform-Specific Debugging

#### Web Debugging
- Use Chrome DevTools for web debugging
- Check Console for JavaScript errors
- Monitor Network tab for Firebase requests

#### Mobile Debugging
- Use device/emulator logs
- Android: `flutter logs` or `adb logcat`
- iOS: Use Xcode console

## Build and Deployment

### Web Deployment (Firebase Hosting)

#### Manual Deployment
```bash
# Build the web app
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

#### Automatic Deployment
The project includes GitHub Actions for automatic deployment:
- Push to `main` branch triggers production deployment
- Pull requests create preview deployments

### Mobile App Deployment

#### Android (Google Play Store)
```bash
# Build App Bundle
flutter build appbundle --release

# The generated AAB file will be at:
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS (App Store)
```bash
# Build iOS app
flutter build ios --release

# Use Xcode to upload to App Store Connect
```

## Environment Configuration

### Development Environment Variables
Create a `.env` file (not committed to repo) for local development:
```env
FIREBASE_API_KEY=your_development_api_key
FIREBASE_PROJECT_ID=your_development_project_id
```

### Production Configuration
Production settings are managed through:
- `lib/firebase_options.dart` for Firebase
- GitHub Secrets for CI/CD
- Platform-specific configuration files

## Troubleshooting

### Common Issues

#### Flutter Doctor Issues
```bash
# Update Flutter
flutter upgrade

# Clean and reinstall dependencies
flutter clean
flutter pub get

# Reset Flutter configuration
flutter config --clear-features
```

#### Firebase Connection Issues
1. Verify internet connection
2. Check Firebase project status
3. Verify API keys and configuration
4. Clear app data and restart

#### Platform-Specific Issues

##### Android
- Ensure Android SDK is properly installed
- Check Gradle version compatibility
- Verify `google-services.json` placement

##### iOS
- Update Xcode to latest version
- Run `pod install` in `ios/` directory
- Check iOS simulator version compatibility

##### Web
- Clear browser cache
- Check CORS settings for Firebase
- Verify web configuration in Firebase Console

### Getting Help

1. **Flutter Documentation**: [flutter.dev](https://flutter.dev/docs)
2. **Firebase Documentation**: [firebase.google.com/docs](https://firebase.google.com/docs)
3. **Issue Tracking**: Use GitHub Issues for project-specific problems
4. **Community**: Flutter Discord, Stack Overflow

## Best Practices

### Code Organization
- Follow the existing folder structure
- Keep related files together
- Use meaningful file and variable names
- Add comments for complex logic

### Git Workflow
1. Create feature branches from `main`
2. Make small, focused commits
3. Write descriptive commit messages
4. Test thoroughly before creating PR
5. Use GitHub Actions for CI/CD validation

### Performance
- Use `const` constructors where possible
- Implement efficient Firebase queries
- Optimize image and asset sizes
- Monitor memory usage during development

### Security
- Never commit sensitive data
- Use environment variables for configuration
- Follow Firebase security best practices
- Regularly update dependencies

## Next Steps

After completing the setup:

1. **Explore the Codebase**: Start with `lib/main.dart` and follow the app flow
2. **Run the App**: Test on your preferred platform
3. **Make a Small Change**: Try adding a new translation or UI element
4. **Read the Architecture**: Review `ARCHITECTURE.md` for deeper understanding
5. **Contribute**: Look for good first issues or propose new features

Happy coding! 🚀