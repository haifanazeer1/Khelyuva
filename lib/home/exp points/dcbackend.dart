// challenge_service.dart
// The glue layer between your analysis backend and the challenge system.
// ─────────────────────────────────────────────────────────────
// HOW IT PLUGS IN:
//   1. Your real-time pose analysis / video analysis calls
//      `ChallengeService.recordPerformance(...)` after each session.
//   2. The service persists records to Hive (offline-first).
//   3. AdaptiveChallengesPage calls `ChallengeService.getDailyChallenges()`
//      which runs the AdaptiveChallengeEngine on the stored records.
//   4. Weekly challenges are fetched from Firestore (online) or
//      cached locally (offline).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
// import 'package:hive_flutter/hive_flutter.dart';       // uncomment when using
// import 'package:cloud_firestore/cloud_firestore.dart'; // uncomment when using

// Re-export from adaptive_challenges_page.dart so callers only import this file.
// import 'adaptive_challenges_page.dart';

/// Raw result from one exercise session.
/// Populate this from your real-time / video analysis pipeline.
class SessionResult {
  const SessionResult({
    required this.athleteId,
    required this.exerciseKey,
    required this.rawValue, // reps, seconds, metres, km
    required this.unit,
    required this.formScore, // 0.0–1.0 from pose/video analysis
    required this.cheatFlags, // list of detected cheat events
    required this.timestampUtc,
    this.videoUrl,
  });

  final String athleteId;
  final String exerciseKey;
  final double rawValue;
  final String unit;
  final double formScore;
  final List<String> cheatFlags; // e.g. ['partial_range', 'knee_cave']
  final DateTime timestampUtc;
  final String? videoUrl;

  /// Effective value after cheat penalty.
  /// Deducts 10% per cheat flag, minimum 50% of raw.
  double get effectiveValue {
    final penalty = (cheatFlags.length * 0.10).clamp(0.0, 0.50);
    return rawValue * (1.0 - penalty);
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'exerciseKey': exerciseKey,
        'rawValue': rawValue,
        'unit': unit,
        'formScore': formScore,
        'cheatFlags': cheatFlags,
        'timestamp': timestampUtc.toIso8601String(),
        'videoUrl': videoUrl,
        'effectiveValue': effectiveValue,
      };
}

/// Singleton service — call ChallengeService.instance anywhere.
class ChallengeService {
  ChallengeService._();
  static final instance = ChallengeService._();

  // In-memory store (replace with Hive box in production).
  final Map<String, List<SessionResult>> _history = {};

  // ── Record a new session result ────────────────────────────
  //
  // Call this from your analysis callback:
  //   ChallengeService.instance.recordPerformance(result);
  //
  Future<void> recordPerformance(SessionResult result) async {
    // 1. Persist to Hive
    // final box = Hive.box<Map>('sessions');
    // await box.add(result.toJson());

    // 2. Update in-memory cache
    _history.putIfAbsent(result.exerciseKey, () => []);
    _history[result.exerciseKey]!.add(result);

    // 3. Optionally sync to Firestore when online
    // await FirebaseFirestore.instance
    //     .collection('athletes/${result.athleteId}/sessions')
    //     .add(result.toJson());

    debugPrint('[ChallengeService] recorded ${result.exerciseKey}: '
        '${result.effectiveValue} ${result.unit} '
        '(form=${result.formScore.toStringAsFixed(2)}, '
        'cheats=${result.cheatFlags})');
  }

  // ── Build PerformanceRecord list from stored history ───────
  //
  // Uses the best EFFECTIVE value from the last 7 days per exercise.
  //
  List<PerformanceRecord> getRecentBests({int lookbackDays = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: lookbackDays));
    final records = <PerformanceRecord>[];

    _history.forEach((key, sessions) {
      final recent = sessions
          .where((s) => s.timestampUtc.isAfter(cutoff))
          .toList()
        ..sort((a, b) => b.effectiveValue.compareTo(a.effectiveValue));

      if (recent.isEmpty) return;

      final best = recent.first;
      // Average form score across recent sessions for a stable signal.
      final avgForm =
          recent.fold(0.0, (s, r) => s + r.formScore) / recent.length;

      records.add(PerformanceRecord(
        exerciseKey: key,
        bestValue: best.effectiveValue,
        unit: best.unit,
        lastUpdated: best.timestampUtc,
        formScore: avgForm,
      ));
    });

    return records;
  }

  // ── Generate today's adaptive daily challenges ─────────────
  List<AdaptiveChallenge> getDailyChallenges() {
    final bests = getRecentBests();
    if (bests.isEmpty) return _defaultChallenges();
    return AdaptiveChallengeEngine.generate(bests);
  }

  // ── Weekly challenge submission ────────────────────────────
  //
  // Called when athlete submits video for a weekly challenge.
  // Your backend verifies the video; on success call this.
  //
  Future<void> submitWeeklyResult({
    required String athleteId,
    required int challengeId,
    required double value,
    required String videoUrl,
    required double formScore,
  }) async {
    // await FirebaseFirestore.instance
    //     .collection('weekly_submissions')
    //     .add({
    //       'athleteId':   athleteId,
    //       'challengeId': challengeId,
    //       'value':       value,
    //       'videoUrl':    videoUrl,
    //       'formScore':   formScore,
    //       'submittedAt': FieldValue.serverTimestamp(),
    //     });

    // Cloud Function picks this up, re-ranks leaderboard, awards LP + XP.
    debugPrint('[ChallengeService] weekly submission: '
        'challenge=$challengeId value=$value form=${formScore.toStringAsFixed(2)}');
  }

  // ── Fallback if no history yet ─────────────────────────────
  List<AdaptiveChallenge> _defaultChallenges() => [
        AdaptiveChallenge(
          id: 1,
          exerciseKey: 'pushups',
          title: 'Push-Up Baseline',
          description: 'No data yet — complete as many as you can.',
          targetValue: 10,
          unit: 'reps',
          previousBest: 0,
          xp: 50,
          category: 'Strength',
          icon: '💪',
          difficulty: 'Adaptive',
          adaptationNote: '📊 First session — sets your personal baseline',
        ),
        AdaptiveChallenge(
          id: 2,
          exerciseKey: 'run_5km',
          title: 'Easy Run',
          description: 'A 1 km warm-up run to establish your baseline pace.',
          targetValue: 1.0,
          unit: 'km',
          previousBest: 0,
          xp: 40,
          category: 'Endurance',
          icon: '🏃',
          difficulty: 'Adaptive',
          adaptationNote: '📊 First session — sets your baseline pace',
        ),
      ];
}

// ─────────────────────────────────────────────────────────────
//  HOOK INTO YOUR EXISTING ANALYSIS PIPELINE
// ─────────────────────────────────────────────────────────────
//
// In your real-time pose analysis callback (wherever MediaPipe /
// TFLite fires after a set is detected):
//
//   void onSetCompleted(String exerciseKey, int reps, double formScore,
//       List<String> cheats) {
//     ChallengeService.instance.recordPerformance(SessionResult(
//       athleteId:    currentUser.uid,
//       exerciseKey:  exerciseKey,
//       rawValue:     reps.toDouble(),
//       unit:         'reps',
//       formScore:    formScore,
//       cheatFlags:   cheats,
//       timestampUtc: DateTime.now().toUtc(),
//     ));
//   }
//
// In your video analysis result handler (cloud response):
//
//   void onVideoAnalysisResult(VideoAnalysisResult result) {
//     ChallengeService.instance.recordPerformance(SessionResult(
//       athleteId:    result.athleteId,
//       exerciseKey:  result.exercise,
//       rawValue:     result.repCount.toDouble(),
//       unit:         'reps',
//       formScore:    result.formScore,
//       cheatFlags:   result.cheatFlags,
//       timestampUtc: result.timestamp,
//       videoUrl:     result.videoUrl,
//     ));
//   }
//

// Stub classes so this file compiles standalone. Remove if importing
// from adaptive_challenges_page.dart.
class PerformanceRecord {
  const PerformanceRecord({
    required this.exerciseKey,
    required this.bestValue,
    required this.unit,
    required this.lastUpdated,
    this.formScore = 0.0,
  });
  final String exerciseKey;
  final double bestValue;
  final String unit;
  final DateTime lastUpdated;
  final double formScore;
}

class AdaptiveChallenge {
  AdaptiveChallenge({
    required this.id,
    required this.exerciseKey,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.unit,
    required this.previousBest,
    required this.xp,
    required this.category,
    required this.icon,
    required this.difficulty,
    required this.adaptationNote,
    this.isClaimed = false,
  });
  final int id;
  final String exerciseKey,
      title,
      description,
      unit,
      category,
      icon,
      difficulty,
      adaptationNote;
  final double targetValue, previousBest;
  final int xp;
  bool isClaimed;
}

class AdaptiveChallengeEngine {
  static const _baseGrowth = 0.20;
  static const _stretchGrowth = 0.40;

  static List<AdaptiveChallenge> generate(List<PerformanceRecord> records) {
    final out = <AdaptiveChallenge>[];
    var id = 1;
    for (final r in records) {
      final growth = r.formScore >= 0.80 ? _stretchGrowth : _baseGrowth;
      final target = _round(r.bestValue * (1 + growth), r.unit);
      final delta = target - r.bestValue;
      out.add(AdaptiveChallenge(
        id: id++,
        exerciseKey: r.exerciseKey,
        title: _titles[r.exerciseKey] ?? r.exerciseKey,
        description:
            'Best: ${_fmt(r.bestValue, r.unit)} → Today: ${_fmt(target, r.unit)}',
        targetValue: target,
        unit: r.unit,
        previousBest: r.bestValue,
        xp: _xp(target, r.unit, growth),
        category: _cats[r.exerciseKey] ?? 'General',
        icon: _icons[r.exerciseKey] ?? '🏋️',
        difficulty: growth >= _stretchGrowth ? 'Stretch' : 'Adaptive',
        adaptationNote: '↑ ${_fmt(delta, r.unit)} above your best  •  '
            '${r.formScore >= 0.80 ? '⚡ Great form bonus!' : '📈 Keep improving'}',
      ));
    }
    return out;
  }

  static double _round(double v, String u) {
    if (u == 'reps') return v.ceilToDouble();
    return (v * 10).ceilToDouble() / 10;
  }

  static int _xp(double t, String u, double g) {
    final b = switch (u) { 'reps' => t * 2.5, 'km' => t * 30, _ => 60.0 };
    return (b * (1 + g)).round().clamp(30, 500);
  }

  static String _fmt(double v, String u) => switch (u) {
        'reps' => '${v.toInt()} reps',
        'km' => '${v.toStringAsFixed(1)} km',
        _ => '${v.toStringAsFixed(1)} $u',
      };

  static const _titles = {
    'pullups': 'Pull-Ups',
    'pushups': 'Push-Ups',
    'squats': 'Jump Squats',
    'sprint_100m': '100m Sprint',
    'run_5km': '5 km Run',
    'plank_seconds': 'Plank Hold',
    'burpees': 'Burpees',
  };
  static const _cats = {
    'pullups': 'Strength',
    'pushups': 'Strength',
    'squats': 'Power',
    'sprint_100m': 'Speed',
    'run_5km': 'Endurance',
    'plank_seconds': 'Core',
    'burpees': 'Conditioning',
  };
  static const _icons = {
    'pullups': '🏋️',
    'pushups': '💪',
    'squats': '⚡',
    'sprint_100m': '🏃',
    'run_5km': '🛤️',
    'plank_seconds': '🔵',
    'burpees': '💥',
  };
}
