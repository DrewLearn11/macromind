// goal_settings_screen.dart
// This screen lets the user update their goal at any time.
// For example, if they want to change their target weight
// or extend their timeline.

import 'package:flutter/material.dart';
import '../models/user_goal.dart';
import '../services/storage_service.dart';

class GoalSettingsScreen extends StatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  final _maintenanceCaloriesController = TextEditingController();

  int _selectedTimelineDays = 30;
  bool _isLoading = true;
  bool _isSaving = false;
  UserGoal? _goal;

  final List<Map<String, dynamic>> _timelineOptions = [
    {'label': '1 Week',   'days': 7},
    {'label': '2 Weeks',  'days': 14},
    {'label': '1 Month',  'days': 30},
    {'label': '3 Months', 'days': 90},
  ];

  @override
  void initState() {
    super.initState();
    // Load existing goal so fields are pre-filled
    _loadExistingGoal();
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _maintenanceCaloriesController.dispose();
    super.dispose();
  }

  // Load the saved goal and pre-fill the form fields
Future<void> _loadExistingGoal() async {
  final UserGoal? goal = await StorageService.loadGoal();

  setState(() {
    _goal = goal; // ← add this line
    if (goal != null) {
      _currentWeightController.text = goal.currentWeight.toString();
      _goalWeightController.text = goal.goalWeight.toString();
      _maintenanceCaloriesController.text =
          goal.maintenanceCalories.toString();
      _selectedTimelineDays = goal.timelineInDays;
    }
    _isLoading = false;
  });
}

  // Save the updated goal
  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

final UserGoal updatedGoal = UserGoal(
  currentWeight: double.parse(_currentWeightController.text.trim()),
  goalWeight: double.parse(_goalWeightController.text.trim()),
  height: _goal?.height ?? 170.0,
  age: _goal?.age ?? 25,
  sex: _goal?.sex ?? 'male',
  activityLevel: _goal?.activityLevel ?? 'sedentary',
  timelineInDays: _selectedTimelineDays,
  maintenanceCalories: double.parse(_maintenanceCaloriesController.text.trim()),
  recommendedCalories: double.parse(_maintenanceCaloriesController.text.trim()),
);

    await StorageService.saveGoal(updatedGoal);

    if (!mounted) return;

    setState(() => _isSaving = false);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goal updated successfully! 🎯'),
        backgroundColor: Color(0xFF00C896),
      ),
    );

    // Go back to Dashboard
    Navigator.pop(context);
  }

  // Show a confirmation dialog before resetting all data
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete ALL your food logs, weight history, and goal. '
          'This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await StorageService.clearAllData();
              if (!context.mounted) return;
              // Pop all screens and go back to Onboarding
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Goal Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info Banner ─────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C896).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00C896).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFF00C896), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Updating your goal will recalculate your daily calorie budget.',
                              style: TextStyle(
                                color: Color(0xFF00C896),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Current Weight ──────────────────
                    const Text(
                      'Current Weight (kg)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: _inputDecoration('e.g. 75.0'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current weight';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Goal Weight ─────────────────────
                    const Text(
                      'Goal Weight (kg)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _goalWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: _inputDecoration('e.g. 65.0'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your goal weight';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        final double goal = double.parse(value);
                        final double current =
                            double.tryParse(_currentWeightController.text) ??
                                0;
                        if (goal >= current) {
                          return 'Goal weight must be less than current weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Maintenance Calories ────────────
                    const Text(
                      'Daily Maintenance Calories (TDEE)',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

                    // ── Timeline Selector ───────────────
                    const Text(
                      'Timeline to reach goal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: _timelineOptions.map((option) {
                        final bool isSelected =
                            _selectedTimelineDays == option['days'];
                        return ChoiceChip(
                          label: Text(option['label']),
                          selected: isSelected,
                          selectedColor: const Color(0xFF00C896),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedTimelineDays = option['days'];
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // ── Save Button ─────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Reset Button ────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _confirmReset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Reset All Data',
                          style: TextStyle(
                            fontSize: 16,
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
    );
  }

  // Reusable input decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}