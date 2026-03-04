import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';

class DietResultPage extends StatelessWidget {
  const DietResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KY.bg,
      appBar: AppBar(
        backgroundColor: KY.surface,
        title: const Text("Your Diet Plan"),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Daily Nutrition Target"),
              _calorieCard(),
              _sectionTitle("Macronutrients"),
              _macroCard(),
              _sectionTitle("Today's Meal Plan"),
              _mealCard("Breakfast", "Oats + Banana + Milk"),
              _mealCard("Lunch", "Brown Rice + Chicken + Salad"),
              _mealCard("Dinner", "Grilled Fish + Vegetables"),
              const SizedBox(height: 20),
              _regenerateButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // SECTION TITLE
  // ─────────────────────────────

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
  // CALORIE CARD
  // ─────────────────────────────

  Widget _calorieCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: KY.gradientAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daily Calories",
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "2000 kcal",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────
  // MACRO CARD
  // ─────────────────────────────

  Widget _macroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KY.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KY.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _MacroItem("Protein", "120g", KY.green),
            _MacroItem("Carbs", "250g", KY.orange),
            _MacroItem("Fat", "70g", KY.purple),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────
  // MEAL CARD
  // ─────────────────────────────

  Widget _mealCard(String title, String food) {
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: KY.gradientAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(food,
                        style:
                            const TextStyle(color: KY.textSec, fontSize: 12)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────
  // REGENERATE BUTTON
  // ─────────────────────────────

  Widget _regenerateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: KY.gradientAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "Regenerate Plan",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────
// MACRO ITEM
// ─────────────────────────────

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: KY.textSec, fontSize: 12),
        )
      ],
    );
  }
}
