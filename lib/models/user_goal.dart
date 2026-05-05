class UserGoal {
  double currentWeight;
  double goalWeight;
  double height;          // in cm
  int age;
  String sex;             // 'male' or 'female'
  String activityLevel;   // sedentary, light, moderate, active, very active
  int timelineInDays;
  double maintenanceCalories;
  double recommendedCalories; // AI recommended

  UserGoal({
    required this.currentWeight,
    required this.goalWeight,
    required this.height,
    required this.age,
    required this.sex,
    required this.activityLevel,
    required this.timelineInDays,
    required this.maintenanceCalories,
    required this.recommendedCalories,
  });

  // Activity level multipliers (Harris-Benedict equation)
  static double getActivityMultiplier(String level) {
    switch (level) {
      case 'sedentary':    return 1.2;
      case 'light':        return 1.375;
      case 'moderate':     return 1.55;
      case 'active':       return 1.725;
      case 'very_active':  return 1.9;
      default:             return 1.2;
    }
  }

  // Calculate BMR using Mifflin-St Jeor Equation
  static double calculateBMR(double weight, double height, int age, String sex) {
    if (sex == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate TDEE
  static double calculateTDEE(double bmr, String activityLevel) {
    return bmr * getActivityMultiplier(activityLevel);
  }

  double get totalCaloriesToBurn => (currentWeight - goalWeight) * 7700;
  double get dailyDeficit => totalCaloriesToBurn / timelineInDays;
  double get dailyCalorieBudget => recommendedCalories - dailyDeficit;

  Map<String, dynamic> toJson() {
    return {
      'currentWeight': currentWeight,
      'goalWeight': goalWeight,
      'height': height,
      'age': age,
      'sex': sex,
      'activityLevel': activityLevel,
      'timelineInDays': timelineInDays,
      'maintenanceCalories': maintenanceCalories,
      'recommendedCalories': recommendedCalories,
    };
  }

  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      currentWeight: json['currentWeight'],
      goalWeight: json['goalWeight'],
      height: json['height'] ?? 170.0,
      age: json['age'] ?? 25,
      sex: json['sex'] ?? 'male',
      activityLevel: json['activityLevel'] ?? 'sedentary',
      timelineInDays: json['timelineInDays'],
      maintenanceCalories: json['maintenanceCalories'],
      recommendedCalories: json['recommendedCalories'] ?? json['maintenanceCalories'],
    );
  }
}