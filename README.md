# Hidayah - Comprehensive Islamic Learning Application 📖🕌

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.8.0+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Educational-green)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-success)

</div>

A feature-rich, cross-platform Islamic learning application built with Flutter, featuring a premium **iOS 26 Liquid Glass UI** design. Hidayah provides an all-in-one platform for Quran reading, Hadith study, prayer times, Islamic education, and spiritual growth tools.

---

## 📑 Table of Contents

- [Highlights](#-highlights)
- [Screenshots](#-screenshots)
- [Features](#-features)
- [Packages Used](#-packages-used)
- [Getting Started](#-getting-started)
- [App Structure](#-app-structure)
- [Liquid Glass UI Design](#-liquid-glass-ui-design)
- [Main Sections](#-main-sections)
- [Development Notes](#-development-notes)
- [Assets Structure](#-assets-structure)
- [Key Technical Features](#-key-technical-features)
- [Download & Distribution](#-download--distribution)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Highlights

🕋 **Complete Islamic Companion** - Everything you need for Islamic learning in one beautiful app  
📖 **Full Quran** - All 114 Surahs with audio recitation by multiple Qaris  
📚 **Authentic Hadith** - Comprehensive collections from renowned scholars  
🕌 **Prayer Times** - GPS-based accurate Salah timings with notifications  
🧭 **Qibla Finder** - Real-time compass for precise direction to Mecca  
🎨 **Premium UI** - Stunning iOS 26 Liquid Glass design with smooth animations  
🌍 **Multilingual** - Full support for English, Arabic, Urdu, and Bahasa Indonesia  
🆓 **100% Free** - No ads, no paywalls, all features available to everyone  

---

## 📸 Screenshots

> *Screenshots showcasing the beautiful Liquid Glass UI and comprehensive features will be added here.*

**Main Features Preview:**
- Home Dashboard with Prayer Times
- Quran Reading with Audio Player
- Hadith Collections Browser
- Qibla Finder with Real-time Compass
- Tajweed Lessons Interface
- Profile & Statistics Dashboard
- Kids Learning Modules
- Dua Collections & Tasbih Counter

---

## ✨ Features

### 📖 Quran Features

- **Complete Quran Access** - Browse all 114 Surahs with Arabic text using the `quran: ^1.4.1` package
- **Multi-Reciter Audio Player** - Listen to renowned Qaris with adjustable playback speed (0.5x to 2.0x)
- **Multilingual Translations** - Translations in English, Urdu, Bahasa Indonesia, and Arabic
- **Memorization Tools** - Track memorization progress with proficiency ratings and spaced repetition
- **Bookmarking & Progress** - Save verses, track reading progress, and resume where you left off
- **Manzil Recitation** - Access specific Surahs traditionally recited for protection
- **Quran Flashes** - Quick verse insights and daily reminders
- **Full Surah Player** - Continuous playback of complete Surahs

### 🎓 Learning & Education

- **Tajweed Mastery Lessons** - Interactive lessons covering essential Tajweed rules with detailed explanations
- **Hadith Collections** - Comprehensive Hadith database with multiple scholars and books using `dorar_hadith: ^0.2.0`
- **Islamic Books** - Access to Islamic literature and educational resources by chapter
- **Kids Learning Modules** - Child-friendly Islamic education content with interactive lessons
- **Islamic Stories** - Inspiring stories from Islamic history and prophetic traditions
- **99 Names of Allah** - Learn and explore the beautiful names and attributes of Allah

### 🕌 Prayer & Worship Tools

- **Prayer Times** - Accurate Salah timings based on your location using `adhan: ^2.0.0`
- **Qibla Finder** - Real-time compass pointing to the Kaaba using `flutter_compass: ^0.8.0`
- **Digital Tasbih** - Electronic counter for Dhikr and remembrance
- **Dua Collections** - Comprehensive collection of daily prayers and supplications
- **Hijri Calendar** - Islamic calendar integration using `hijri: ^3.0.0`
- **Zakat Calculator** - Calculate Zakat obligations with precision

### 🏆 Tracking & Achievements

- **Daily Goals & Streaks** - Set study goals and maintain learning streaks
- **Achievement System** - Unlock badges and achievements as you progress
- **Progress Analytics** - Detailed statistics on reading, memorization, and learning
- **Prayer Notifications** - Smart reminders for Salah times using `flutter_local_notifications: ^17.2.3`

### UI/UX Features

- **🎨 iOS 26 Liquid Glass UI** - Premium translucent, blurred glass aesthetic
- **🌓 Glass Style Options** - Choose between Clear or Tinted glass themes
- **📱 Responsive Design** - Beautiful layouts optimized for all screen sizes
- **✨ Smooth Animations** - Fluid transitions and interactive elements
- **🎯 Intuitive Navigation** - Easy-to-use bottom navigation with 4 main sections

## 📦 Packages Used

### Core Islamic Content
- **`quran: ^1.4.1`** - Source for all Arabic text, Surah names, and verse data
- **`dorar_hadith: ^0.2.0`** - Comprehensive Hadith collections and Islamic texts
- **`adhan: ^2.0.0`** - Accurate prayer time calculations
- **`hijri: ^3.0.0`** - Hijri calendar conversion and Islamic dates

### State Management & Storage
- **`provider: ^6.1.1`** - State management solution
- **`hive: ^2.2.3`** & **`hive_flutter: ^1.1.0`** - Local NoSQL database for user data
- **`shared_preferences: ^2.2.2`** - User preferences and settings
- **`path_provider: ^2.1.2`** - File system paths for storing data

### Audio & Media
- **`just_audio: ^0.9.36`** - Audio playback for Quran recitations
- **`audio_session: ^0.1.18`** - Audio session management

### Location & Navigation
- **`geolocator: ^10.1.0`** - Device location for prayer times
- **`geocoding: ^2.1.1`** - Reverse geocoding for location names
- **`flutter_compass: ^0.8.0`** - Compass functionality for Qibla direction

### UI/UX Components
- **`google_fonts: ^6.1.0`** - Beautiful typography with Google Fonts
- **`flutter_svg: ^2.0.9`** - SVG image support
- **`flutter_islamic_icons: ^1.0.2`** - Islamic iconography
- **`flutter_staggered_animations: ^1.1.1`** - Smooth staggered animations
- **`shimmer: ^3.0.0`** - Shimmer loading effects

### Utilities
- **`intl: ^0.19.0`** - Internationalization and date formatting
- **`url_launcher: ^6.2.4`** - Launch external URLs and apps
- **`share_plus: ^12.0.1`** - Share content functionality
- **`translator: ^1.0.0`** - Translation services

### Notifications
- **`flutter_local_notifications: ^17.2.3`** - Local push notifications for prayer times
- **`timezone: ^0.9.2`** - Timezone support for notifications
- **`flutter_native_timezone: ^2.0.0`** - Native device timezone

### Monetization
- **`in_app_purchase: ^3.1.13`** - Donation feature (simulated IAP)

### Development Tools
- **`hive_generator: ^2.0.1`** - Code generation for Hive models
- **`build_runner: ^2.4.8`** - Build system for code generation
- **`flutter_launcher_icons: ^0.13.1`** - Automated app icon generation

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: 3.8.0 or higher (included with Flutter)
- **Platform Requirements**:
  - iOS: Xcode 14+ (for iOS development)
  - Android: Android Studio with SDK 21+ (for Android development)
- **Location Services**: Required for prayer times and Qibla finder
- **Internet Connection**: Required for initial audio downloads and translations

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd i_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate required files (for Hive models):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Generate app icons (optional):**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### iOS
```bash
cd ios
pod install
cd ..
flutter run
```

#### Android
Ensure you have accepted Android licenses:
```bash
flutter doctor --android-licenses
flutter run
```

### First Launch

On the first launch, you'll see a welcome screen where you can:
- Select your preferred language (English, Urdu, Bahasa Indonesia, or Arabic)
- Learn about the app's features
- Get started with your Quran learning journey

## 📱 App Structure

```
lib/
├── constants/          # App-wide constants and themes
│   ├── app_constants.dart
│   ├── app_theme.dart
│   └── colors.dart
├── models/            # Data models (Hive)
│   ├── user_progress.dart
│   ├── user_progress.g.dart (generated)
│   └── bookmarks.dart
├── providers/         # State management (Provider)
│   └── app_provider.dart
├── screens/           # All app screens
│   ├── welcome_screen.dart
│   ├── home_screen.dart
│   ├── quran_reading_screen.dart
│   ├── surah_detail_screen.dart
│   ├── audio_player_screen.dart
│   ├── full_surah_player_screen.dart
│   ├── manzil_screen.dart
│   ├── quran_flashes_screen.dart
│   ├── tajweed_lessons_screen.dart
│   ├── tajweed_lesson_detail_screen.dart
│   ├── memorization_screen.dart
│   ├── hadith_books_screen.dart
│   ├── hadith_collection_screen.dart
│   ├── hadith_scholars_screen.dart
│   ├── book_chapters_screen.dart
│   ├── islamic_stories_screen.dart
│   ├── kids_learning_screen.dart
│   ├── kids_modules/     # Children's learning modules
│   ├── names_of_allah_screen.dart
│   ├── dua_screen.dart
│   ├── tasbih_screen.dart
│   ├── qibla_screen.dart
│   ├── zakat_calculator_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── donation_screen.dart
│   └── support_app_screen.dart
├── widgets/           # Reusable UI components
│   ├── glass_card.dart
│   ├── custom_app_bar.dart
│   ├── prayer_time_card.dart
│   └── loading_shimmer.dart
├── services/          # Business logic and external services
│   └── notification_service.dart
├── utils/             # Helper functions and utilities
└── main.dart          # App entry point
```

## 🎨 Liquid Glass UI Design

The app features a premium **iOS 26 Liquid Glass aesthetic** with:

- **Translucent Cards** - Frosted glass effect using `BackdropFilter`
- **Rounded Elements** - Deeply rounded corners (24px radius)
- **Gradient Backgrounds** - Rich, immersive color gradients
- **Subtle Animations** - Smooth scale and fade transitions
- **Glass Styles** - User-selectable Clear or Tinted glass effects

### Color Palette

- **Primary Gold**: `#D4AF37` - Accent and highlights
- **Dark Background**: `#0A0E27` to `#16213E` gradient
- **Text Light**: `#F5F5F5` - Primary text
- **Glass Effects**: Semi-transparent overlays with blur

## 📚 Main Sections

### 1. 📖 Quran & Recitation
- **Quran Reading**: Browse all 114 Surahs with Arabic text and translations
- **Audio Player**: Multi-reciter support with speed control and repeat options
- **Full Surah Player**: Continuous playback of complete Surahs
- **Manzil**: Access protective verses organized by traditional groupings
- **Quran Flashes**: Quick daily verse insights and reminders
- **Memorization**: Track progress with proficiency ratings and review schedules
- **Bookmarks**: Save verses and resume reading from where you left off

### 2. 📚 Hadith & Islamic Knowledge
- **Hadith Collections**: Browse authentic Hadiths from multiple scholars
- **Hadith Books**: Access organized Hadith books by category
- **Islamic Books**: Read classical and contemporary Islamic literature
- **Islamic Stories**: Inspiring narratives from Islamic history
- **99 Names of Allah**: Learn the beautiful names and attributes of Allah
- **Kids Learning**: Child-friendly modules with interactive Islamic education

### 3. 🕌 Prayer & Worship
- **Prayer Times**: Accurate Salah timings based on GPS location
- **Qibla Finder**: Real-time compass pointing to Mecca
- **Digital Tasbih**: Electronic counter for Dhikr and Tasbeeh
- **Dua Collections**: Comprehensive supplications for daily life
- **Hijri Calendar**: Islamic calendar with important dates
- **Zakat Calculator**: Calculate your Zakat obligations accurately

### 4. 🎓 Learning & Education
- **Tajweed Lessons**: Comprehensive Tajweed rules with examples
- **Tajweed Practice**: Interactive exercises for pronunciation mastery
- **Progress Tracking**: Monitor your learning journey with detailed analytics
- **Achievement System**: Earn badges and unlock milestones

### 5. 👤 Profile & Settings
- **Study Statistics**: View reading hours, streaks, and progress
- **Achievement Badges**: Unlock rewards as you learn
- **Daily Goals**: Set and track personal study targets
- **Language Preferences**: Choose from 4 interface languages
- **Glass Style Themes**: Customize the UI appearance
- **Notification Settings**: Configure prayer time reminders
- **Support the App**: Voluntary donation options

## 🔧 Development Notes

### Location Permissions

The app requires location permissions for:
- **Prayer Times**: GPS-based calculation for accurate Salah timings
- **Qibla Direction**: Real-time compass orientation

Configure permissions in:
- **iOS**: `ios/Runner/Info.plist` - Location usage descriptions
- **Android**: `android/app/src/main/AndroidManifest.xml` - Location permissions

### Notification Setup

Prayer time notifications require platform-specific configuration:
- **iOS**: Enable push notifications capability in Xcode
- **Android**: Configure notification channels in `AndroidManifest.xml`

### Audio Sources

The app uses online audio sources for Quran recitations:
- API endpoints configured in `app_constants.dart`
- Multiple Qari options with different recitation styles
- Supports verse-by-verse and full Surah playback

### Data Storage

The app uses a multi-layer storage approach:
- **Hive**: NoSQL database for user progress, bookmarks, and memorization data
- **SharedPreferences**: User settings and preferences
- **Path Provider**: File system for audio caching

### Building for Production

Generate release builds:

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### Code Generation

After modifying Hive models, regenerate type adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## � Assets Structure

The app uses organized asset folders:

```
assets/
├── audio/
│   ├── tajweed/        # Tajweed lesson audio files
│   └── qaris/          # Quran recitation audio (cached)
├── images/             # App images and illustrations
├── data/               # Local JSON data files
└── books/              # Islamic book resources
```

## 🔑 Key Technical Features

### State Management
- **Provider Pattern**: Centralized app state management
- **Hive Database**: Fast, lightweight NoSQL storage
- **Real-time Updates**: Reactive UI updates across screens

### Performance Optimizations
- **Lazy Loading**: Efficient loading of Quran text and audio
- **Shimmer Effects**: Smooth loading placeholders
- **Staggered Animations**: Optimized list animations
- **Audio Caching**: Local storage for frequently played recitations

### Accessibility
- **Multiple Languages**: Full RTL support for Arabic and Urdu
- **Font Scaling**: Adjustable text sizes
- **High Contrast**: Glass UI with readable color schemes
- **Audio Support**: Complete audio recitation for all content

## �� Free & Ad-Free

Hidayah is completely **free and ad-free**. The app is supported by voluntary donations through the "Support the App" feature. Donations do not unlock any additional features - all content remains accessible to everyone.

## � Download & Distribution

### Version Information
- **Current Version**: 1.0.0+1
- **Minimum Android SDK**: 21 (Android 5.0 Lollipop)
- **Minimum iOS Version**: 12.0

### Build Outputs
- Android APK: `build/app/outputs/flutter-apk/app-release.apk`
- Android App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- iOS Archive: Generated through Xcode

## 📄 License

### Open Source with Attribution

This project is open source and available for anyone to use, modify, and distribute for educational and non-commercial purposes. However, please note the following important requirements:

#### ⚠️ Required Modifications for App Store Publishing

**This app is already published on Google Play Store and Apple App Store.** If you want to publish your own version, you **MUST** make the following changes:

1. **Change the App Logo/Icon** 
   - Create your own unique app icon
   - Do not use the original "Hidayah" branding
   - Update: `assets/logo.png` and run `flutter pub run flutter_launcher_icons`

2. **Modify the UI Design**
   - Customize colors, themes, and visual elements
   - Create your own distinct visual identity
   - Ensure your design differs from the published version

3. **Change App Name & Bundle Identifier**
   - Use a different app name in `pubspec.yaml`
   - Change the package name/bundle identifier:
     - iOS: Modify bundle identifier in Xcode
     - Android: Update `applicationId` in `android/app/build.gradle`

4. **Update Branding Elements**
   - Replace all branding assets in `assets/images/`
   - Modify splash screens and launch images
   - Update app metadata and descriptions

#### ✅ What You Can Do

- ✓ Use the source code for learning and educational purposes
- ✓ Fork and modify the codebase for your own projects
- ✓ Use the code as a reference for your own Islamic apps
- ✓ Contribute improvements back to this repository
- ✓ Deploy with your own unique branding and identity

#### ❌ What You Cannot Do

- ✗ Publish to app stores using the original "Hidayah" name and branding
- ✗ Copy the exact UI design and claim it as your own
- ✗ Use the original logo and assets in your published version
- ✗ Violate Google Play Store and Apple App Store policies regarding duplicate apps

#### 📜 Attribution

If you use this code, please provide attribution by:
- Mentioning this repository in your app's "About" or "Credits" section
- Keeping a reference to the original project in your documentation

This ensures compliance with app store policies and respects the original published application while allowing the community to benefit from the open-source code.

## 🤝 Contributing

While this is primarily an educational project, contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Areas for Contribution
- Translation improvements
- UI/UX enhancements
- Bug fixes
- Performance optimizations
- Documentation updates

## 📞 Support & Contact

For issues, questions, or suggestions:
- Create an issue in the repository
- Refer to Flutter documentation: [flutter.dev](https://flutter.dev)
- Package documentation on [pub.dev](https://pub.dev)

## 🌟 Acknowledgments

- **Quran Package**: Thanks to the maintainers of the `quran` package
- **Hadith Package**: `dorar_hadith` for comprehensive Hadith collections
- **Flutter Community**: For excellent packages and support
- **Islamic Scholars**: For making authentic knowledge accessible

---

<div align="center">

**بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ**

*"Read! In the Name of your Lord, Who created"* - **Surah Al-Alaq (96:1)**

**May this app be beneficial in your journey of learning and understanding the Quran and Islamic teachings. 🌙**

</div>
