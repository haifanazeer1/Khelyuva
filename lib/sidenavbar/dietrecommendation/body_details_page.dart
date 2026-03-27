import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';
import 'package:khel_yuva/sidenavbar/dietrecommendation/dietresult.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khel_yuva/services/diet_api_service.dart';
import 'package:khel_yuva/sidenavbar/dietrecommendation/diet.dart';

class BodyDetailsPage extends StatefulWidget {
  const BodyDetailsPage({super.key});

  @override
  State<BodyDetailsPage> createState() => _BodyDetailsPageState();
}

class _BodyDetailsPageState extends State<BodyDetailsPage> {
  // ─── Text Controllers ───────────────────────────────────────────────────────
  // These capture user input from the text fields
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // ─── Selected Values ────────────────────────────────────────────────────────
  // Default selections shown when the page first loads
  String goal = "Weight Loss";
  String activity = "Moderate";
  bool _isLoading = false;

  // ─── Goal Mapper ────────────────────────────────────────────────────────────
  // Converts the display label (e.g. "Weight Loss") to the exact value
  // stored in the Supabase 'fitness_goal' column CHECK constraint
  String get _mappedGoal {
    switch (goal) {
      case 'Weight Loss':
        return 'lose_weight';
      case 'Muscle Gain':
        return 'gain_muscle';
      case 'Maintain':
        return 'maintain_weight';
      default:
        return 'maintain_weight';
    }
  }

  // ─── Activity Mapper ────────────────────────────────────────────────────────
  // Converts the display label (e.g. "Moderate") to the exact value
  // stored in the Supabase 'activity_level' column CHECK constraint
  String get _mappedActivity {
    switch (activity) {
      case 'Low':
        return 'lightly_active';
      case 'Moderate':
        return 'moderately_active';
      case 'High':
        return 'very_active';
      default:
        return 'sedentary';
    }
  }

  // ─── Dispose ────────────────────────────────────────────────────────────────
  // Always dispose controllers to free memory when the page is removed
  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
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

              // ── Input Fields ──
              _inputField("Age", ageController),
              const SizedBox(height: 16),
              _inputField("Height (cm)", heightController),
              const SizedBox(height: 16),
              _inputField("Weight (kg)", weightController),
              const SizedBox(height: 24),

              // ── Fitness Goal Selector ──
              _sectionTitle("Fitness Goal"),
              const SizedBox(height: 10),
              _goalSelector(),
              const SizedBox(height: 24),

              // ── Activity Level Selector ──
              _sectionTitle("Activity Level"),
              const SizedBox(height: 10),
              _activitySelector(),
              const SizedBox(height: 30),

              // ── Submit Button ──
              _generateButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section Title Widget ───────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  // ─── Reusable Input Field ───────────────────────────────────────────────────
  // Used for Age, Height, and Weight — accepts numbers only
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
        keyboardType: TextInputType.number, // opens number keyboard on mobile
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: KY.textSec),
        ),
      ),
    );
  }

  // ─── Fitness Goal Selector ──────────────────────────────────────────────────
  // Renders 3 tappable buttons; highlights the selected one in accent color
  Widget _goalSelector() {
    final goals = ["Weight Loss", "Muscle Gain", "Maintain"];

    return Row(
      children: goals.map((g) {
        final selected = goal == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => goal = g), // update selected goal
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

  // ─── Activity Level Selector ─────────────────────────────────────────────────
  // Renders 3 tappable buttons; highlights the selected one in green color
  Widget _activitySelector() {
    final levels = ["Low", "Moderate", "High"];

    return Row(
      children: levels.map((a) {
        final selected = activity == a;
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => activity = a), // update selected activity
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

  // ─── Submit to Supabase ──────────────────────────────────────────────────────
  Future<void> _submitDetails() async {
    // Validate: make sure no field is empty before proceeding
    if (ageController.text.trim().isEmpty ||
        heightController.text.trim().isEmpty ||
        weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true); // show loading spinner on button

    try {
      final supabase = Supabase.instance.client;

      // Get the currently logged-in user's ID
      // This is required because RLS policies only allow users to insert their own data

      // Insert data into the 'physical_health' table
      // inside the 'physical_health' schema in Supabase
      // Column names must exactly match what's in Supabase:
      //   age, height_cm, weight_kg, fitness_goal, activity_level, user_id
      await supabase.schema('physical_health').from('physical_health').insert({
        // links row to logged-in user
        'age': int.parse(ageController.text.trim()), // stored as integer
        'height_cm':
            double.parse(heightController.text.trim()), // stored as numeric
        'weight_kg':
            double.parse(weightController.text.trim()), // stored as numeric
        'fitness_goal':
            _mappedGoal, // mapped from "Weight Loss" → "lose_weight" etc.
        'activity_level':
            _mappedActivity, // mapped from "Low" → "lightly_active" etc.
      });

      // Only navigate if the widget is still on screen
      if (mounted) {
        setState(() => _isLoading = false);
        // Go to the diet result page after successful save
        final foods = await DietApiService.getDiet(
          age: int.parse(ageController.text.trim()),
          weight: double.parse(weightController.text.trim()),
          height: double.parse(heightController.text.trim()),
          fitnessGoal: goal,
          activityLevel: activity,
        );

        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DietResultPage(foods: foods)),
        );

        if (result != null && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DietHomePage(foods: result),
            ),
          );
        }
      }
    } catch (e) {
      // Show the error message if anything goes wrong
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save details: $e')),
      );
    }
  }

  // ─── Generate Button ─────────────────────────────────────────────────────────
  // Shows a loading spinner while saving, otherwise shows the button text
  Widget _generateButton() {
    return GestureDetector(
      onTap: _submitDetails,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: KY.gradientAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text(
                  "Generate Diet Plan",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
        ),
      ),
    );
  }
}
