// dashboard_screen.dart
// This is the MAIN screen of the app.
// It shows:
// - Today's calorie summary (consumed vs budget)
// - A circular progress ring
// - A quick list of today's food entries
// - Navigation to other screens

import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../models/user_goal.dart';
import '../services/storage_service.dart';
import 'food_log_screen.dart';
import 'food_search_screen.dart';
import 'progress_screen.dart';
import 'goal_settings_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // These hold the data we load from storage
  UserGoal? _goal;
  List<FoodEntry> _todayEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // "initState()" runs ONCE when the screen first loads
    // We use it to load our data from storage
    _loadData();
  }

  // Load goal and today's food entries from storage
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final goal = await StorageService.loadGoal();
    final entries = await StorageService.loadTodaysFoodEntries();

    setState(() {
      _goal = goal;
      _todayEntries = entries;
      _isLoading = false;
    });
  }

  // Calculate total calories eaten today
  double get _totalCaloriesToday {
    return _todayEntries.fold(0.0, (sum, entry) => sum + entry.calories);
  }

  // Calculate remaining calories for today
  double get _remainingCalories {
    if (_goal == null) return 0;
    return _goal!.dailyCalorieBudget - _totalCaloriesToday;
  }

  // Calculate progress as a value between 0.0 and 1.0
  // Used for the progress ring
  double get _progressValue {
    if (_goal == null || _goal!.dailyCalorieBudget <= 0) return 0;
    final progress = _totalCaloriesToday / _goal!.dailyCalorieBudget;
    // Clamp keeps the value between 0.0 and 1.0
    return progress.clamp(0.0, 1.0);
  }

  // Color of the progress ring changes based on how full it is
  Color get _progressColor {
    if (_progressValue < 0.7) return const Color(0xFF00C896); // Green — good
    if (_progressValue < 0.9) return Colors.orange;           // Orange — careful
    return Colors.red;                                         // Red — over limit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MacroMind 🥗',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // Logout button
              IconButton(
                icon: const Icon(Icons.logout_outlined),
                onPressed: () async {
                  await StorageService.logout();
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
          // Settings icon — goes to Goal Settings screen
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GoalSettingsScreen()),
              );
              // Reload data when coming back from settings
              _loadData();
            },
          ),
        ],
        
      ),

      // ── Bottom Navigation Bar ──────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Dashboard is always index 0
        selectedItemColor: const Color(0xFF00C896),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 1) {
            // Go to Food Log screen
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FoodLogScreen()),
            );
            _loadData(); // Refresh after returning
          } else if (index == 2) {
            // Go to Progress screen
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: 'Food Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Progress',
          ),
        ],
      ),

      // ── FAB — Quick Add Food ───────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Go to Food Search screen
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodSearchScreen()),
          );
          _loadData(); // Refresh after adding food
        },
        backgroundColor: const Color(0xFF00C896),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Food',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // "RefreshIndicator" lets user pull down to refresh
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Greeting ───────────────────────
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Here's your day so far",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Calorie Ring Card ───────────────
                    _buildCalorieRingCard(),
                    const SizedBox(height: 20),

                    // ── Stats Row ───────────────────────
                    _buildStatsRow(),
                    const SizedBox(height: 28),

                    // ── Today's Food List ───────────────
                    const Text(
                      "Today's Food",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFoodList(),
                  ],
                ),
              ),
            ),
    );
  }

  // ── WIDGET BUILDERS ──────────────────────────────────

  // The big circular progress ring card
  Widget _buildCalorieRingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular progress indicator
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              // "Stack" lets us layer widgets on top of each other
              alignment: Alignment.center,
              children: [
                // Background ring (grey)
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 14,
                    color: Colors.grey.shade200,
                  ),
                ),
                // Foreground ring (colored based on progress)
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: _progressValue,
                    strokeWidth: 14,
                    color: _progressColor,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Text in the center of the ring
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_totalCaloriesToday.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'consumed',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Budget label below the ring
          Text(
            _goal == null
                ? 'No goal set'
                : 'Daily Budget: ${_goal!.dailyCalorieBudget.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Row of 3 stat boxes: Consumed, Remaining, Burned
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatBox(
          label: 'Consumed',
          value: '${_totalCaloriesToday.toStringAsFixed(0)}',
          unit: 'kcal',
          color: const Color(0xFF00C896),
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          label: 'Remaining',
          value: '${_remainingCalories.toStringAsFixed(0)}',
          unit: 'kcal',
          color: _remainingCalories >= 0 ? Colors.blue : Colors.red,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          label: 'Budget',
          value: _goal != null
              ? '${_goal!.dailyCalorieBudget.toStringAsFixed(0)}'
              : '--',
          unit: 'kcal',
          color: Colors.orange,
        ),
      ],
    );
  }

  // A single stat box widget
  Widget _buildStatBox({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      // "Expanded" makes each box take equal width
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // List of today's food entries
  Widget _buildFoodList() {
    if (_todayEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: const [
              Text('🍽️', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text(
                'No food logged today',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Tap "Add Food" to get started!',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      // "shrinkWrap" lets ListView sit inside a ScrollView
      shrinkWrap: true,
      // "NeverScrollableScrollPhysics" disables ListView's own scrolling
      // since the parent SingleChildScrollView handles it
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todayEntries.length,
      itemBuilder: (context, index) {
        final entry = _todayEntries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Food icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🍴', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 14),
              // Food name and serving size
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${entry.servingSize.toStringAsFixed(0)}g',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Calories
              Text(
                '${entry.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF00C896),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Returns a greeting based on the time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! ☀️';
    if (hour < 17) return 'Good afternoon! 🌤️';
    return 'Good evening! 🌙';
  }
}