import 'package:flutter/material.dart';
import 'package:khel_yuva/bottomnavbar/exercise_form/real_time_analysis/live_workout.dart';
import 'package:khel_yuva/res/colors.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  final List<String> exercises = ["Pushups", "Plank", "Left Bicep Curl"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: KY.surface,
        title: Text("Select Exercise", style: TextStyle(color: Colors.white)),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: exercises.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveWorkoutScreen(exercise: exercises[index]),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1F3A), Color(0xFF0D1330)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center,
                      color: Colors.cyanAccent, size: 40),
                  SizedBox(height: 10),
                  // FIXED TEXT
                  Text(
                    exercises[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
