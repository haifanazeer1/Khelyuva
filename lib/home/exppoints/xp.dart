import 'package:flutter/material.dart';
import 'activity_model.dart';
import 'activity_service.dart';

const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF111827);
const _cardD = Color(0xFF0F172A);
const _cyan = Color(0xFF06B6D4);
const _indigo = Color(0xFF6366F1);
const _gold = Color(0xFFFBBF24);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFF97316);
const _red = Color(0xFFEF4444);
const _purple = Color(0xFF8B5CF6);
const _muted = Color(0xFF64748B);
const _sub = Color(0xFF475569);
const _slate = Color(0xFF94A3B8);

class XPPage extends StatefulWidget {
  const XPPage({super.key});

  @override
  State<XPPage> createState() => _XPPageState();
}

class _XPPageState extends State<XPPage> {
  late ActivityResult current;

  @override
  void initState() {
    super.initState();

    current = ActivityEngine.analyze(
      reps: 42,
      accuracy: 0.86,
    );

    ActivityService.addSession(current);
  }

  @override
  Widget build(BuildContext context) {
    final totalXP = ActivityService.getTotalXP();
    final level = ActivityService.getLevel();
    final streak = ActivityService.getStreak();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // HEADER
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "XP Experience Hub",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "AI-powered activity tracking",
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      const Text("🔥"),
                      const SizedBox(width: 6),
                      Text(
                        "$streak Day Streak",
                        style: const TextStyle(
                          color: _red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // HERO CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_card, _cardD],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _gold.withOpacity(0.20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_gold, _orange],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        "Lv.$level",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total XP",
                          style: TextStyle(
                            color: _muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$totalXP",
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: totalXP / 1000,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.06),
                          valueColor: const AlwaysStoppedAnimation(_cyan),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ACTIVITY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_card, _cardD],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Activity",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: current.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            current.icon,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.activityLevel,
                              style: TextStyle(
                                color: current.color,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${current.reps} repetitions detected",
                              style: const TextStyle(
                                color: _slate,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Accuracy ${(current.accuracy * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                color: _slate,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              current.color,
                              current.color.withOpacity(0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "+${current.xp} XP",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: current.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      current.activityLevel == "Highly Active"
                          ? "Excellent performance! Athlete mode unlocked ⚡"
                          : current.activityLevel == "Medium Active"
                              ? "Nice work! You're improving 🔥"
                              : "Good start! Keep moving 💪",
                      style: TextStyle(
                        color: current.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BADGES
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_card, _cardD],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Achievements",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _badge("🥇", "Beginner"),
                      _badge("🔥", "Consistent"),
                      _badge("⚡", "Athlete"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String icon, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_indigo, _purple],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: _slate,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
