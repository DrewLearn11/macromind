import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_entry.dart';
import '../models/user_goal.dart';
import '../models/weight_log.dart';
import '../models/user.dart';

class StorageService {
  // These are "keys" — like labels on storage boxes.
  // We use the same key to save and retrieve data.
  static const String _goalKey = 'user_goal';
  static const String _foodEntriesKey = 'food_entries';
  static const String _weightLogsKey = 'weight_logs';

  // "static const" means:
  // - "static" → belongs to the class, not a specific instance
  // - "const" → the value never changes (it's a constant)

  // ─────────────────────────────────────────
  // USER GOAL — Save, Load, Clear
  // ─────────────────────────────────────────

  // SAVE USER GOAL
  // "Future<void>" means this function runs asynchronously (in the background)
  // and doesn't return any value when done.
  // "async" means this function can use "await" inside it.
  static Future<void> saveGoal(UserGoal goal) async {
    // Get access to SharedPreferences storage
    final prefs = await SharedPreferences.getInstance();

    // Convert our UserGoal object → Map → JSON String
    // Example result: '{"currentWeight":70.0,"goalWeight":65.0,...}'
    final String jsonString = jsonEncode(goal.toJson());

    // Save the JSON string to storage using our key
    await prefs.setString(_goalKey, jsonString);
  }

  // LOAD USER GOAL
  // "Future<UserGoal?>" means this returns a UserGoal OR null
  // The "?" means it's nullable — it might not exist yet (first time opening app)
  static Future<UserGoal?> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get the saved JSON string using our key
    final String? jsonString = prefs.getString(_goalKey);

    // If nothing was saved yet, return null
    if (jsonString == null) return null;

    // Convert JSON String → Map → UserGoal object
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return UserGoal.fromJson(jsonMap);
  }

  // CLEAR USER GOAL (used when user wants to reset)
  static Future<void> clearGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalKey);
  }

  // ─────────────────────────────────────────
  // FOOD ENTRIES — Save, Load, Add, Delete
  // ─────────────────────────────────────────

  // LOAD ALL FOOD ENTRIES
  // Returns a List of FoodEntry objects
  static Future<List<FoodEntry>> loadFoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_foodEntriesKey);

    // If no food entries saved yet, return an empty list
    if (jsonString == null) return [];

    // JSON String → List of Maps → List of FoodEntry objects
    // "jsonDecode" returns a List here because we saved a List
    final List<dynamic> jsonList = jsonDecode(jsonString);

    // ".map()" loops through each item in the list and converts it
    // "(e)" is each individual Map in the list
    // ".toList()" converts the result back into a List
    return jsonList.map((e) => FoodEntry.fromJson(e)).toList();
  }

  // SAVE ALL FOOD ENTRIES (overwrites everything)
  static Future<void> saveFoodEntries(List<FoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert List of FoodEntry → List of Maps → JSON String
    final String jsonString = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_foodEntriesKey, jsonString);
  }

  // ADD A SINGLE FOOD ENTRY
  // This loads existing entries, adds the new one, then saves everything
  static Future<void> addFoodEntry(FoodEntry entry) async {
    // Load what's already saved
    final List<FoodEntry> entries = await loadFoodEntries();

    // Add the new entry to the list
    entries.add(entry);

    // Save the updated list back to storage
    await saveFoodEntries(entries);
  }

  // DELETE A SINGLE FOOD ENTRY BY ID
  // Each FoodEntry has a unique "id" — we use it to find and remove it
  static Future<void> deleteFoodEntry(String id) async {
    final List<FoodEntry> entries = await loadFoodEntries();

    // ".removeWhere()" removes all items where the condition is true
    // Here we remove the entry whose id matches the one we want to delete
    entries.removeWhere((entry) => entry.id == id);

    await saveFoodEntries(entries);
  }

  // LOAD FOOD ENTRIES FOR TODAY ONLY
  static Future<List<FoodEntry>> loadTodaysFoodEntries() async {
    final List<FoodEntry> allEntries = await loadFoodEntries();
    final DateTime now = DateTime.now();

    // Filter entries where the date matches today
    // We compare year, month, and day (ignoring the time)
    return allEntries.where((entry) {
      return entry.loggedAt.year == now.year &&
          entry.loggedAt.month == now.month &&
          entry.loggedAt.day == now.day;
    }).toList();
  }

  // ─────────────────────────────────────────
  // WEIGHT LOGS — Save, Load, Add
  // ─────────────────────────────────────────

  // LOAD ALL WEIGHT LOGS
  static Future<List<WeightLog>> loadWeightLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_weightLogsKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => WeightLog.fromJson(e)).toList();
  }

  // SAVE ALL WEIGHT LOGS
  static Future<void> saveWeightLogs(List<WeightLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      logs.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_weightLogsKey, jsonString);
  }

  // ADD A SINGLE WEIGHT LOG
  static Future<void> addWeightLog(WeightLog log) async {
    final List<WeightLog> logs = await loadWeightLogs();
    logs.add(log);
    await saveWeightLogs(logs);
  }

  // DELETE ALL DATA (full reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

 // ─────────────────────────────────────────
  // AUTH — Register, Login, Logout
  // ─────────────────────────────────────────

  static const String _usersKey = 'registered_users';
  static const String _loggedInEmailKey = 'logged_in_email';

  // Simple hash function — converts password to a basic encoded string
  // This is NOT cryptographic — just beginner friendly obfuscation
  // For a real app, use a proper hashing package like "crypto"
  static String _hashPassword(String password) {
    int hash = 0;
    for (int i = 0; i < password.length; i++) {
      hash = (hash * 31 + password.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.toString();
  }

  // LOAD ALL REGISTERED USERS
  static Future<List<AppUser>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_usersKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => AppUser.fromJson(e)).toList();
  }

  // SAVE ALL USERS
  static Future<void> _saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      users.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_usersKey, jsonString);
  }

  // REGISTER A NEW USER
  // Returns null if success, or an error message string if failed
  static Future<String?> register(String email, String password) async {
    final List<AppUser> users = await _loadUsers();

    // Check if email already exists
    final bool emailExists = users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );

    if (emailExists) {
      return 'An account with this email already exists.';
    }

    // Add new user with hashed password
    users.add(AppUser(
      email: email.trim().toLowerCase(),
      password: _hashPassword(password),
    ));

    await _saveUsers(users);

    // Automatically log in after registering
    await _setLoggedInEmail(email.trim().toLowerCase());

    return null; // null = success
  }
static Future<String?> login(String email, String password) async {
  final List<AppUser> users = await _loadUsers();

  // Find user by email using a different approach
  // Instead of firstWhere with orElse, we use indexWhere
  final int index = users.indexWhere(
    (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
  );

  // If index is -1, no user was found
  if (index == -1) {
    return 'No account found with this email.';
  }

  // Get the found user
  final AppUser user = users[index];

  // Check if password matches
  if (user.password != _hashPassword(password)) {
    return 'Incorrect password.';
  }

  // Save logged in email
  await _setLoggedInEmail(user.email);

  return null; // null = success
}

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInEmailKey);
  }

  // SAVE LOGGED IN EMAIL
  static Future<void> _setLoggedInEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInEmailKey, email);
  }

  // GET LOGGED IN EMAIL (null if not logged in)
  static Future<String?> getLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedInEmailKey);
  }

  // CHECK IF USER IS LOGGED IN
  static Future<bool> isLoggedIn() async {
    final String? email = await getLoggedInEmail();
    return email != null;
  }

}


