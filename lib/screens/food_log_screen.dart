import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../services/storage_service.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  List<FoodEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  // Load today's food entries from storage
  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await StorageService.loadTodaysFoodEntries();
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  // Delete a food entry by ID
  Future<void> _deleteEntry(String id) async {
    await StorageService.deleteFoodEntry(id);
    _loadEntries(); // Refresh the list after deleting
  }

  // Calculate total calories of all entries
  double get _totalCalories {
    return _entries.fold(0.0, (sum, entry) => sum + entry.calories);
  }

  // Show a confirmation dialog before deleting
  void _confirmDelete(FoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Entry?'),
        content: Text('Remove "${entry.name}" from your food log?'),
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
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteEntry(entry.id); // Delete the entry
            },
            child: const Text('Delete'),
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
          "Today's Food Log",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // ── Total Calories Summary ──────────
                    _buildTotalCard(),

                    // ── Food Entry List ─────────────────
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          // "Dismissible" lets user swipe left to delete
                          return Dismissible(
                            key: Key(entry.id),
                            direction: DismissDirection.endToStart,
                            // Red background shown when swiping
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            // Called when swipe is complete
                            onDismissed: (_) => _deleteEntry(entry.id),
                            child: _buildFoodCard(entry),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  // Total calories summary card at the top
  Widget _buildTotalCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00C896),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C896).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Consumed',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_totalCalories.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'kcal',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // A single food entry card
  Widget _buildFoodCard(FoodEntry entry) {
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

          // Food name, serving, and time
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${entry.servingSize.toStringAsFixed(0)}g',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    const Text('•',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    // Show the time the food was logged
                    Text(
                      _formatTime(entry.loggedAt),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calories + delete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF00C896),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _confirmDelete(entry),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Empty state when no food is logged
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No food logged today',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Go back and tap "Add Food" to log your meals',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // Format DateTime to a readable time string like "2:30 PM"
  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}