// goal_setup_screen.dart
// This screen collects the user's physical details after registration.
// It calculates BMR and TDEE, then sends data to OpenAI for
// a personalized calorie recommendation.

import 'package:flutter/material.dart';
import '../models/user_goal.dart';
import '../services/openai_service.dart';
import 'ai_recommendation_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedSex = 'male';
  String _selectedActivity = 'sedentary';
  int _selectedTimelineDays = 30;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _activityLevels = [
    {
      'value': 'sedentary',
      'label': 'Sedentary',
      'description': 'Little or no exercise',
      'icon': '🪑'
    },
    {
      'value': 'light',
      'label': 'Lightly Active',
      'description': 'Light exercise 1-3 days/week',
      'icon': '🚶'
    },
    {
      'value': 'moderate',
      'label': 'Moderately Active',
      'description': 'Moderate exercise 3-5 days/week',
      'icon': '🏃'
    },
    {
      'value': 'active',
      'label': 'Very Active',
      'description': 'Hard exercise 6-7 days/week',
      'icon': '🏋️'
    },
    {
      'value': 'very_active',
      'label': 'Extra Active',
      'description': 'Very hard exercise & physical job',
      'icon': '⚡'
    },
  ];

  final List<Map<String, dynamic>> _timelineOptions = [
    {'label': '1 Week',   'days': 7},
    {'label': '2 Weeks',  'days': 14},
    {'label': '1 Month',  'days': 30},
    {'label': '2 Months', 'days': 60},
    {'label': '3 Months', 'days': 90},
    {'label': '6 Months', 'days': 180},
  ];

  @override
  void dispose() {
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _calculateAndGetRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final double currentWeight = double.parse(_currentWeightController.text.trim());
    final double goalWeight = double.parse(_goalWeightController.text.trim());
    final double height = double.parse(_heightController.text.trim());
    final int age = int.parse(_ageController.text.trim());

    // Calculate BMR using Mifflin-St Jeor Equation
    final double bmr = UserGoal.calculateBMR(
      currentWeight, height, age, _selectedSex);

    // Calculate TDEE
    final double tdee = UserGoal.calculateTDEE(bmr, _selectedActivity);

    // Send to OpenAI for recommendation
    final Map<String, dynamic> aiResult =
        await OpenAIService.getCalorieRecommendation(
      currentWeight: currentWeight,
      goalWeight: goalWeight,
      height: height,
      age: age,
      sex: _selectedSex,
      activityLevel: _selectedActivity,
      timelineInDays: _selectedTimelineDays,
      bmr: bmr,
      tdee: tdee,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate to AI Recommendation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AIRecommendationScreen(
          currentWeight: currentWeight,
          goalWeight: goalWeight,
          height: height,
          age: age,
          sex: _selectedSex,
          activityLevel: _selectedActivity,
          timelineInDays: _selectedTimelineDays,
          bmr: bmr,
          tdee: tdee,
          aiResult: aiResult,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Header ──────────────────────────────
                const Text(
                  '💪 Let\'s Build Your Plan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tell us about yourself so our AI can calculate your perfect calorie goal.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 28),

                // ── Weight Row ───────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Weight (kg)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _currentWeightController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            decoration: _inputDecoration('e.g. 75.0'),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Goal Weight (kg)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _goalWeightController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            decoration: _inputDecoration('e.g. 65.0'),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              final double goal = double.parse(value);
                              final double current = double.tryParse(
                                      _currentWeightController.text) ?? 0;
                              if (goal >= current) return 'Must be less than current';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Height & Age Row ─────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Height (cm)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _heightController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            decoration: _inputDecoration('e.g. 170'),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Age',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('e.g. 25'),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (int.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
               const SizedBox(height: 20),

                // ── Sex Selector ─────────────────────────
                const Text('Sex',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSex = 'male'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedSex == 'male'
                                ? const Color(0xFF00C896)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text('👨', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                'Male',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedSex == 'male'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSex = 'female'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedSex == 'female'
                                ? const Color(0xFF00C896)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text('👩', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                'Female',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedSex == 'female'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Activity Level ───────────────────────
                const Text('Activity Level',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                ..._activityLevels.map((activity) {
                  final bool isSelected =
                      _selectedActivity == activity['value'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedActivity = activity['value']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00C896).withOpacity(0.1)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00C896)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(activity['icon'],
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['label'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF00C896)
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  activity['description'],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: Color(0xFF00C896)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // ── Timeline ─────────────────────────────
                const Text('Goal Timeline',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timelineOptions.map((option) {
                    final bool isSelected =
                        _selectedTimelineDays == option['days'];
                    return GestureDetector(
                      onTap: () => setState(
                          () => _selectedTimelineDays = option['days']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00C896)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          option['label'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),

                // ── Calculate Button ─────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _calculateAndGetRecommendation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C896),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Getting AI Recommendation...',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        : const Text(
                            '✨ Get AI Recommendation',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}