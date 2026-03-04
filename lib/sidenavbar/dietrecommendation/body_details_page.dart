import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';
import 'package:khel_yuva/sidenavbar/dietrecommendation/dietresult.dart';

class BodyDetailsPage extends StatefulWidget {
  const BodyDetailsPage({super.key});

  @override
  State<BodyDetailsPage> createState() => _BodyDetailsPageState();
}

class _BodyDetailsPageState extends State<BodyDetailsPage> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String goal = "Weight Loss";
  String activity = "Moderate";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KY.bg,
      appBar: AppBar(
        backgroundColor: KY.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: KY.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("Body Details"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Your Body Details",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _inputField("Age", ageController),
              const SizedBox(height: 16),
              _inputField("Height (cm)", heightController),
              const SizedBox(height: 16),
              _inputField("Weight (kg)", weightController),
              const SizedBox(height: 24),
              _sectionTitle("Fitness Goal"),
              _goalSelector(),
              const SizedBox(height: 24),
              _sectionTitle("Activity Level"),
              _activitySelector(),
              const SizedBox(height: 30),
              _generateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: KY.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KY.divider),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: KY.textSec),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // GOAL SELECTOR
  // ─────────────────────────────

  Widget _goalSelector() {
    final goals = ["Weight Loss", "Muscle Gain", "Maintain"];

    return Row(
      children: goals.map((g) {
        final selected = goal == g;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                goal = g;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? KY.accent.withValues(alpha: 0.2) : KY.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? KY.accent : KY.divider,
                ),
              ),
              child: Center(
                child: Text(
                  g,
                  style: TextStyle(
                    color: selected ? KY.accent : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────
  // ACTIVITY SELECTOR
  // ─────────────────────────────

  Widget _activitySelector() {
    final levels = ["Low", "Moderate", "High"];

    return Row(
      children: levels.map((a) {
        final selected = activity == a;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                activity = a;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? KY.green.withValues(alpha: 0.2) : KY.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? KY.green : KY.divider,
                ),
              ),
              child: Center(
                child: Text(
                  a,
                  style: TextStyle(
                    color: selected ? KY.green : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────
  // GENERATE BUTTON
  // ─────────────────────────────

  Widget _generateButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DietResultPage(),
          ),
        );
        // Later this will call the ML API
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
            "Generate Diet Plan",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
