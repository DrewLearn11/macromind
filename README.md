🥗 MacroMind
A calorie tracking and weight loss mobile application built with Flutter.
 
 
 

📱 About
MacroMind is a Flutter-based Android application that helps users track their daily calorie intake and monitor their weight loss journey. Users can set a goal weight, choose a timeline, and the app automatically calculates their daily calorie budget using a scientifically-backed formula.
All data is stored locally on the device — no internet connection or cloud account required.
✨ Features
🔐 User Authentication — Register and login with email & password (stored locally)
🎯 Goal Setting — Set current weight, goal weight, and timeline (1 week to 3 months)
🍎 Food Logging — Search 40+ foods and log meals with custom serving sizes
📊 Dashboard — Circular calorie ring with real-time consumed/remaining/budget stats
⚖️ Weight Tracking — Log weight entries and visualize progress with a line chart
📈 Progress Screen — Track weight lost, remaining, and overall goal percentage
⚙️ Goal Settings — Edit your goal anytime with instant recalculation
💾 Offline First — All data persists locally using SharedPreferences
🖼️ Screenshots 

🧮 Calorie Formula
Total Calories to Burn  = (Current Weight - Goal Weight) × 7,700 kcal
Daily Deficit Needed    = Total Calories to Burn ÷ Timeline in Days
Daily Calorie Budget    = Maintenance Calories - Daily Deficit
Food Calories           = (Calories per 100g × Grams Eaten) ÷ 100
🗂️ Project Structure
lib/
├── main.dart                  # App entry point
├── models/
│   ├── food_entry.dart        # Food log data model
│   ├── user_goal.dart         # Goal data model with calorie calculations
│   ├── user.dart              # User account model
│   └── weight_log.dart        # Weight entry model
├── screens/
│   ├── login_screen.dart      # Login screen
│   ├── register_screen.dart   # Registration screen
│   ├── onboarding_screen.dart # First-time goal setup
│   ├── dashboard_screen.dart  # Main screen with calorie ring
│   ├── food_search_screen.dart# Food search and logging
│   ├── food_log_screen.dart   # Today's food log list
│   ├── progress_screen.dart   # Weight progress and chart
│   └── goal_settings_screen.dart # Edit goal settings
├── services/
│   └── storage_service.dart   # All SharedPreferences read/write logic
├── data/
│   └── food_database.dart     # Built-in food database (40+ foods)
└── widgets/
    ├── calorie_ring.dart      # Circular progress ring widget
    └── food_tile.dart         # Food list item widget
🛠️ Tech Stack
Technology	Version	Purpose
Flutter	3.x	UI framework
Dart	3.x	Programming language
shared_preferences	^2.2.2	Local data storage
fl_chart	^0.68.0	Weight progress chart
uuid	^4.0.0	Unique IDs for food entries
Material Design 3	Built-in	UI components


🚀 Getting Started
Prerequisites
Make sure you have the following installed:
Flutter SDK (3.x or higher)
Android Studio with Android emulator
Git
VS Code or Android Studio (IDE)
Installation
1. Clone the repository
git clone https://github.com/YOUR_USERNAME/macromind.git
cd macromind
2. Install dependencies
flutter pub get
3. Run the app on emulator
flutter run
4. Run on physical device
First enable USB Debugging on your phone:
Go to Settings → About Phone
Tap Build Number 7 times
Go back to Settings → Developer Options
Enable USB Debugging
Then connect your phone via USB and run:
flutter devices        # verify your device is detected
flutter run            # select your device
5. Build APK for installation
flutter build apk --release
APK will be at: build/app/outputs/flutter-apk/app-release.apk
📦 Dependencies
Add these to your pubspec.yaml:
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  fl_chart: ^0.68.0
  uuid: ^4.0.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
🗺️ App Flow
App Launch
    │
    ├── Not logged in ──────────→ Login Screen
    │                                  │
    │                            Register Screen
    │                                  │
    ├── Logged in, no goal ──────→ Onboarding Screen
    │                                  │
    └── Logged in, has goal ─────→ Dashboard Screen
                                       │
                    ┌──────────────────┼──────────────────┐
                    │                  │                   │
              Food Search         Food Log            Progress
              Screen              Screen              Screen
                    │
              Goal Settings
              Screen
📖 How to Use
Step 1 — Register
Open the app
Tap "Register" on the login screen
Enter your email and a password (min. 6 characters)
Tap "Create Account"
Step 2 — Set Your Goal
Enter your current weight (kg)
Enter your goal weight (kg)
Enter your daily maintenance calories (use 2000 if unsure)
Select a timeline (1 Week / 2 Weeks / 1 Month / 3 Months)
Tap "Get Started"
Step 3 — Log Food
From the Dashboard tap "Add Food"
Search for a food (e.g. "chicken")
Tap the + button
Enter how many grams you ate
Tap "Add Food"
Step 4 — Track Progress
Tap "Progress" in the bottom nav
Tap "Log Weight" to record today's weight
View your progress bar, chart, and weight history
🤝 Contributing
Contributions are welcome! Here's how:
Fork the repository
Create a new branch:
git checkout -b feature/your-feature-name
Make your changes and commit:
git commit -m "Add: your feature description"
Push to your branch:
git push origin feature/your-feature-name
Open a Pull Request
Commit Message Convention
Add:    new feature
Fix:    bug fix
Update: change to existing feature
Remove: deleted something
Docs:   documentation changes
🐛 Known Issues
Password hashing uses a basic algorithm — not suitable for production
Food database is limited to 40+ items (no API integration yet)
No cloud sync — data is device-specific
🔮 Future Improvements
[ ] Firebase Authentication for cloud accounts
[ ] Expanded food database with API (e.g. Open Food Facts)
[ ] BMR/TDEE calculator built into onboarding
[ ] Meal categories (Breakfast, Lunch, Dinner, Snacks)
[ ] Daily calorie history chart on Dashboard
[ ] Dark mode support
[ ] iOS support
📄 License
This project is licensed under the MIT License.
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
👤 Author
Mitch Andrew Palang
GitHub: DrewLearn11
<div align="center"> Made with ❤️ using Flutter </div>