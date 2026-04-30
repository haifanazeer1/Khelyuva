// ALL shared domain models + AdaptiveChallengeEngine live here.
/// backend / AI engine populates this and passes it to the engine.
class PerformanceRecord {
  const PerformanceRecord({
    required this.exerciseKey,
    required this.bestValue,
    required this.unit,
    required this.lastUpdated,
    this.formScore = 0.0,
  });

  /// e.g. 'pullups', 'sprint_100m'
  final String exerciseKey;

  /// reps, seconds, metres, km — depends on unit
  final double bestValue;

  /// 'reps' | 'seconds' | 'metres' | 'km'
  final String unit;

  final DateTime lastUpdated;

  /// 0.0–1.0 from pose/video analysis
  final double formScore;
}

/// A single adaptive daily challenge derived from a PerformanceRecord.
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
  final String exerciseKey;
  final String title;
  final String description;
  final double targetValue;
  final String unit;
  final double previousBest;
  final int xp;
  final String category;
  final String icon;
  final String difficulty;
  final String adaptationNote;

  bool isClaimed;
}

/// Weekly elite challenge - harder, fixed targets used to rank
/// athletes on the global leaderboard.
class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.unit,
    required this.xp,
    required this.leaderboardPoints,
    required this.category,
    required this.icon,
    required this.endDate,
    required this.totalParticipants,
    this.userRank,
    this.userProgress = 0.0,
    this.isJoined = false,
  });

  final int id;
  final String title;
  final String description;
  final double targetValue;
  final String unit;
  final int xp;

  /// Feeds global leaderboard ranking
  final int leaderboardPoints;

  final String category;
  final String icon;
  final String endDate;
  final int totalParticipants;
  final int? userRank;

  /// 0.0–1.0
  final double userProgress;

  final bool isJoined;
}

class AdaptiveChallengeEngine {
  AdaptiveChallengeEngine._();

  static const _baseGrowth = 0.20;
  static const _stretchGrowth = 0.40;

  static List<AdaptiveChallenge> generate(List<PerformanceRecord> records) {
    final challenges = <AdaptiveChallenge>[];
    var id = 1;

    for (final record in records) {
      final growth = record.formScore >= 0.80 ? _stretchGrowth : _baseGrowth;
      final target = _roundTarget(record.bestValue * (1 + growth), record.unit);
      final delta = target - record.bestValue;

      final difficulty = growth >= _stretchGrowth ? 'Stretch' : 'Adaptive';

      challenges.add(AdaptiveChallenge(
        id: id++,
        exerciseKey: record.exerciseKey,
        title: _titles[record.exerciseKey] ?? record.exerciseKey,
        description: _buildDesc(record, target),
        targetValue: target,
        unit: record.unit,
        previousBest: record.bestValue,
        xp: _calcXP(target, record.unit, growth),
        category: _categories[record.exerciseKey] ?? 'General',
        icon: _icons[record.exerciseKey] ?? '🏋️',
        difficulty: difficulty,
        adaptationNote: _adaptNote(delta, record.unit, record.formScore),
      ));
    }
    return challenges;
  }

  static double _roundTarget(double raw, String unit) {
    if (unit == 'reps') return raw.ceilToDouble();
    if (unit == 'seconds') return (raw * 10).ceilToDouble() / 10;
    if (unit == 'km') return (raw * 10).ceilToDouble() / 10;
    return (raw * 100).ceilToDouble() / 100;
  }

  static int _calcXP(double target, String unit, double growth) {
    final base = switch (unit) {
      'reps' => target * 2.5,
      'km' => target * 30,
      'seconds' => target * 0.8,
      _ => 60.0,
    };
    return (base * (1 + growth)).round().clamp(30, 500);
  }

  static String _buildDesc(PerformanceRecord r, double target) {
    final prev = _fmt(r.bestValue, r.unit);
    final tgt = _fmt(target, r.unit);
    return 'Your best: $prev  →  Today\'s target: $tgt';
  }

  static String _adaptNote(double delta, String unit, double formScore) {
    final d = _fmt(delta, unit);
    final formTag =
        formScore >= 0.80 ? '⚡ Great form bonus!' : '📈 Keep improving';
    return '↑ $d above your best  •  $formTag';
  }

  static String _fmt(double v, String unit) => switch (unit) {
        'reps' => '${v.toInt()} reps',
        'km' => '${v.toStringAsFixed(1)} km',
        'seconds' => '${v.toStringAsFixed(1)} s',
        _ => '${v.toStringAsFixed(1)} $unit',
      };

  static const _titles = <String, String>{
    'pullups': 'Pull-Ups',
    'pushups': 'Push-Ups',
    'squats': 'Jump Squats',
    'sprint_100m': '100m Sprint',
    'run_5km': '5 km Run',
    'plank_seconds': 'Plank Hold',
    'burpees': 'Burpees',
  };

  static const _categories = <String, String>{
    'pullups': 'Strength',
    'pushups': 'Strength',
    'squats': 'Power',
    'sprint_100m': 'Speed',
    'run_5km': 'Endurance',
    'plank_seconds': 'Core',
    'burpees': 'Conditioning',
  };

  static const _icons = <String, String>{
    'pullups': '🏋️',
    'pushups': '💪',
    'squats': '⚡',
    'sprint_100m': '🏃',
    'run_5km': '🛤️',
    'plank_seconds': '🔵',
    'burpees': '💥',
  };
}
