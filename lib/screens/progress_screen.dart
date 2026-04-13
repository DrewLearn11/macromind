// progress_screen.dart
// This screen shows the user's weight history as a chart
// and a list of all weight log entries.
// The user can also log their current weight here.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weight_log.dart';
import '../models/user_goal.dart';
import '../services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<WeightLog> _weightLogs = [];
  UserGoal? _goal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final logs = await StorageService.loadWeightLogs();
    final goal = await StorageService.loadGoal();
    setState(() {
      // Sort logs by date oldest first so chart flows left to right
      _weightLogs = logs..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
      _goal = goal;
      _isLoading = false;
    });
  }

  // Show dialog to log today's weight
  void _showLogWeightDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Log Your Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your current weight in kg',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. 70.5',
                suffixText: 'kg',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final double? weight =
                  double.tryParse(controller.text.trim());

              if (weight == null || weight <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid weight')),
                );
                return;
              }

              // Save the new weight log
              await StorageService.addWeightLog(
                WeightLog(
                  weight: weight,
                  loggedAt: DateTime.now(),
                ),
              );

              if (!context.mounted) return;
              Navigator.pop(context);

              // Refresh the screen
              _loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Weight logged: ${weight}kg'),
                  backgroundColor: const Color(0xFF00C896),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Get the most recent weight log
  double get _currentWeight {
    if (_weightLogs.isEmpty) return 0;
    return _weightLogs.last.weight;
  }

  // Calculate how much weight lost so far
  double get _weightLost {
    if (_weightLogs.isEmpty || _goal == null) return 0;
    return _goal!.currentWeight - _currentWeight;
  }

  // Calculate how much weight left to lose
  double get _weightRemaining {
    if (_goal == null) return 0;
    return _currentWeight - _goal!.goalWeight;
  }

  // Calculate overall progress percentage
  double get _progressPercent {
    if (_goal == null) return 0;
    final total = _goal!.currentWeight - _goal!.goalWeight;
    if (total <= 0) return 0;
    final lost = _goal!.currentWeight - _currentWeight;
    return (lost / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Button to log weight
          TextButton.icon(
            onPressed: _showLogWeightDialog,
            icon: const Icon(Icons.add, color: Color(0xFF00C896)),
            label: const Text(
              'Log Weight',
              style: TextStyle(
                color: Color(0xFF00C896),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Goal Summary Card ───────────────
                    _buildGoalSummaryCard(),
                    const SizedBox(height: 20),

                    // ── Weight Chart ────────────────────
                    if (_weightLogs.length >= 2) ...[
                      const Text(
                        'Weight Over Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildWeightChart(),
                      const SizedBox(height: 28),
                    ],

                    // ── Weight Log History ──────────────
                    const Text(
                      'Weight History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWeightHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  // Goal summary card showing progress stats
  Widget _buildGoalSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goal Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              // "LinearProgressIndicator" is a horizontal progress bar
              value: _progressPercent,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00C896),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progressPercent * 100).toStringAsFixed(1)}% of goal reached',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // 3 stat boxes in a row
          Row(
            children: [
              _buildStatBox(
                label: 'Start',
                value: _goal != null
                    ? '${_goal!.currentWeight.toStringAsFixed(1)}kg'
                    : '--',
                color: Colors.grey,
              ),
              _buildStatBox(
                label: 'Current',
                value: _weightLogs.isNotEmpty
                    ? '${_currentWeight.toStringAsFixed(1)}kg'
                    : '--',
                color: const Color(0xFF00C896),
              ),
              _buildStatBox(
                label: 'Goal',
                value: _goal != null
                    ? '${_goal!.goalWeight.toStringAsFixed(1)}kg'
                    : '--',
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lost and remaining row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_weightLost.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C896),
                        ),
                      ),
                      const Text(
                        'Lost so far',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_weightRemaining.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Text(
                        'Remaining',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Weight line chart using fl_chart
  Widget _buildWeightChart() {
    // Convert weight logs into chart data points
    // "FlSpot" is a single point on the chart (x, y)
    // x = index (0, 1, 2...), y = weight value
    final List<FlSpot> spots = _weightLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    // Find min and max weight for chart boundaries
    final double minWeight =
        _weightLogs.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    final double maxWeight =
        _weightLogs.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
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
      child: LineChart(
        LineChartData(
          // Hide the grid lines
          gridData: const FlGridData(show: false),

          // Chart border
          borderData: FlBorderData(show: false),

          // Y axis boundaries
          minY: minWeight,
          maxY: maxWeight,

          // Axis label styling
          titlesData: FlTitlesData(
            // Hide top and right labels
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            // Show left (weight) labels
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(0)}kg',
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ),
            // Hide bottom labels (too many dates)
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),

          // The actual line data
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true, // Smooth curved line
              color: const Color(0xFF00C896),
              barWidth: 3,
              dotData: const FlDotData(show: true), // Show dots at each point
              belowBarData: BarAreaData(
                // Shaded area below the line
                show: true,
                color: const Color(0xFF00C896).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List of all weight log entries
  Widget _buildWeightHistory() {
    if (_weightLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: const [
              Text('⚖️', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text(
                'No weight logs yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Tap "Log Weight" to get started!',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Show logs in reverse order (newest first)
    final reversedLogs = _weightLogs.reversed.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedLogs.length,
      itemBuilder: (context, index) {
        final log = reversedLogs[index];
        final bool isLatest = index == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isLatest
                ? Border.all(color: const Color(0xFF00C896), width: 1.5)
                : null,
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
              // Scale icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLatest
                      ? const Color(0xFF00C896).withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('⚖️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 14),

              // Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(log.loggedAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatTime(log.loggedAt),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Weight value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${log.weight.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isLatest
                          ? const Color(0xFF00C896)
                          : Colors.black87,
                    ),
                  ),
                  if (isLatest)
                    const Text(
                      'Latest',
                      style: TextStyle(
                        color: Color(0xFF00C896),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // A single stat box for the goal summary
  Widget _buildStatBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Format date like "Apr 12, 2026"
  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  // Format time like "2:30 PM"
  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}