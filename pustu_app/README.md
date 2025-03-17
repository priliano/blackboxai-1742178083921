# PUSTU Queue App

A modern queue management system for Pusat Kesehatan Masyarakat Pembantu (PUSTU) built with Flutter.

## Features

### For Patients
- Register for a queue number
- Track queue status in real-time
- Receive notifications when their queue is called
- View queue history
- Submit feedback for services
- View feedback history

### For Staff (Petugas)
- Manage active queues
- Call next patient
- Skip queues
- View basic queue statistics

### For Administrators
- Comprehensive dashboard with statistics
- Manage all queues
- View and respond to feedback
- Access detailed analytics
- Monitor staff performance

### General Features
- Real-time updates
- Push notifications
- Dark/Light theme
- Offline support
- Multi-language support (planned)

## Architecture

The app follows a clean architecture pattern with the following layers:

```
lib/
├── constants/       # App-wide constants and configurations
├── models/         # Data models and DTOs
├── providers/      # State management using Provider
├── screens/        # UI screens organized by feature
├── services/       # Business logic and API services
├── utils/          # Utility functions and extensions
└── widgets/        # Reusable UI components
```

### State Management
- Uses Provider for state management
- Implements repository pattern for data access
- Follows SOLID principles

### API Integration
- RESTful API communication using Dio
- JWT authentication
- Automatic token refresh
- Error handling and retry logic

### Local Storage
- Secure storage for sensitive data
- SharedPreferences for app settings
- Offline data persistence

## Setup Instructions

1. **Prerequisites**
   ```bash
   flutter --version  # Ensure Flutter 3.0.0 or higher
   ```

2. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/pustu_app.git
   cd pustu_app
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure Environment**
   - Copy `.env.example` to `.env`
   - Update the values with your configuration

5. **Run the App**
   ```bash
   flutter run
   ```

## Development

### Code Generation
```bash
# Generate JSON serializers
flutter pub run build_runner build

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Project Structure

```
pustu_app/
├── android/          # Android-specific files
├── ios/             # iOS-specific files
├── lib/             # Dart source code
├── test/            # Test files
├── assets/          # Static assets
│   ├── images/      # Image assets
│   ├── icons/       # Icon assets
│   └── animations/  # Lottie animations
├── pubspec.yaml     # Project configuration
└── README.md        # Project documentation
```

## Dependencies

Major dependencies used in this project:

- **State Management**
  - provider: ^6.1.1

- **Network & API**
  - dio: ^5.4.0
  - connectivity_plus: ^5.0.2

- **Storage**
  - shared_preferences: ^2.2.2
  - flutter_secure_storage: ^9.0.0

- **UI Components**
  - google_fonts: ^6.1.0
  - flutter_rating_bar: ^4.0.1

- **Firebase Services**
  - firebase_messaging: ^14.7.10
  - firebase_analytics: ^10.7.4

See `pubspec.yaml` for a complete list of dependencies.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who participate in this project
