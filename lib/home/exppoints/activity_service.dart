import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'activity_model.dart';

class ActivityService {
  static final List<ActivityResult> _history = [];

  static void addSession(ActivityResult result) {
    _history.insert(0, result);
  }

  static List<ActivityResult> getHistory() {
    return _history;
  }

  static int getTotalXP() {
    return _history.fold(
      0,
      (sum, item) => sum + item.xp,
    );
  }

  static int getLevel() {
    final xp = getTotalXP();

    if (xp < 300) return 1;
    if (xp < 600) return 2;
    if (xp < 1000) return 3;
    if (xp < 1500) return 4;

    return 5;
  }

  static int getStreak() {
    return _history.length;
  }

  static ActivityResult? latestSession() {
    if (_history.isEmpty) return null;
    return _history.first;
  }

  static Future<ActivityResult?> getLatestSession() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return null;

    final data = await Supabase.instance.client
        .from('session_results')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;

    return ActivityResult(
      kneeAngle: (data['knee_angle'] as num).toDouble(),
      hipAngle: (data['hip_angle'] as num).toDouble(),
      shoulderAngle: (data['shoulder_angle'] as num).toDouble(),
      activityLevel: data['activity_level'],
      badge: data['badge'],
      xp: data['xp'],
      color: _getColor(data['activity_level']),
      icon: _getIcon(data['activity_level']),
    );
  }

  static Color _getColor(String level) {
    switch (level) {
      case 'Athlete':
        return const Color(0xFF4ADE80);

      case 'Consistent':
        return const Color(0xFFF97316);

      default:
        return const Color(0xFF06B6D4);
    }
  }

  static String _getIcon(String level) {
    switch (level) {
      case 'Athlete':
        return '⚡';

      case 'Consistent':
        return '🔥';

      default:
        return '🌱';
    }
  }
}
