import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:khel_yuva/res/colors.dart';

void main() {
  runApp(const KhelYuva());
}

class KhelYuva extends StatelessWidget {
  const KhelYuva({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KhelYuva',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ── Dashboard State ───────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // ── State ──
  int steps = 98;
  int stepGoal = 3000;
  int caloriesBurned = 0;
  int calorieGoal = 500;
  int foodCalories = 0;
  int baseGoal = 1200;
  bool hasNotifications = true;
  bool isPremium = false;

  // AI toggles
  bool formCorrectionActive = true;
  bool cheatDetectionEnabled = true;
  bool realtimeFeedbackOnline = false;

  // Weekly chart data (Mon–Fri scores)
  List<double> weeklyScores = [50, 55, 60, 70, 75];

  // Animation controller for circular progress
  late AnimationController _progressAnimCtrl;
  late Animation<double> _progressAnim;

  // ── Derived Values ──
  int get remaining =>
      (baseGoal - caloriesBurned + foodCalories).clamp(0, baseGoal * 2);
  double get exerciseProgress =>
      ((baseGoal - remaining) / baseGoal).clamp(0.0, 1.0);
  double get stepsProgress => (steps / stepGoal).clamp(0.0, 1.0);
  double get caloriesProgress => (caloriesBurned / calorieGoal).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _progressAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnim = Tween<double>(begin: 0, end: exerciseProgress).animate(
      CurvedAnimation(parent: _progressAnimCtrl, curve: Curves.easeOutCubic),
    );
    _progressAnimCtrl.forward();
  }

  @override
  void dispose() {
    _progressAnimCtrl.dispose();
    super.dispose();
  }

  void _refreshProgressAnimation() {
    _progressAnim =
        Tween<double>(begin: _progressAnim.value, end: exerciseProgress)
            .animate(CurvedAnimation(
                parent: _progressAnimCtrl, curve: Curves.easeOutCubic));
    _progressAnimCtrl
      ..reset()
      ..forward();
  }

  // ── Log Calories Bottom Sheet ──
  void _showLogCaloriesSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(
        title: 'Log Calories Burned',
        icon: Icons.local_fire_department_rounded,
        iconColor: AppColor.amber,
        hint: 'e.g. 150',
        unit: 'cal',
        controller: controller,
        onConfirm: (val) {
          setState(() {
            caloriesBurned = (caloriesBurned + val).clamp(0, 9999);
            _refreshProgressAnimation();
          });
        },
      ),
    );
  }

  // ── Log Food Bottom Sheet ──
  void _showLogFoodSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(
        title: 'Log Food Intake',
        icon: Icons.restaurant_rounded,
        iconColor: AppColor.cyan,
        hint: 'e.g. 300',
        unit: 'cal',
        controller: controller,
        onConfirm: (val) {
          setState(() {
            foodCalories = (foodCalories + val).clamp(0, 9999);
            _refreshProgressAnimation();
          });
        },
      ),
    );
  }

  // ── Log Steps Bottom Sheet ──
  void _showLogStepsSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(
        title: 'Log Steps',
        icon: Icons.directions_run_rounded,
        iconColor: AppColor.red,
        hint: 'e.g. 500',
        unit: 'steps',
        controller: controller,
        onConfirm: (val) {
          setState(() {
            steps = (steps + val).clamp(0, 99999);
          });
        },
      ),
    );
  }

  // ── Edit Goals Sheet ──
  void _showEditGoalsSheet() {
    final stepCtrl = TextEditingController(text: stepGoal.toString());
    final calGoalCtrl = TextEditingController(text: calorieGoal.toString());
    final baseCtrl = TextEditingController(text: baseGoal.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditGoalsSheet(
        stepCtrl: stepCtrl,
        calGoalCtrl: calGoalCtrl,
        baseCtrl: baseCtrl,
        onSave: (newStepGoal, newCalGoal, newBaseGoal) {
          setState(() {
            stepGoal = newStepGoal;
            calorieGoal = newCalGoal;
            baseGoal = newBaseGoal;
            _refreshProgressAnimation();
          });
        },
      ),
    );
  }

  // ── Notifications Sheet ──
  void _showNotificationsSheet() {
    setState(() => hasNotifications = false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationsSheet(),
    );
  }

  // ── Reset Day ──
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColor.border),
        ),
        title: const Text('Reset Today?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will clear all of today\'s logged data.',
          style: TextStyle(color: AppColor.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColor.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                steps = 0;
                caloriesBurned = 0;
                foodCalories = 0;
                _refreshProgressAnimation();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                _buildSnackBar('Today\'s data has been reset.', AppColor.red),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  SnackBar _buildSnackBar(String msg, Color color) {
    return SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _HeaderSection(
                hasNotifications: hasNotifications,
                onNotificationTap: _showNotificationsSheet,
              ),
              const SizedBox(height: 20),

              // ── Today Header ──
              _TodayHeader(
                onEditTap: _showEditGoalsSheet,
                onResetTap: _showResetDialog,
              ),
              const SizedBox(height: 14),

              // ── Exercise Card ──
              _ExerciseCard(
                remaining: remaining,
                baseGoal: baseGoal,
                foodCalories: foodCalories,
                caloriesBurned: caloriesBurned,
                progressAnimation: _progressAnim,
                onLogFood: _showLogFoodSheet,
                onLogCalories: _showLogCaloriesSheet,
              ),
              const SizedBox(height: 20),

              // ── Steps & Calories ──
              _StepsAndCaloriesRow(
                steps: steps,
                stepGoal: stepGoal,
                stepsProgress: stepsProgress,
                caloriesBurned: caloriesBurned,
                calorieGoal: calorieGoal,
                caloriesProgress: caloriesProgress,
                onAddSteps: _showLogStepsSheet,
                onAddCalories: _showLogCaloriesSheet,
              ),
              const SizedBox(height: 20),

              // ── Progress Chart ──
              _ProgressChart(weeklyScores: weeklyScores),
              const SizedBox(height: 20),

              // ── AI Status Card ──
              _AIStatusCard(
                formCorrectionActive: formCorrectionActive,
                cheatDetectionEnabled: cheatDetectionEnabled,
                realtimeFeedbackOnline: realtimeFeedbackOnline,
                onFormCorrectionToggle: (val) =>
                    setState(() => formCorrectionActive = val),
                onCheatDetectionToggle: (val) =>
                    setState(() => cheatDetectionEnabled = val),
                onRealtimeToggle: (val) =>
                    setState(() => realtimeFeedbackOnline = val),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEETS
// ═══════════════════════════════════════════════════════════════════════════════

class _LogSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final String unit;
  final TextEditingController controller;
  final void Function(int) onConfirm;

  const _LogSheet({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.unit,
    required this.controller,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Input
            Container(
              decoration: BoxDecoration(
                color: AppColor.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.border),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColor.textSecondary),
                  suffixText: unit,
                  suffixStyle: const TextStyle(color: AppColor.textSecondary),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final val = int.tryParse(controller.text) ?? 0;
                  if (val > 0) {
                    onConfirm(val);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Add',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditGoalsSheet extends StatelessWidget {
  final TextEditingController stepCtrl;
  final TextEditingController calGoalCtrl;
  final TextEditingController baseCtrl;
  final void Function(int, int, int) onSave;

  const _EditGoalsSheet({
    required this.stepCtrl,
    required this.calGoalCtrl,
    required this.baseCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Goals',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _GoalField(
                label: 'Daily Step Goal', controller: stepCtrl, unit: 'steps'),
            const SizedBox(height: 12),
            _GoalField(
                label: 'Calories Burn Goal',
                controller: calGoalCtrl,
                unit: 'cal'),
            const SizedBox(height: 12),
            _GoalField(
                label: 'Calorie Base Goal', controller: baseCtrl, unit: 'cal'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final s = int.tryParse(stepCtrl.text) ?? 3000;
                  final c = int.tryParse(calGoalCtrl.text) ?? 500;
                  final b = int.tryParse(baseCtrl.text) ?? 1200;
                  onSave(s, c, b);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Goals',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;

  const _GoalField(
      {required this.label, required this.controller, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColor.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: const TextStyle(color: AppColor.textSecondary),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final notifications = [
      (
        Icons.local_fire_department_rounded,
        AppColor.amber,
        'Calorie goal 80% reached!',
        '2 min ago'
      ),
      (
        Icons.directions_run_rounded,
        AppColor.red,
        'Keep going! 2,902 more steps to goal.',
        '15 min ago'
      ),
      (
        Icons.smart_toy_rounded,
        AppColor.accent,
        'AI detected form issues in last session.',
        '1 hr ago'
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Notifications',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...notifications.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: n.$2.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(n.$1, color: n.$2, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.$3,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                          Text(n.$4,
                              style: const TextStyle(
                                  color: AppColor.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// UI COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _HeaderSection extends StatelessWidget {
  final bool hasNotifications;
  final VoidCallback onNotificationTap;

  const _HeaderSection({
    required this.hasNotifications,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [AppColor.accent, AppColor.pink]),
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              const Icon(Icons.person_rounded, color: Colors.white, size: 24),
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Khel',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              TextSpan(
                text: 'Yuva',
                style: TextStyle(
                    color: AppColor.accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 22),
                if (hasNotifications)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColor.accent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayHeader extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onResetTap;

  const _TodayHeader({required this.onEditTap, required this.onResetTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: AppColor.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Today',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: onResetTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.red.withOpacity(0.3)),
                ),
                child: const Text('Reset',
                    style: TextStyle(
                        color: AppColor.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.accent.withOpacity(0.3)),
                ),
                child: const Text('Edit',
                    style: TextStyle(
                        color: AppColor.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int remaining;
  final int baseGoal;
  final int foodCalories;
  final int caloriesBurned;
  final Animation<double> progressAnimation;
  final VoidCallback onLogFood;
  final VoidCallback onLogCalories;

  const _ExerciseCard({
    required this.remaining,
    required this.baseGoal,
    required this.foodCalories,
    required this.caloriesBurned,
    required this.progressAnimation,
    required this.onLogFood,
    required this.onLogCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exercise',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Today',
                    style: TextStyle(
                        color: AppColor.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Remaining = Goal − Calories Burned + Food',
            style: TextStyle(color: AppColor.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Animated Circular Progress
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: progressAnimation,
                      builder: (_, __) => SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          value: progressAnimation.value,
                          strokeWidth: 10,
                          backgroundColor: AppColor.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColor.accent),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          remaining.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text('kcal left',
                            style: TextStyle(
                                color: AppColor.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatRow(
                      icon: Icons.flag_rounded,
                      iconColor: AppColor.textSecondary,
                      label: 'Base Goal',
                      value: '$baseGoal',
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onLogFood,
                      child: _StatRow(
                        icon: Icons.restaurant_rounded,
                        iconColor: AppColor.cyan,
                        label: 'Food  ＋',
                        value: '$foodCalories cal',
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onLogCalories,
                      child: _StatRow(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: AppColor.amber,
                        label: 'Burned  ＋',
                        value: '$caloriesBurned cal',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColor.textSecondary, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _StepsAndCaloriesRow extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final double stepsProgress;
  final int caloriesBurned;
  final int calorieGoal;
  final double caloriesProgress;
  final VoidCallback onAddSteps;
  final VoidCallback onAddCalories;

  const _StepsAndCaloriesRow({
    required this.steps,
    required this.stepGoal,
    required this.stepsProgress,
    required this.caloriesBurned,
    required this.calorieGoal,
    required this.caloriesProgress,
    required this.onAddSteps,
    required this.onAddCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onAddSteps,
            child: _MiniStatCard(
              title: 'Steps',
              value: '$steps',
              goal: 'Goal: $stepGoal',
              icon: Icons.directions_run_rounded,
              iconColor: AppColor.red,
              progress: stepsProgress,
              progressColor: AppColor.red,
              showAdd: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onAddCalories,
            child: _MiniStatCard(
              title: 'Calories Burned',
              value: '$caloriesBurned cal',
              goal: 'Goal: $calorieGoal cal',
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColor.amber,
              progress: caloriesProgress,
              progressColor: AppColor.amber,
              showAdd: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String goal;
  final IconData icon;
  final Color iconColor;
  final double progress;
  final Color progressColor;
  final bool showAdd;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.goal,
    required this.icon,
    required this.iconColor,
    required this.progress,
    required this.progressColor,
    this.showAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              if (showAdd)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(Icons.add, color: iconColor, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColor.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(goal,
              style:
                  const TextStyle(color: AppColor.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List<double> weeklyScores;

  const _ProgressChart({required this.weeklyScores});

  @override
  Widget build(BuildContext context) {
    final spots = weeklyScores
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble() + 1, e.value))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Performance',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('This Week',
                    style: TextStyle(
                        color: AppColor.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('+25% improvement since last week',
              style: TextStyle(color: AppColor.teal, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 40,
                maxY: 90,
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                        final idx = value.toInt() - 1;
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(days[idx],
                              style: const TextStyle(
                                  color: AppColor.textSecondary, fontSize: 11)),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFF2A2A4A),
                    strokeWidth: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: AppColor.accent,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColor.accent.withOpacity(0.25),
                          AppColor.accent.withOpacity(0.0),
                        ],
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: index == spots.length - 1 ? 5 : 3,
                        color: index == spots.length - 1
                            ? AppColor.accent
                            : Colors.transparent,
                        strokeWidth: index == spots.length - 1 ? 0 : 2,
                        strokeColor: AppColor.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIStatusCard extends StatelessWidget {
  final bool formCorrectionActive;
  final bool cheatDetectionEnabled;
  final bool realtimeFeedbackOnline;
  final ValueChanged<bool> onFormCorrectionToggle;
  final ValueChanged<bool> onCheatDetectionToggle;
  final ValueChanged<bool> onRealtimeToggle;

  const _AIStatusCard({
    required this.formCorrectionActive,
    required this.cheatDetectionEnabled,
    required this.realtimeFeedbackOnline,
    required this.onFormCorrectionToggle,
    required this.onCheatDetectionToggle,
    required this.onRealtimeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final allActive =
        formCorrectionActive && cheatDetectionEnabled && realtimeFeedbackOnline;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColor.accent.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColor.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: AppColor.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Offline AI Feedback',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(
                    allActive
                        ? 'All systems operational'
                        : 'Some systems paused',
                    style: TextStyle(
                        color: allActive ? AppColor.teal : AppColor.amber,
                        fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: allActive
                      ? AppColor.teal.withOpacity(0.15)
                      : AppColor.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  allActive ? 'LIVE' : 'PARTIAL',
                  style: TextStyle(
                    color: allActive ? AppColor.teal : AppColor.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColor.border),
          const SizedBox(height: 16),
          _AIToggleRow(
            icon: Icons.accessibility_new_rounded,
            iconColor: AppColor.accent,
            label: 'Form Correction',
            value: formCorrectionActive,
            onChanged: onFormCorrectionToggle,
          ),
          const SizedBox(height: 10),
          _AIToggleRow(
            icon: Icons.remove_red_eye_rounded,
            iconColor: AppColor.pink,
            label: 'Cheat Detection',
            value: cheatDetectionEnabled,
            onChanged: onCheatDetectionToggle,
          ),
          const SizedBox(height: 10),
          _AIToggleRow(
            icon: Icons.wifi_rounded,
            iconColor: AppColor.amber,
            label: 'Real-time Feedback',
            value: realtimeFeedbackOnline,
            onChanged: onRealtimeToggle,
          ),
        ],
      ),
    );
  }
}

class _AIToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AIToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.accent,
            inactiveThumbColor: AppColor.textSecondary,
            inactiveTrackColor: AppColor.border,
          ),
        ),
      ],
    );
  }
}
