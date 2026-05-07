# 🥗 MacroMind

> An AI-powered calorie tracking and weight loss mobile application built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-GPT--3.5-412991?style=for-the-badge&logo=openai&logoColor=white)
![Google](https://img.shields.io/badge/Google_Sign--In-4285F4?style=for-the-badge&logo=google&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=for-the-badge)

---

## 📱 About

**MacroMind** is a Flutter-based Android application that helps users track their daily calorie intake and monitor their weight loss journey. What makes MacroMind unique is its **AI-powered calorie recommendation system** — instead of using generic calorie targets, it analyzes the user's physical profile (BMR, TDEE, activity level) and uses **OpenAI GPT** to provide a personalized daily calorie goal with a detailed explanation.

All data is stored **locally on the device** — no cloud backend required.

---

## ✨ Features

- 🔐 **User Authentication** — Register/login with email & password or **Google Sign-In (Gmail)**
- 🤖 **AI Calorie Recommendation** — OpenAI GPT analyzes BMR, TDEE, and goals to recommend personalized daily calories
- 🎯 **Smart Goal Setup** — Enter weight, height, age, sex, and activity level for accurate calculations
- 🍎 **Food Logging** — Search 40+ built-in foods, log meals with custom serving sizes
- 📊 **Visual Dashboard** — Circular calorie ring with color-coded progress and stat boxes
- ⚖️ **Weight Tracking** — Log weight entries and visualize progress with a line chart
- 📈 **Progress Screen** — Track weight lost, remaining, and goal percentage
- ⚙️ **Goal Settings** — Edit your goal anytime with instant budget recalculation
- 💾 **Offline First** — All data persists locally using SharedPreferences
- 🔒 **Safe Budget Validation** — App warns and blocks goals that are too aggressive (under 800 kcal/day)

---


## 🤖 AI Integration

MacroMind uses **OpenAI GPT-3.5-turbo** to provide personalized calorie recommendations.

### How it works:
1. User enters physical details (weight, height, age, sex, activity level, timeline)
2. App calculates **BMR** using the Mifflin-St Jeor equation
3. App calculates **TDEE** using activity multipliers
4. All data is sent to OpenAI API
5. GPT returns a **personalized calorie recommendation** with:
   - Recommended daily calories
   - Explanation of why this amount was chosen
   - A pro tip for reaching the goal safely
   - Safety warning if the goal is too aggressive

### Calorie Formula:
```
BMR (Male)    = (10 × weight) + (6.25 × height) - (5 × age) + 5
BMR (Female)  = (10 × weight) + (6.25 × height) - (5 × age) - 161
TDEE          = BMR × Activity Multiplier
Daily Deficit = (Weight to Lose × 7,700) ÷ Timeline in Days
Daily Budget  = AI Recommended Calories - Daily Deficit
```

### Activity Multipliers:
| Level | Multiplier | Description |
|---|---|---|
| Sedentary | 1.2 | Little or no exercise |
| Lightly Active | 1.375 | Light exercise 1-3 days/week |
| Moderately Active | 1.55 | Moderate exercise 3-5 days/week |
| Very Active | 1.725 | Hard exercise 6-7 days/week |
| Extra Active | 1.9 | Very hard exercise & physical job |

---

## 🔐 Authentication

MacroMind supports two authentication methods:

### Email & Password
- Registered and stored locally on device
- Password is hashed before storage
- No internet required

### Google Sign-In
- Uses `google_sign_in` Flutter package
- Requires internet connection
- OAuth 2.0 via Google Cloud Console
- Automatically registers new Google users on first sign-in
- Existing Google users are logged in directly

---

## 🗂️ Project Structure

```
lib/
├── main.dart                         # App entry point & routing logic
├── models/
│   ├── food_entry.dart               # Food log data model
│   ├── user_goal.dart                # Goal model with BMR/TDEE calculations
│   ├── user.dart                     # User account model
│   └── weight_log.dart              # Weight entry model
├── screens/
│   ├── login_screen.dart             # Login with email or Google Sign-In
│   ├── register_screen.dart          # Email & password registration
│   ├── goal_setup_screen.dart        # Physical details & timeline input
│   ├── ai_recommendation_screen.dart # AI calorie recommendation display
│   ├── dashboard_screen.dart         # Main screen with calorie ring
│   ├── food_search_screen.dart       # Food search and logging
│   ├── food_log_screen.dart          # Today's food log list
│   ├── progress_screen.dart          # Weight progress and chart
│   └── goal_settings_screen.dart     # Edit goal settings
├── services/
│   ├── storage_service.dart          # All SharedPreferences read/write
│   ├── openai_service.dart           # OpenAI GPT API integration
│   └── google_auth_service.dart      # Google Sign-In logic
└── data/
    └── food_database.dart            # Built-in food database (40+ foods)
```

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| Flutter | 3.x | UI framework |
| Dart | 3.x | Programming language |
| shared_preferences | ^2.2.2 | Local data storage |
| fl_chart | ^0.68.0 | Weight progress line chart |
| uuid | ^4.0.0 | Unique IDs for food entries |
| http | ^1.2.0 | OpenAI API network requests |
| google_sign_in | ^6.2.1 | Google OAuth 2.0 authentication |
| OpenAI GPT-3.5-turbo | API | AI calorie recommendation engine |
| Material Design 3 | Built-in | UI components and theming |

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or higher)
- [Android Studio](https://developer.android.com/studio) with Android emulator
- [Git](https://git-scm.com/)
- [OpenAI API Key](https://platform.openai.com/api-keys)
- [Google Cloud Console Account](https://console.cloud.google.com/) for Google Sign-In

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/DrewLearn11/macro_mind.git
cd macro_mind
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Add your OpenAI API Key**

Open `lib/services/openai_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
```
With your actual key:
```dart
static const String _apiKey = 'sk-xxxxxxxxxxxxxxxxxxxxxxxx';
```

**4. Add your Google Web Client ID**

Open `lib/services/google_auth_service.dart` and replace:
```dart
static const String _webClientId = 'YOUR_WEB_CLIENT_ID_HERE';
```
With your actual Web Client ID from Google Cloud Console.

**5. Run the app**
```bash
flutter run
```

**6. Build APK for physical device**
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

## ⚙️ Google Sign-In Setup

To enable Google Sign-In you need to configure Google Cloud Console:

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project
3. Enable **Google People API**
4. Go to **Google Auth Platform → Get Started**
5. Configure the OAuth consent screen
6. Create an **Android OAuth 2.0 Client ID**:
   - Package name: `com.example.macro_mind`
   - SHA-1 fingerprint: run `cd android && .\gradlew signingReport`
7. Create a **Web OAuth 2.0 Client ID**
8. Copy the **Web Client ID** into `lib/services/google_auth_service.dart`

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  fl_chart: ^0.68.0
  uuid: ^4.0.0
  http: ^1.2.0
  google_sign_in: ^6.2.1
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

---

## 🗺️ App Flow

```
App Launch
    │
    ├── Not logged in ──────────────→ Login Screen
    │                                      │
    │                         ┌────────────┴────────────┐
    │                         │                         │
    │                   Email/Password           Google Sign-In
    │                   Register Screen                 │
    │                         │                         │
    │                         └────────────┬────────────┘
    │                                      │
    ├── Logged in, no goal ────────→ Goal Setup Screen
    │                                      │
    │                            AI Recommendation Screen
    │                                      │
    └── Logged in, has goal ───────→ Dashboard Screen
                                          │
                       ┌──────────────────┼──────────────────┐
                       │                  │                   │
                 Food Search          Food Log           Progress
                 Screen               Screen             Screen
                                                              │
                                                       Goal Settings
                                                       Screen
```

---

## 📖 How to Use

### Step 1 — Login or Register
- Open the app → **Log In** with existing credentials
- Or tap **Register** to create a new account
- Or tap **Continue with Google** to sign in with Gmail

### Step 2 — Set Up Your Goal
- Enter **current weight, goal weight, height, age, sex, and activity level**
- Choose a **timeline** (1 Week to 6 Months)
- Tap **✨ Get AI Recommendation**

### Step 3 — Review AI Recommendation
- View your personalized **daily calorie target** from OpenAI GPT
- Check **BMR and TDEE** breakdown
- Read the **AI explanation and pro tip**
- Tap **Start My Journey** to save and proceed

### Step 4 — Log Food Daily
- From Dashboard tap **Add Food** (green FAB)
- Search for food and enter **grams eaten**
- Calories are calculated and added to your daily total

### Step 5 — Track Your Progress
- Tap **Progress** in the bottom navigation
- Tap **Log Weight** to record today's weight
- View your **progress bar, line chart, and weight history**

### Step 6 — Logout
- Tap the **logout icon** (top right of Dashboard)
- Login with a different account if needed

---

## 🤝 Contributing

1. **Fork** the repository
2. Create a new branch:
```bash
git checkout -b feature/your-feature-name
```
3. Commit your changes:
```bash
git commit -m "Add: your feature description"
```
4. Push to your branch:
```bash
git push origin feature/your-feature-name
```
5. Open a **Pull Request**

### Commit Message Convention
```
Add:    new feature
Fix:    bug fix
Update: change to existing feature
Remove: deleted something
Docs:   documentation changes only
```

---

## 🐛 Known Issues

- Password hashing uses a basic algorithm — not suitable for production
- Food database limited to 40+ hardcoded items (no external API)
- No cloud sync — data is device-specific only
- Google Sign-In requires internet connection
- OpenAI API requires internet and has usage costs (~$0.001 per request)

---

## 🔮 Future Improvements

- [ ] Firebase Authentication for cloud-based accounts
- [ ] Expanded food database with Open Food Facts API
- [ ] Meal categories (Breakfast, Lunch, Dinner, Snacks)
- [ ] Daily calorie history chart on Dashboard
- [ ] Dark mode support
- [ ] iOS support
- [ ] Barcode scanner for food logging
- [ ] Push notifications for daily reminders
- [ ] Export progress report as PDF

---

## 📄 License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2026 MacroMind

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 👤 Author

**DrewLearn11**
- GitHub: [@DrewLearn11](https://github.com/DrewLearn11)

---

<div align="center">
  Made with ❤️ using Flutter + OpenAI GPT
</div>