// onboarding_screen.dart
// This is the setup screen shown when the user opens the app for the first time.
// The user enters their weight, goal, and timeline here.
// Once done, their goal is saved and they're taken to the Dashboard.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/user_goal.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';
import '../models/weight_log.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// "StatefulWidget" means this screen CAN change — 
// for example when the user types in a field or selects a timeline.
// "_OnboardingScreenState" holds all the changeable data.
class _OnboardingScreenState extends State<OnboardingScreen> {

  // "_formKey" is used to validate the form before saving.
  // It checks if all required fields are filled correctly.
  final _formKey = GlobalKey<FormState>();

  // "TextEditingController" lets us READ what the user typed in a TextField.
  // We create one for each input field.
  final _currentWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  final _maintenanceCaloriesController = TextEditingController();

  // This holds the selected timeline in days.
  // Default is 30 days (1 month).
  int _selectedTimelineDays = 30;

  // This controls whether the save button shows a loading spinner.
  bool _isLoading = false;

  // These are the timeline options shown as buttons.
  // Each option has a label and a value in days.
  final List<Map<String, dynamic>> _timelineOptions = [
    {'label': '1 Week',   'days': 7},
    {'label': '2 Weeks',  'days': 14},
    {'label': '1 Month',  'days': 30},
    {'label': '3 Months', 'days': 90},
  ];

  // "dispose()" is called when the screen is removed from memory.
  // We MUST dispose controllers to free up memory — good practice!
  @override
  void dispose() {
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _maintenanceCaloriesController.dispose();
    super.dispose();
  }

  // This function runs when the user taps "Get Started"
  Future<void> _saveGoal() async {
    // Check if all fields are valid before saving
    if (!_formKey.currentState!.validate()) return;

    // Show loading spinner on the button
    setState(() => _isLoading = true);

    // Parse the text field values into numbers
    // "double.parse()" converts a String like "70.5" into a number 70.5
    final double currentWeight =
        double.parse(_currentWeightController.text.trim());
    final double goalWeight =
        double.parse(_goalWeightController.text.trim());
    final double maintenanceCalories =
        double.parse(_maintenanceCaloriesController.text.trim());

final UserGoal goal = UserGoal(
  currentWeight: currentWeight,
  goalWeight: goalWeight,
  height: 170.0,        // default
  age: 25,              // default
  sex: 'male',          // default
  activityLevel: 'sedentary', // default
  timelineInDays: _selectedTimelineDays,
  maintenanceCalories: maintenanceCalories,
  recommendedCalories: maintenanceCalories, // same as maintenance
);

    // Save the goal to SharedPreferences
    await StorageService.saveGoal(goal);

    // Also save the starting weight as the first weight log entry
await StorageService.addWeightLog(
  WeightLog(
    weight: currentWeight,
    loggedAt: DateTime.now(),
  ),
);
    // "mounted" checks if the screen is still active before navigating.
    // This prevents errors if the user closes the screen while saving.
    if (!mounted) return;

    // Navigate to Dashboard and remove Onboarding from the stack
    // "pushReplacement" means the user can't go BACK to Onboarding
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // "Scaffold" is the basic screen layout in Flutter.
      // It provides appBar, body, floatingActionButton, etc.
      backgroundColor: Colors.white,
      body: SafeArea(
        // "SafeArea" keeps content away from notches and status bars
        child: SingleChildScrollView(
          // "SingleChildScrollView" makes the screen scrollable
          // so the keyboard doesn't cover the input fields
          padding: const EdgeInsets.all(24.0),
          child: Form(
            // "Form" groups all the input fields together
            // and lets us validate them all at once
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // ── Header ───────────────────────────────
                const Text(
                  '👋 Welcome!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's set up your calorie goal.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // ── Current Weight Field ─────────────────
                const Text('Current Weight (kg)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentWeightController,
                  // "keyboardType" shows a number keyboard
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('e.g. 75.0'),
                  // "validator" checks the input when form is submitted
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null; // null means "no error"
                  },
                ),
                const SizedBox(height: 20),

                // ── Goal Weight Field ────────────────────
                const Text('Goal Weight (kg)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _goalWeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('e.g. 65.0'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your goal weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    // Goal weight must be less than current weight
                    final double goal = double.parse(value);
                    final double current =
                        double.tryParse(_currentWeightController.text) ?? 0;
                    if (goal >= current) {
                      return 'Goal weight must be less than current weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Maintenance Calories Field ───────────
                const Text('Daily Maintenance Calories (TDEE)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  'Not sure? Use 2000 as a starting estimate.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maintenanceCaloriesController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('e.g. 2000'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maintenance calories';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Timeline Selector ────────────────────
                const Text('Timeline to reach goal',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // Show timeline options as selectable buttons
                Wrap(
                  spacing: 10,
                  children: _timelineOptions.map((option) {
                    final bool isSelected =
                        _selectedTimelineDays == option['days'];
                    return ChoiceChip(
                      // "ChoiceChip" is a selectable button widget
                      label: Text(option['label']),
                      selected: isSelected,
                      selectedColor: const Color(0xFF00C896),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        // Update the selected timeline when tapped
                        setState(() {
                          _selectedTimelineDays = option['days'];
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // ── Get Started Button ───────────────────
                SizedBox(
                  width: double.infinity, // Full width button
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGoal,
                    // Disable button while loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C896),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Get Started 🚀',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to keep input field styling consistent
  // Instead of repeating the same decoration on every field, 
  // we define it once here and reuse it.
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No visible border line
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}