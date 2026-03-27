import 'dart:convert';
import 'package:http/http.dart' as http;

class DietApiService {
  static const String baseUrl = "http://localhost:8000";

  static Future<Map<String, dynamic>> getDiet({
    required int age,
    required double weight,
    required double height,
    required String fitnessGoal,
    required String activityLevel,
  }) async {
    final url = Uri.parse("$baseUrl/recommend");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "age": age,
        "weight": weight,
        "height": height,
        "fitness_goal": fitnessGoal,
        "activity_level": activityLevel,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data; // ⭐ NOW returning FULL JSON MAP
    } else {
      throw Exception("Failed to fetch diet recommendation");
    }
  }
}
