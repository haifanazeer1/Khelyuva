import 'package:flutter/material.dart';

class ActivityResult {
  final double kneeAngle;
  final double hipAngle;
  final double shoulderAngle;

  final String activityLevel;
  final int xp;
  final String badge;
  final Color color;
  final String icon;

  ActivityResult({
    required this.kneeAngle,
    required this.hipAngle,
    required this.shoulderAngle,
    required this.activityLevel,
    required this.xp,
    required this.badge,
    required this.color,
    required this.icon,
  });
}

class ActivityEngine {
  static ActivityResult analyze({
    required double knee,
    required double hip,
    required double shoulder,
    required String feedback,
  }) {
    int score = 0;

    if (knee >= 70 && knee <= 120) score += 30;
    if (hip >= 80 && hip <= 150) score += 30;
    if (shoulder >= 80 && shoulder <= 150) score += 30;

    if (feedback.toLowerCase().contains('excellent')) {
      score += 10;
    }

    if (score < 40) {
      return ActivityResult(
        kneeAngle: knee,
        hipAngle: hip,
        shoulderAngle: shoulder,
        activityLevel: "Beginner",
        xp: 30,
        badge: "🌱 Beginner",
        color: const Color(0xFF06B6D4),
        icon: "🌱",
      );
    }

    if (score < 80) {
      return ActivityResult(
        kneeAngle: knee,
        hipAngle: hip,
        shoulderAngle: shoulder,
        activityLevel: "Consistent",
        xp: 70,
        badge: "🔥 Consistent",
        color: const Color(0xFFF97316),
        icon: "🔥",
      );
    }

    return ActivityResult(
      kneeAngle: knee,
      hipAngle: hip,
      shoulderAngle: shoulder,
      activityLevel: "Athlete",
      xp: 150,
      badge: "⚡ Athlete",
      color: const Color(0xFF4ADE80),
      icon: "⚡",
    );
  }
}
