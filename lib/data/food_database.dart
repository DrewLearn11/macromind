

class FoodDatabase{

    static const List<Map<String, dynamic>> foods=[
            // ── Grains & Carbs ──────────────────────
    {'name': 'White Rice (cooked)',       'caloriesPer100g': 130.0},
    {'name': 'Brown Rice (cooked)',       'caloriesPer100g': 112.0},
    {'name': 'White Bread',               'caloriesPer100g': 265.0},
    {'name': 'Whole Wheat Bread',         'caloriesPer100g': 247.0},
    {'name': 'Oatmeal (cooked)',          'caloriesPer100g': 71.0},
    {'name': 'Pasta (cooked)',            'caloriesPer100g': 131.0},
    {'name': 'Pancake',                   'caloriesPer100g': 227.0},

        // ── Proteins ────────────────────────────
    {'name': 'Chicken Breast (cooked)',   'caloriesPer100g': 165.0},
    {'name': 'Chicken Thigh (cooked)',    'caloriesPer100g': 209.0},
    {'name': 'Egg (whole)',               'caloriesPer100g': 155.0},
    {'name': 'Egg White',                 'caloriesPer100g': 52.0},
    {'name': 'Tuna (canned)',             'caloriesPer100g': 116.0},
    {'name': 'Salmon (cooked)',           'caloriesPer100g': 208.0},
    {'name': 'Beef (lean, cooked)',       'caloriesPer100g': 250.0},
    {'name': 'Pork (lean, cooked)',       'caloriesPer100g': 242.0},
    {'name': 'Tofu',                      'caloriesPer100g': 76.0},

        // ── Vegetables ──────────────────────────
    {'name': 'Broccoli',                  'caloriesPer100g': 34.0},
    {'name': 'Spinach',                   'caloriesPer100g': 23.0},
    {'name': 'Carrot',                    'caloriesPer100g': 41.0},
    {'name': 'Potato (boiled)',           'caloriesPer100g': 87.0},
    {'name': 'Sweet Potato (boiled)',     'caloriesPer100g': 76.0},
    {'name': 'Tomato',                    'caloriesPer100g': 18.0},
    {'name': 'Cucumber',                  'caloriesPer100g': 16.0},
    {'name': 'Cabbage',                   'caloriesPer100g': 25.0},
    {'name': 'Corn (cooked)',             'caloriesPer100g': 96.0},

        // ── Fruits ──────────────────────────────
    {'name': 'Banana',                    'caloriesPer100g': 89.0},
    {'name': 'Apple',                     'caloriesPer100g': 52.0},
    {'name': 'Mango',                     'caloriesPer100g': 60.0},
    {'name': 'Watermelon',               'caloriesPer100g': 30.0},
    {'name': 'Orange',                    'caloriesPer100g': 47.0},
    {'name': 'Pineapple',                'caloriesPer100g': 50.0},

    // ── Dairy ───────────────────────────────
    {'name': 'Whole Milk',               'caloriesPer100g': 61.0},
    {'name': 'Low Fat Milk',             'caloriesPer100g': 42.0},
    {'name': 'Cheddar Cheese',           'caloriesPer100g': 403.0},
    {'name': 'Greek Yogurt (plain)',     'caloriesPer100g': 59.0},
    {'name': 'Butter',                   'caloriesPer100g': 717.0},

        // ── Snacks & Others ─────────────────────
    {'name': 'Peanut Butter',            'caloriesPer100g': 588.0},
    {'name': 'Almonds',                  'caloriesPer100g': 579.0},
    {'name': 'Dark Chocolate',           'caloriesPer100g': 546.0},
    {'name': 'French Fries',             'caloriesPer100g': 312.0},
    {'name': 'Pizza (cheese)',           'caloriesPer100g': 266.0},
    {'name': 'Hamburger',               'caloriesPer100g': 295.0},
    ];

      // SEARCH FUNCTION
  // Takes a search query and returns matching foods
  // Example: search("chi") returns Chicken Breast, Chicken Thigh
  static List<Map<String, dynamic>> search(String query) {
    // If the search box is empty, return the full list
    if (query.isEmpty) return foods;

    // ".toLowerCase()" makes the search case-insensitive
    // So "chicken" and "Chicken" and "CHICKEN" all match
    final String lowerQuery = query.toLowerCase();

    // Filter the list — keep only foods whose name contains the query
    return foods.where((food) {
      return (food['name'] as String)
          .toLowerCase()
          .contains(lowerQuery);
    }).toList();
  }

  // CALCULATE CALORIES FOR A SPECIFIC SERVING SIZE
  // Example: calculateCalories(165.0, 150.0) 
  // → Chicken Breast is 165 cal/100g, user ate 150g
  // → result = 165 * 150 / 100 = 247.5 calories
  static double calculateCalories(double caloriesPer100g, double gramsEaten) {
    return (caloriesPer100g * gramsEaten) / 100;
  }
  
}