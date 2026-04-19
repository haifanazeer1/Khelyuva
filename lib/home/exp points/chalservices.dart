// challenge_service.dart
// ─────────────────────────────────────────────────────────────
// Glue layer between your analysis backend and the challenge system.
//
// HOW IT PLUGS IN:
//   1. Your real-time pose analysis / video analysis calls
//      ChallengeService.instance.recordPerformance(...) after each set.
//   2. The service persists records to Hive (offline-first).
//   3. AdaptiveChallengesPage calls ChallengeService.instance
//      .getDailyChallenges() which runs AdaptiveChallengeEngine on
//      the stored records.
//   4. Weekly challenges are fetched from Firestore (online) or
//      cached locally (offline).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'chalmodel.dart';

// Uncomment when adding persistence / cloud sync:
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

export 'chalmodel.dart'; // re-export so callers only need this file

// ── Session Result ─────────────────────────────────────────────
//
// Populate this from your real-time / video analysis pipeline.
// Pass an instance to ChallengeService.instance.recordPerformance().

class SessionResult {
  const SessionResult({
    required this.athleteId,
    required this.exerciseKey,
    required this.rawValue,
    required this.unit,
    required this.formScore,
    required this.cheatFlags,
    required this.timestampUtc,
    this.videoUrl,
  });

  final String athleteId;
  final String exerciseKey;

  /// Reps, seconds, metres, or km — raw value before cheat penalty
  final double rawValue;
  final String unit;

  /// 0.0–1.0 from pose / video analysis
  final double formScore;

  /// e.g. ['partial_range', 'knee_cave']
  final List<String> cheatFlags;

  final DateTime timestampUtc;
  final String? videoUrl;

  /// Effective value after cheat penalty.
  /// Deducts 10 % per cheat flag, floored at 50 % of raw value.
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

// ── Singleton Service ──────────────────────────────────────────

/// Singleton — call ChallengeService.instance from anywhere.
class ChallengeService {
  ChallengeService._();
  static final instance = ChallengeService._();

  // In-memory store.  Replace with a Hive box in production.
  final _history = <String, List<SessionResult>>{};

  // ── Record a new session result ──────────────────────────────
  //
  // Call from your real-time pose analysis callback:
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
  // Call from your video analysis result handler:
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

  Future<void> recordPerformance(SessionResult result) async {
    // ── Step 1: Persist to Hive ──────────────────────────────
    // final box = Hive.box<Map>('sessions');
    // await box.add(result.toJson());

    // ── Step 2: Update in-memory cache ───────────────────────
    _history.putIfAbsent(result.exerciseKey, () => []);
    _history[result.exerciseKey]!.add(result);

    // ── Step 3: Sync to Firestore when online ────────────────
    // await FirebaseFirestore.instance
    //     .collection('athletes/${result.athleteId}/sessions')
    //     .add(result.toJson());

    debugPrint('[ChallengeService] recorded ${result.exerciseKey}: '
        '${result.effectiveValue} ${result.unit} '
        '(form=${result.formScore.toStringAsFixed(2)}, '
        'cheats=${result.cheatFlags})');
  }

  // ── Build PerformanceRecord list from stored history ─────────
  //
  // Uses the best EFFECTIVE value from the last [lookbackDays] days
  // per exercise.  Average form score across recent sessions gives
  // a stable signal for the difficulty bump.

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
      final avgForm =
          recent.fold(0.0, (sum, r) => sum + r.formScore) / recent.length;

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

  // ── Generate today's adaptive daily challenges ───────────────

  List<AdaptiveChallenge> getDailyChallenges() {
    final bests = getRecentBests();
    return bests.isEmpty
        ? _defaultChallenges()
        : AdaptiveChallengeEngine.generate(bests);
  }

  // ── Weekly challenge video submission ────────────────────────
  //
  // Called after your backend verifies the athlete's video.

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
    //       'athleteId'   : athleteId,
    //       'challengeId' : challengeId,
    //       'value'       : value,
    //       'videoUrl'    : videoUrl,
    //       'formScore'   : formScore,
    //       'submittedAt' : FieldValue.serverTimestamp(),
    //     });
    // Cloud Function picks this up, re-ranks leaderboard, awards LP + XP.

    debugPrint('[ChallengeService] weekly submission: '
        'challenge=$challengeId value=$value '
        'form=${formScore.toStringAsFixed(2)}');
  }

  // ── Fallback challenges when no history exists yet ───────────

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
