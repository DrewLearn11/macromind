// food_search_screen.dart
// This screen lets the user search for food and log it.
// It searches through our FoodDatabase and lets the user
// enter how many grams they ate, then saves it.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/food_database.dart';
import '../models/food_entry.dart';
import '../services/storage_service.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchController = TextEditingController();

  // This holds the current search results
  List<Map<String, dynamic>> _searchResults = FoodDatabase.foods;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter food list as user types
  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = FoodDatabase.search(query);
    });
  }

  // Show a dialog asking how many grams the user ate
  void _showServingDialog(Map<String, dynamic> food) {
    final TextEditingController gramsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(food['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${food['caloriesPer100g']} kcal per 100g',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('How many grams did you eat?'),
            const SizedBox(height: 8),
            TextField(
              controller: gramsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. 150',
                suffixText: 'g',
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
              final double? grams =
                  double.tryParse(gramsController.text.trim());

              // Validate input
              if (grams == null || grams <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              // Calculate calories for this serving
              final double calories = FoodDatabase.calculateCalories(
                food['caloriesPer100g'],
                grams,
              );

              // Create a new FoodEntry object
              final FoodEntry entry = FoodEntry(
                id: const Uuid().v4(), // Generate a unique ID
                name: food['name'],
                calories: calories,
                servingSize: grams,
                loggedAt: DateTime.now(),
              );

              // Save to storage
              await StorageService.addFoodEntry(entry);

              if (!context.mounted) return;

              // Close the dialog
              Navigator.pop(context);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${food['name']} added! ${calories.toStringAsFixed(0)} kcal'),
                  backgroundColor: const Color(0xFF00C896),
                ),
              );

              // Go back to Dashboard
              Navigator.pop(context);
            },
            child: const Text('Add Food'),
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
          'Search Food',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search food (e.g. chicken, rice...)',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // ── Results Count ───────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_searchResults.length} foods found',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // ── Food List ───────────────────────────
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🔍', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'No foods found',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final food = _searchResults[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          // Food icon
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C896).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('🍴',
                                style: TextStyle(fontSize: 18)),
                          ),
                          // Food name
                          title: Text(
                            food['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          // Calories per 100g
                          subtitle: Text(
                            '${food['caloriesPer100g']} kcal / 100g',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF00C896),
                            size: 28,
                          ),
                          onTap: () => _showServingDialog(food),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}