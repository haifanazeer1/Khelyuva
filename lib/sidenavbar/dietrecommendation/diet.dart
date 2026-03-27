import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';
import 'package:khel_yuva/sidenavbar/dietrecommendation/body_details_page.dart';
import 'package:khel_yuva/home/homepage.dart';

class DietHomePage extends StatelessWidget {
  final Map<String, dynamic>? foods;
  const DietHomePage({super.key, this.foods});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KY.bg,
      appBar: AppBar(
        backgroundColor: KY.surface,
        title: const Text("Diet Planner"),
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Today's Nutrition"),
              _nutritionSummary(),
              _sectionTitle("Today's Meal Plan"),
              _mealPlan(),
              _sectionTitle("AI Diet Recommendation"),
              _generateDietCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ─────────────────────────────
  // NUTRITION SUMMARY
  // ─────────────────────────────
  Widget _nutritionSummary() {
    // 🔥 If no data yet
    if (foods == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "No nutrition data yet. Generate a plan.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final calories = foods!['target_calories'];
    final protein = foods!['macros']['protein'];
    final carbs = foods!['macros']['carbs'];
    final fat = foods!['macros']['fat'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KY.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KY.divider),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Calories",
                    style: TextStyle(color: KY.textSec, fontSize: 12)),
                Text(
                  "$calories kcal",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔥 Progress bar (dummy progress for now)
            LinearProgressIndicator(
              value: 0.7, // you can make this dynamic later
              backgroundColor: KY.divider,
              valueColor: const AlwaysStoppedAnimation(KY.accent),
              minHeight: 8,
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _macro("Protein", "${protein}g", KY.green),
                _macro("Carbs", "${carbs}g", KY.orange),
                _macro("Fat", "${fat}g", KY.purple),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _macro(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: KY.textSec, fontSize: 12))
      ],
    );
  }

  // ─────────────────────────────
  // MEAL PLAN
  // ─────────────────────────────
  Widget _mealPlan() {
    // 🔥 If no data yet → show placeholder
    if (foods == null || foods!['meals'] == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "No meal plan generated yet. Click Generate.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final meals = [
      {"name": "Breakfast", "food": foods!['meals']['breakfast']},
      {"name": "Lunch", "food": foods!['meals']['lunch']},
      {"name": "Dinner", "food": foods!['meals']['dinner']},
    ];

    return Column(
      children: meals.map((meal) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KY.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: KY.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: KY.gradientAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant,
                      color: Colors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal["name"]!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(meal["food"]!,
                            style: const TextStyle(
                                color: KY.textSec, fontSize: 12)),
                      ]),
                ),
                const Icon(Icons.arrow_forward_ios, color: KY.textSec, size: 14)
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────
  // GENERATE AI DIET
  // ─────────────────────────────
  Widget _generateDietCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: KY.gradientAccent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: KY.accent.withValues(alpha: 0.4),
              blurRadius: 20,
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.psychology, color: Colors.black, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AI Diet Recommendation",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text(
                    "Generate a personalized diet plan",
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  )
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BodyDetailsPage(),
                  ),
                );
              },
              child: const Text("Generate"),
            )
          ],
        ),
      ),
    );
  }
}
