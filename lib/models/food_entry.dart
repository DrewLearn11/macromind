
class FoodEntry {
  String id;
  String name;
  double calories;
  double servingSize;
  DateTime loggedAt;

FoodEntry({
  required this.id,
  required this.name,
  required this.calories,
  required this.servingSize,
  required this.loggedAt,

});

Map<String, dynamic> toJson(){
  return {
    'id': id,
    'name': name,
    'calories': calories,
    'servingSize': servingSize,
    'loggedAt' : loggedAt.toIso8601String(),
  };
}

factory FoodEntry.fromJson(Map<String, dynamic> json){
  return FoodEntry(
    id:json['id'],
    name:json['name'],
    calories:json['calories'],
    servingSize:json['servingSize'],
    loggedAt: DateTime.parse(json['loggedAt']),
  );
}


}

