import 'package:flutter/material.dart';

class ActivityResult {
  final int reps;
  final double accuracy;
  final String activityLevel;
  final int xp;
  final String badge;
  final Color color;
  final String icon;

  ActivityResult({
    required this.reps,
    required this.accuracy,
    required this.activityLevel,
    required this.xp,
    required this.badge,
    required this.color,
    required this.icon,
  });
}

class ActivityEngine {
  static ActivityResult analyze({
    required int reps,
    required double accuracy,
  }) {
    final score = reps + (accuracy * 20);

    if (score < 25) {
      return ActivityResult(
        reps: reps,
        accuracy: accuracy,
        activityLevel: "Low Active",
        xp: 30,
        badge: "Beginner",
        color: const Color(0xFF06B6D4),
        icon: "🌱",
      );
    }

    if (score < 60) {
      return ActivityResult(
        reps: reps,
        accuracy: accuracy,
        activityLevel: "Medium Active",
        xp: 70,
        badge: "Consistent",
        color: const Color(0xFFF97316),
        icon: "🔥",
      );
    }

    return ActivityResult(
      reps: reps,
      accuracy: accuracy,
      activityLevel: "Highly Active",
      xp: 150,
      badge: "Athlete",
      color: const Color(0xFF4ADE80),
      icon: "⚡",
    );
  }
}
