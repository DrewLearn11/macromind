

class WeightLog {
  double weight;
  DateTime loggedAt;

  WeightLog({
    required this.weight,
    required this.loggedAt,
  });

Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  // Convert from Map when loading
  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      weight: json['weight'],
      loggedAt: DateTime.parse(json['loggedAt']),
    );
  }

}