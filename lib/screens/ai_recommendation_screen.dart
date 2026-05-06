// ai_recommendation_screen.dart
// Shows the AI-generated calorie recommendation to the user.
// Displays BMR, TDEE, and the personalized recommendation
// with explanation. User confirms to save and go to Dashboard.

import 'package:flutter/material.dart';
import '../models/user_goal.dart';
import '../models/weight_log.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';
import 'goal_setup_screen.dart';

class AIRecommendationScreen extends StatelessWidget {
  final double currentWeight;
  final double goalWeight;
  final double height;
  final int age;
  final String sex;
  final String activityLevel;
  final int timelineInDays;
  final double bmr;
  final double tdee;
  final Map<String, dynamic> aiResult;

  const AIRecommendationScreen({
    super.key,
    required this.currentWeight,
    required this.goalWeight,
    required this.height,
    required this.age,
    required this.sex,
    required this.activityLevel,
    required this.timelineInDays,
    required this.bmr,
    required this.tdee,
    required this.aiResult,
  });

Future<void> _saveAndContinue(BuildContext context) async {
  final double recommendedCalories =
      (aiResult['recommendedCalories'] as num).toDouble();

  final UserGoal tempGoal = UserGoal(
    currentWeight: currentWeight,
    goalWeight: goalWeight,
    height: height,
    age: age,
    sex: sex,
    activityLevel: activityLevel,
    timelineInDays: timelineInDays,
    maintenanceCalories: tdee,
    recommendedCalories: recommendedCalories,
  );

  // ← ADD THIS: Block if budget is too low
  if (tempGoal.dailyCalorieBudget < 800) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('⚠️ Goal Too Aggressive!'),
        content: Text(
          'Your daily calorie budget would be '
          '${tempGoal.dailyCalorieBudget.toStringAsFixed(0)} kcal '
          'which is not safe.\n\n'
          'For healthy weight loss aim for:\n'
          '• Minimum 1,200 kcal/day for women\n'
          '• Minimum 1,500 kcal/day for men\n\n'
          'Please go back and choose a longer timeline.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to goal setup
            },
            child: const Text('Adjust My Goal'),
          ),
        ],
      ),
    );
    return; // stop saving
  }

  // Save goal if budget is safe
  final UserGoal goal = UserGoal(
    currentWeight: currentWeight,
    goalWeight: goalWeight,
    height: height,
    age: age,
    sex: sex,
    activityLevel: activityLevel,
    timelineInDays: timelineInDays,
    maintenanceCalories: tdee,
    recommendedCalories: recommendedCalories,
  );

  await StorageService.saveGoal(goal);
  await StorageService.addWeightLog(
    WeightLog(weight: currentWeight, loggedAt: DateTime.now()),
  );

  if (!context.mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const DashboardScreen()),
  );
}

  @override
  Widget build(BuildContext context) {
    final int recommendedCalories = aiResult['recommendedCalories'] as int;
    final String explanation = aiResult['explanation'] as String;
    final String tip = aiResult['tip'] as String;
    final bool isGoalSafe = aiResult['isGoalSafe'] as bool? ?? true;
    final String warningMessage = aiResult['warningMessage'] as String? ?? '';

    final UserGoal tempGoal = UserGoal(
      currentWeight: currentWeight,
      goalWeight: goalWeight,
      height: height,
      age: age,
      sex: sex,
      activityLevel: activityLevel,
      timelineInDays: timelineInDays,
      maintenanceCalories: tdee,
      recommendedCalories: recommendedCalories.toDouble(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your AI Recommendation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Warning Banner (if goal unsafe) ─────
            if (!isGoalSafe)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        warningMessage,
                        style: TextStyle(
                            color: Colors.orange.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ── AI Recommendation Card ───────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C896), Color(0xFF00A87C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C896).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '✨ AI Recommended',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$recommendedCalories',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'kcal / day',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── BMR & TDEE Stats ─────────────────────
            Row(
              children: [
                _buildStatCard(
                  label: 'BMR',
                  value: '${bmr.toStringAsFixed(0)} kcal',
                  description: 'Calories at rest',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  label: 'TDEE',
                  value: '${tdee.toStringAsFixed(0)} kcal',
                  description: 'Maintenance calories',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Daily Budget Card ────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Calorie Budget',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('After weight loss deficit',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Text(
                    '${tempGoal.dailyCalorieBudget.toStringAsFixed(0)} kcal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tempGoal.dailyCalorieBudget > 0
                          ? const Color(0xFF00C896)
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── AI Explanation ───────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('AI Analysis',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    explanation,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Tip Card ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6FFF8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF00C896).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pro Tip',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A87C))),
                        const SizedBox(height: 4),
                        Text(
                          tip,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF00A87C),
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Profile Summary ──────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Profile Summary',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildProfileRow('⚖️ Current Weight', '${currentWeight}kg'),
                  _buildProfileRow('🎯 Goal Weight', '${goalWeight}kg'),
                  _buildProfileRow('📏 Height', '${height}cm'),
                  _buildProfileRow('🎂 Age', '$age years'),
                  _buildProfileRow('👤 Sex', sex == 'male' ? 'Male' : 'Female'),
                  _buildProfileRow('🏃 Activity', _getActivityLabel()),
                  _buildProfileRow('📅 Timeline', _getTimelineLabel()),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Confirm Button ───────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => _saveAndContinue(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C896),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Start My Journey 🚀',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
  child: TextButton(
    onPressed: () {
      // Pop only back to Goal Setup Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const GoalSetupScreen(),
        ),
      );
    },
    child: const Text(
      'Go Back & Adjust',
      style: TextStyle(color: Colors.grey),
    ),
  ),
),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String description,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text(description,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  String _getActivityLabel() {
    const labels = {
      'sedentary': 'Sedentary',
      'light': 'Lightly Active',
      'moderate': 'Moderately Active',
      'active': 'Very Active',
      'very_active': 'Extra Active',
    };
    return labels[activityLevel] ?? activityLevel;
  }

  String _getTimelineLabel() {
    if (timelineInDays == 7) return '1 Week';
    if (timelineInDays == 14) return '2 Weeks';
    if (timelineInDays == 30) return '1 Month';
    if (timelineInDays == 60) return '2 Months';
    if (timelineInDays == 90) return '3 Months';
    if (timelineInDays == 180) return '6 Months';
    return '$timelineInDays days';
  }
}