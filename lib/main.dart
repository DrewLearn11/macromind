import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user is already logged in
  final bool loggedIn = await StorageService.isLoggedIn();
  final goal = loggedIn ? await StorageService.loadGoal() : null;

  // Decide starting screen:
  // Not logged in        → LoginScreen
  // Logged in, no goal   → OnboardingScreen
  // Logged in, has goal  → DashboardScreen
  Widget startScreen;
  if (!loggedIn) {
    startScreen = const LoginScreen();
  } else if (goal == null) {
    startScreen = const OnboardingScreen();
  } else {
    startScreen = const DashboardScreen();
  }

  runApp(CalorieMateApp(startScreen: startScreen));
}

class CalorieMateApp extends StatelessWidget {
  final Widget startScreen;

  const CalorieMateApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalorieMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C896),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: startScreen,
    );
  }
}