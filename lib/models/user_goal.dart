

class UserGoal {
double currentWeight;
double goalWeight;
int timelineInDays;
double maintenanceCalories;

UserGoal({
  required this.currentWeight,
  required this.goalWeight,
  required this.timelineInDays,
  required this.maintenanceCalories,
});

double get totalCaloriesToBurn =>(currentWeight - goalWeight) * 7700;
double get dailyDeficit => totalCaloriesToBurn / timelineInDays;
double get dailyCalorieBudget => maintenanceCalories - dailyDeficit;


 Map<String, dynamic> toJson() {
    return {
      'currentWeight': currentWeight,
      'goalWeight': goalWeight,
      'timelineInDays': timelineInDays,
      'maintenanceCalories': maintenanceCalories,
    };
  }

  // "fromJson" is the reverse — it takes a Map and creates a UserGoal object.
  // This is used when we LOAD data from SharedPreferences.
  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      currentWeight: json['currentWeight'],
      goalWeight: json['goalWeight'],
      timelineInDays: json['timelineInDays'],
      maintenanceCalories: json['maintenanceCalories'],
    );
  }

}

