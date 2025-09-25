# Architecture Documentation

## Overview

This Flutter application follows a clean, layered architecture designed for maintainability, scalability, and cross-platform compatibility. The app is built around a payment management system with Firebase backend integration and comprehensive internationalization support.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                        │
├─────────────────────────────────────────────────────────────────┤
│  Widgets & UI Components                                       │
│  - main.dart (App Entry & Routing)                            │
│  - payments_page.dart (Main Payment UI)                       │
│  - Custom Widgets (OmniText, etc.)                            │
└─────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Business Logic Layer                       │
├─────────────────────────────────────────────────────────────────┤
│  Services & State Management                                   │
│  - payment_service.dart (Payment Operations)                  │
│  - user_service.dart (User Management)                        │
│  - Language Management Utilities                               │
└─────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                               │
├─────────────────────────────────────────────────────────────────┤
│  Data Sources & Models                                         │
│  - Firebase Firestore                                          │
│  - PaymentConfirm Model                                        │
│  - Localization Files (i18n)                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Application Entry Point (`main.dart`)
- **Responsibility**: App initialization, Firebase setup, localization configuration
- **Key Features**:
  - Firebase initialization with platform-specific options
  - EasyLocalization setup for Khmer/English support
  - Material App configuration with theming
  - Route management and initial navigation

```dart
// Key initialization sequence
await EasyLocalization.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 2. Payment Management System

#### PaymentService (`payment_service.dart`)
- **Responsibility**: Firebase Firestore operations and data management
- **Key Methods**:
  - `getPaymentConfirmsStream()`: Real-time payment data
  - `getPaymentConfirmsBySuccessStream(bool success)`: Filter by status
  - `getPaymentConfirmsBySourceStream(String source)`: Filter by payment source
  - CRUD operations for payment confirmations

#### PaymentConfirm Model
- **Data Structure**: Represents payment confirmation entities
- **Firebase Integration**: Automatic serialization/deserialization
- **Fields**: ID, amounts, timestamps, status, metadata

### 3. User Interface Components

#### PaymentsPage (`payments_page.dart`)
- **Responsibility**: Main payment management interface
- **Features**:
  - Real-time data streaming with StreamBuilder
  - Filter functionality (All, Success, Failed, KHQR)
  - Firebase connection status monitoring
  - Language toggle integration
  - Pull-to-refresh capability

#### Custom Widget System

##### OmniText Widget (`widgets/omni_text.dart`)
- **Purpose**: Intelligent multilingual text rendering
- **Features**:
  - Automatic font selection (English vs Khmer fonts)
  - Proper line breaking for Khmer text
  - Translation integration with easy_localization
  - Consistent styling across languages

```dart
// Usage example
OmniText(
  text: 'payment_confirmations', // Key from i18n files
  size: 18,
  weight: FontWeight.bold,
)
```

## Data Flow Architecture

### 1. Real-Time Data Flow
```
Firebase Firestore → PaymentService → StreamBuilder → UI Components
                         ↓
                   Filter Logic → Filtered Stream → Updated UI
```

### 2. User Interaction Flow
```
User Action → UI Event → Service Method → Firebase Operation → Data Update → UI Refresh
```

### 3. Localization Flow
```
Language Selection → Context.setLocale() → Widget Rebuild → Text Translation → Font Update
```

## State Management Strategy

The application uses a **Stateful Widget + StreamBuilder** pattern:

- **Local State**: Managed within individual widgets using `setState()`
- **Global State**: Implicit through Firebase real-time streams
- **Language State**: Managed by EasyLocalization context

### Benefits:
- Simple and predictable state management
- Real-time updates without complex state synchronization
- Minimal boilerplate code
- Easy debugging and maintenance

## Cross-Platform Architecture

### Platform-Specific Configurations

#### Web Platform
- Firebase Web SDK configuration
- Progressive Web App capabilities
- Firebase Hosting deployment
- Responsive design for various screen sizes

#### Mobile Platforms (Android/iOS)
- Native Firebase SDK integration
- Platform-specific UI adaptations
- Device-specific font rendering for Khmer

#### Desktop Platforms (Windows/macOS/Linux)
- CMake build system integration
- Desktop-specific UI patterns
- Native window management
- File system access for local storage

### Build System Integration

#### Flutter/Dart Level
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  easy_localization: ^3.0.1
```

#### Platform Build Systems
- **Android**: Gradle build system
- **iOS**: Xcode project configuration  
- **Web**: Flutter Web build tools
- **Desktop**: CMake configuration files

## Internationalization Architecture

### Translation System
```
Translation Key → easy_localization → Language Detection → Font Selection → Rendered Text
```

### Language Support Matrix
| Feature | English (en-US) | Khmer (km-KM) |
|---------|----------------|---------------|
| UI Text | ✅ Default | ✅ Complete |
| Font Support | ✅ System | ✅ Custom Khmer |
| Date Formatting | ✅ Standard | ✅ Localized |
| Number Formatting | ✅ Standard | ✅ Localized |

### Font Management Strategy
- **English**: Uses system default fonts for optimal performance
- **Khmer**: Uses specialized Khmer fonts for proper text rendering
- **Automatic Selection**: OmniText widget automatically selects appropriate fonts
- **Performance**: Font loading optimized for each platform

## Security Architecture

### Firebase Security
- Firestore security rules (configured in Firebase Console)
- Authentication integration points (ready for implementation)
- API key configuration through environment-specific files

### Data Protection
- Client-side data validation
- Secure Firebase configuration
- No sensitive data hardcoded in source

## Performance Considerations

### Firebase Optimization
- Efficient query patterns with proper indexing
- Stream subscription management to prevent memory leaks
- Pagination support for large datasets

### UI Performance
- Efficient widget rebuilding with StreamBuilder
- Lazy loading for payment lists
- Image and resource optimization

### Build Optimization
- Platform-specific asset bundling
- Code splitting for web builds
- AOT compilation for release builds

## Testing Architecture

### Testing Levels
1. **Unit Tests**: Business logic and services
2. **Widget Tests**: UI component behavior
3. **Integration Tests**: End-to-end user flows

### Testable Components
- PaymentService methods
- Data model serialization
- Widget rendering with different languages
- Navigation and routing

## Future Architecture Considerations

### Scalability
- Microservices integration points
- Caching layer implementation
- Advanced state management (if needed)

### Feature Extensions
- User authentication system
- Push notification infrastructure
- Offline data synchronization
- Advanced analytics integration

### Platform Extensions
- Wear OS support
- TV platform compatibility  
- Desktop notification systems
- Native platform integrations

## Development Guidelines

### Code Organization
- Feature-based folder structure
- Separation of concerns
- Consistent naming conventions
- Documentation requirements

### Performance Guidelines
- Efficient widget building
- Proper resource disposal
- Memory management best practices
- Platform-specific optimizations

### Maintenance Guidelines
- Regular dependency updates
- Security patch management
- Performance monitoring
- User feedback integration