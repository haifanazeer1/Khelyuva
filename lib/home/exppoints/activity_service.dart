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
    return _history.fold(0, (sum, item) => sum + item.xp);
  }

  static int getLevel() {
    final xp = getTotalXP();
    return (xp ~/ 300) + 1;
  }

  static int getStreak() {
    return _history.length;
  }

  static ActivityResult? latestSession() {
    if (_history.isEmpty) return null;
    return _history.first;
  }
}
