# Payment Management Flutter App

A cross-platform Flutter application for managing and viewing payment confirmations with multilingual support (English and Khmer).

## 🚀 Features

### Core Features
- **Payment Management**: View and filter payment confirmations from Firebase Firestore
- **Multilingual Support**: Full localization in English and Khmer (Cambodian)
- **Firebase Integration**: Real-time data sync with Cloud Firestore
- **Cross-Platform**: Supports Web, Android, iOS, Windows, macOS, and Linux
- **Modern UI**: Material Design 3 with responsive layout

### Payment Features
- Real-time payment confirmation viewing
- Filter payments by status (All, Successful, Failed, KHQR)
- Payment details including amount, currency, source, and timestamps
- Firebase connection status indicator
- Pull-to-refresh functionality

### Internationalization
- **English (en-US)**: Primary language
- **Khmer (km-KM)**: Native Cambodian language support
- Custom font handling for proper Khmer text rendering
- Language toggle functionality

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── payments_page.dart        # Main payment management UI
├── payment_service.dart      # Firebase Firestore service layer
├── firebase_options.dart     # Firebase configuration
├── widgets/
│   └── omni_text.dart       # Custom multilingual text widget
├── constants/
│   ├── default_color.dart   # App color scheme
│   └── style.dart          # Text styles and constants
└── utils/
    └── helpers/
        └── language.dart    # Language management utilities
```

### Key Components

#### Payment Service (`payment_service.dart`)
- Handles Firebase Firestore operations
- Provides streaming data for real-time updates
- Supports filtering by payment status and source
- Models payment confirmation data

#### Multilingual Text Widget (`omni_text.dart`)
- Custom widget for handling English and Khmer text
- Automatic font selection based on language
- Proper line breaking for Khmer text
- Translation integration with easy_localization

#### Payment Management UI (`payments_page.dart`)
- Real-time payment list with filtering
- Firebase connection status monitoring
- Responsive card-based layout
- Language switching capability

## 🛠️ Technical Stack

### Frontend
- **Flutter 3.13.9+**: Cross-platform framework
- **Dart SDK**: >=3.0.6 <4.0.0
- **Material Design 3**: Modern UI components

### Backend & Services
- **Firebase Core**: Authentication and configuration
- **Cloud Firestore**: Real-time database
- **Firebase Hosting**: Web deployment

### Localization
- **easy_localization**: Internationalization framework
- **intl**: Date and number formatting

### Development Tools
- **flutter_lints**: Code quality and style enforcement
- **flutter_test**: Unit and widget testing framework

## 📱 Platform Support

The app supports all major platforms:
- **Web**: Progressive Web App with Firebase hosting
- **Mobile**: Android and iOS native apps
- **Desktop**: Windows, macOS, and Linux native applications

### Build Configurations
- **Android**: Native Android APK/AAB
- **iOS**: Native iOS IPA
- **Web**: Single Page Application deployed to Firebase Hosting
- **Windows**: Native Windows executable with CMake
- **macOS**: Native macOS app bundle
- **Linux**: Native Linux executable with CMake

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.13.9 or higher
- Firebase project setup
- Platform-specific development tools (Android Studio, Xcode, etc.)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vansaodai-ichi/untitled.git
   cd untitled
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Update `lib/firebase_options.dart` with your Firebase project settings
   - Ensure Firebase project has Firestore enabled

4. **Run the application**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d android
   
   # iOS (macOS only)
   flutter run -d ios
   
   # Desktop
   flutter run -d windows  # or macos/linux
   ```

### Building for Production

```bash
# Web build
flutter build web --release

# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release

# Desktop
flutter build windows --release  # or macos/linux
```

## 🌐 Deployment

### Firebase Hosting (Web)
The project is configured with GitHub Actions for automatic deployment:
- **Production**: Deploys to Firebase Hosting on pushes to `main`
- **Preview**: Creates preview deployments for pull requests

### CI/CD Pipeline
- Code analysis with `flutter analyze`
- Automated testing
- Multi-platform builds
- Firebase hosting deployment

## 📊 Data Model

### PaymentConfirm
```dart
class PaymentConfirm {
  final String id;
  final String applicationNumber;
  final String billNumber;
  final String createdAt;
  final String createdBy;
  final String currency;
  final bool hasPopup;
  final double paidAmount;
  final String source;        // e.g., "KHQR", "Card", etc.
  final bool success;
  final String? testMessage;
}
```

## 🌍 Localization

The app supports two languages with complete translations:

### Supported Languages
- **English (en-US)**: Default language
- **Khmer (km-KM)**: Cambodian language with proper font rendering

### Translation Files
- `i18n/en-US.json`: English translations
- `i18n/km-KM.json`: Khmer translations

### Custom Font Handling
- English text uses system default fonts
- Khmer text uses specialized Khmer fonts for proper rendering
- Automatic font selection based on current language

## 🎨 UI/UX Features

- **Material Design 3**: Modern, accessible design system
- **Responsive Layout**: Adapts to different screen sizes
- **Dark/Light Mode**: Follows system preferences
- **Smooth Animations**: Enhanced user experience
- **Pull-to-Refresh**: Real-time data updates
- **Loading States**: Clear feedback for async operations

## 🔧 Development

### Code Style
- Uses `flutter_lints` for consistent code quality
- Follows Flutter/Dart best practices
- Proper error handling and loading states

### Testing
- Widget tests for UI components
- Unit tests for business logic
- Integration tests for payment flows

### Performance Optimization
- Efficient Firebase Firestore queries
- Proper widget lifecycle management
- Optimized build configurations for each platform

## 📄 License

This project is configured as a private package and is not intended for publication to pub.dev.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

For major changes, please open an issue first to discuss what you would like to change.
