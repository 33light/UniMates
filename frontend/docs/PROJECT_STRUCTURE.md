# 📁 Project Structure Guide

**Professional organization of the UniMates Flutter project**

## Root Level Organization

```
chatter/
├── 📁 lib/                      ← Main application source code
├── 📁 android/                  ← Android platform code
├── 📁 ios/                      ← iOS platform code
├── 📁 web/                      ← Web platform code
├── 📁 windows/                  ← Windows platform code
├── 📁 macos/                    ← macOS platform code
├── 📁 linux/                    ← Linux platform code
├── 📁 assets/                   ← Images, fonts, and other assets
├── 📁 test/                     ← Unit and widget tests
├── 📁 docs/                     ← Project documentation
├── 📁 .vscode/                  ← VS Code workspace settings
├── 📁 .idea/                    ← IntelliJ/Android Studio settings
├── pubspec.yaml                 ← Flutter dependencies and metadata
├── pubspec.lock                 ← Locked dependency versions
├── analysis_options.yaml        ← Dart linter configuration
├── .gitignore                   ← Git ignore rules
├── firebase.json                ← Firebase configuration
├── BUILD_AND_RUN.md             ← Build and run instructions
└── README.md                    ← Project overview
```

## Source Code (lib/) Organization

### ✅ Professional Clean Architecture Pattern

```
lib/
├── main.dart                    ← App entry point
├── firebase_options.dart        ← Firebase configuration
│
├── 🎨 theme/
│   └── app_theme.dart          ← Material Design 3 themes (light/dark)
│
├── ⚙️ constants/
│   └── app_constants.dart       ← Colors, strings, sizes (single source of truth)
│
├── 🛠️ utils/
│   └── app_utils.dart           ← Helper functions, validation, formatting
│
├── 📊 models/
│   └── app_models.dart          ← Data models and entities
│       ├── UniMatesUser
│       ├── Post
│       └── Comment
│
├── 🔌 services/
│   └── mock_api_service.dart    ← Business logic and API calls
│       ├── Authentication
│       ├── Posts CRUD
│       └── Comments & Likes
│
├── 🖥️ screens/
│   ├── auth.dart               ← Login/Signup screens
│   ├── home_screen.dart         ← Main navigation hub
│   ├── profile_screen.dart      ← User profile management
│   ├── marketplace_screen.dart  ← Marketplace placeholder
│   ├── messaging_screen.dart    ← Messaging placeholder
│   ├── lost_found_screen.dart   ← Lost & Found placeholder
│   └── community/               ← Community module screens
│       ├── community_feed.dart
│       ├── create_post.dart
│       └── post_detail.dart
│
└── 🧩 widgets/
    ├── post_card.dart           ← Reusable post component
    └── community/               ← Community-specific widgets
```

## Architecture Layers

### 1. **Presentation Layer** (screens/ + widgets/)
- UI screens and reusable widgets
- Material Design 3 components
- User interaction handling
- State management with FutureBuilder

### 2. **Business Logic Layer** (services/)
- MockApiService for API calls
- Data processing and validation
- Firebase integration hooks

### 3. **Data Layer** (models/)
- Data structures and entities
- Serialization/deserialization
- Type-safe models

### 4. **Foundation Layer** (theme/, constants/, utils/)
- Design system and theming
- App-wide constants
- Utility functions and helpers

## Key Design Principles

### ✅ Separation of Concerns
- Each layer has a specific responsibility
- Models don't know about UI
- UI doesn't know about API details

### ✅ DRY (Don't Repeat Yourself)
- Constants centralized in `constants/app_constants.dart`
- Shared utilities in `utils/app_utils.dart`
- Reusable widgets in `widgets/`

### ✅ Scalability
- Easy to add new modules (e.g., marketplace/, messaging/)
- Each module can have its own screens and widgets
- Services layer can be extended with new APIs

### ✅ Maintainability
- Clear folder structure
- Consistent naming conventions
- Type-safe with null safety
- Well-documented code

## Development Workflow

### Adding a New Feature
```
1. Define data model → lib/models/
2. Create service methods → lib/services/
3. Build screen/widget → lib/screens/ or lib/widgets/
4. Add constants if needed → lib/constants/
5. Test and iterate
```

### Adding a New Module (e.g., Marketplace Phase 3)
```
lib/screens/marketplace/
├── marketplace_feed.dart
├── product_detail.dart
├── create_listing.dart
└── ...
```

## File Naming Conventions

- **Directories:** snake_case (community/, lost_found/)
- **Files:** snake_case.dart (community_feed.dart, app_models.dart)
- **Classes:** PascalCase (CommunityFeed, AppTheme)
- **Constants:** camelCase (primaryColor, paddingMedium)
- **Functions:** camelCase (validateEmail, formatDate)

## Dependency Management

All dependencies managed in `pubspec.yaml`:
- flutter: Core framework
- firebase_auth: Authentication
- firebase_core: Firebase initialization
- google_sign_in: Google OAuth
- intl: Date/time formatting

## Clean Build

To completely clean the project:
```bash
flutter clean
rm -r build/
rm pubspec.lock
flutter pub get
```

The `/build` folder is automatically generated during build and is ignored by `.gitignore`.

## Documentation Structure

```
docs/
├── README.md                    ← Documentation index
├── PHASE_2.md                   ← Current phase details
├── TESTING.md                   ← 15 test scenarios
├── UNIMATES_PROJECT_PLAN.md     ← Full roadmap
├── QUICKSTART.md                ← Quick start guide
└── [other reference files]
```

## CI/CD Ready

✅ Project structure supports:
- Automated testing
- Code analysis (flutter analyze)
- Build automation
- Deployment pipelines

---

**Status:** ✅ Professional structure ready for development and scaling
