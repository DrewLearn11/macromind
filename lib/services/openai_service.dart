// openai_service.dart
// This file handles all communication with the OpenAI API.
// It sends the user's health data and gets back a personalized
// calorie recommendation with explanation.

import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  // ⚠️ Replace with your actual OpenAI API key
  static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  // Send user data to OpenAI and get calorie recommendation
  static Future<Map<String, dynamic>> getCalorieRecommendation({
    required double currentWeight,
    required double goalWeight,
    required double height,
    required int age,
    required String sex,
    required String activityLevel,
    required int timelineInDays,
    required double bmr,
    required double tdee,
  }) async {
    // Build a detailed prompt for OpenAI
    final String prompt = '''
You are a professional nutritionist and fitness expert. 
A user wants personalized calorie intake advice based on their profile.

User Profile:
- Current Weight: ${currentWeight}kg
- Goal Weight: ${goalWeight}kg
- Height: ${height}cm
- Age: $age years old
- Sex: $sex
- Activity Level: $activityLevel
- Timeline: $timelineInDays days to reach goal
- Calculated BMR: ${bmr.toStringAsFixed(0)} kcal/day
- Calculated TDEE: ${tdee.toStringAsFixed(0)} kcal/day

Please provide:
1. Recommended daily calorie intake (just a number in kcal)
2. A brief explanation (2-3 sentences) of why this amount
3. A simple tip for reaching their goal safely

Respond ONLY in this exact JSON format, no extra text:
{
  "recommendedCalories": 1800,
  "explanation": "Your explanation here.",
  "tip": "Your tip here.",
  "isGoalSafe": true,
  "warningMessage": ""
}

If the goal is unsafe (too aggressive), set isGoalSafe to false and provide a warningMessage.
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional nutritionist. Always respond with valid JSON only.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 300,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];

        // Parse the JSON response from OpenAI
        final Map<String, dynamic> result = jsonDecode(content);
        return result;
      } else {
        // API error — return a fallback using TDEE
        return {
          'recommendedCalories': tdee.toInt(),
          'explanation': 'Based on your TDEE calculation, this is your estimated daily calorie need.',
          'tip': 'Aim for a moderate deficit of 300-500 kcal/day for safe weight loss.',
          'isGoalSafe': true,
          'warningMessage': '',
        };
      }
    } catch (e) {
      // Network error — return fallback
      return {
        'recommendedCalories': tdee.toInt(),
        'explanation': 'Could not connect to AI. Using your calculated TDEE instead.',
        'tip': 'Aim for a moderate deficit of 300-500 kcal/day for safe weight loss.',
        'isGoalSafe': true,
        'warningMessage': '',
      };
    }
  }
}