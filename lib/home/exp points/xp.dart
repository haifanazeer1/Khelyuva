// • switch expressions, records, pattern matching
// • AnimationController late-init via field initializer

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/*  STATIC DATA
const kUserXP = 620;
const kNextLevelXP = 1000;
const kLevel = 7;
const kStreak = 12;
*/
int userXP = 0;
int userLevel = 1;
int streak = 0;
const kNextLevelXP = 1000;
bool isLoading = true;

typedef XPEvent = ({
  int id,
  String action,
  int xp,
  String type,
  String time,
  String icon,
  Color color
});
typedef Challenge = ({
  int id,
  String title,
  int xp,
  String difficulty,
  String category,
  String icon
});
typedef Competition = ({
  int id,
  String title,
  int xp,
  int participants,
  int? rank,
  String endDate,
  String icon
});
typedef Reward = ({int level, String reward, String icon, bool unlocked});

const _history = <XPEvent>[
  (
    id: 1,
    action: 'Completed Morning Run',
    xp: 80,
    type: 'workout',
    time: 'Today, 6:30 AM',
    icon: '🏃',
    color: _cyan
  ),
  (
    id: 2,
    action: 'Daily Challenge: 100 Push-ups',
    xp: 150,
    type: 'challenge',
    time: 'Today, 8:00 AM',
    icon: '💪',
    color: _orange
  ),
  (
    id: 3,
    action: 'Warm Up Session',
    xp: 30,
    type: 'workout',
    time: 'Yesterday, 7:00 AM',
    icon: '🔥',
    color: _cyan
  ),
  (
    id: 4,
    action: 'Jump Squats (3×15)',
    xp: 60,
    type: 'workout',
    time: 'Yesterday, 7:30 AM',
    icon: '⚡',
    color: _cyan
  ),
  (
    id: 5,
    action: 'Sprint Drills Competition',
    xp: 200,
    type: 'competition',
    time: '2 days ago',
    icon: '🏆',
    color: _gold
  ),
  (
    id: 6,
    action: 'Core Circuit',
    xp: 50,
    type: 'workout',
    time: '3 days ago',
    icon: '🔵',
    color: _cyan
  ),
  (
    id: 7,
    action: 'Weekly Goal Achieved',
    xp: 300,
    type: 'milestone',
    time: '4 days ago',
    icon: '🎯',
    color: _green
  ),
  (
    id: 8,
    action: '7-Day Streak Bonus',
    xp: 100,
    type: 'streak',
    time: '4 days ago',
    icon: '🔥',
    color: _red
  ),
];

const challenges = <Challenge>[
  (
    id: 1,
    title: '200 Jump Ropes',
    xp: 120,
    difficulty: 'Medium',
    category: 'Cardio',
    icon: '🪢'
  ),
  (
    id: 2,
    title: '50 Burpees Challenge',
    xp: 180,
    difficulty: 'Hard',
    category: 'Strength',
    icon: '💥'
  ),
  (
    id: 3,
    title: '15 min Meditation',
    xp: 60,
    difficulty: 'Easy',
    category: 'Recovery',
    icon: '🧘'
  ),
  (
    id: 4,
    title: '5km Run or Walk',
    xp: 150,
    difficulty: 'Medium',
    category: 'Endurance',
    icon: '🏃'
  ),
];

const _competitions = <Competition>[
  (
    id: 1,
    title: 'March Sprint King',
    xp: 500,
    participants: 248,
    rank: 12,
    endDate: 'Mar 10',
    icon: '⚡'
  ),
  (
    id: 2,
    title: 'Core Challenge Cup',
    xp: 350,
    participants: 183,
    rank: null,
    endDate: 'Mar 15',
    icon: '🎯'
  ),
  (
    id: 3,
    title: 'Endurance Elite',
    xp: 800,
    participants: 97,
    rank: null,
    endDate: 'Mar 20',
    icon: '🏆'
  ),
];

const _rewards = <Reward>[
  (level: 5, reward: '1 Free Basic Consult', icon: '📞', unlocked: true),
  (level: 10, reward: 'Exclusive Training Plans', icon: '📋', unlocked: false),
  (level: 15, reward: '2 Premium Sessions', icon: '⭐', unlocked: false),
  (level: 20, reward: 'VIP Trainer Access', icon: '👑', unlocked: false),
];

const _weeklyData = <({String day, int xp})>[
  (day: 'Mon', xp: 140),
  (day: 'Tue', xp: 210),
  (day: 'Wed', xp: 80),
  (day: 'Thu', xp: 300),
  (day: 'Fri', xp: 190),
  (day: 'Sat', xp: 0),
  (day: 'Sun', xp: 0),
];

const _tabs = ['Overview', 'Challenges', 'Competitions', 'Rewards', 'History'];

//  PAGE
class XPPage extends StatefulWidget {
  const XPPage({super.key});
  @override
  State<XPPage> createState() => _XPPageState();
}

class _XPPageState extends State<XPPage> with TickerProviderStateMixin {
  var _tabIndex = 0;
  var _displayXP = 0;
  var _xpPopText = '';
  var _showPop = false;

  final Set<int> _claimed = {1};
  final Set<int> _joined = {1};

  Timer? _countTimer;
  List<Challenge> generateAdaptiveChallenges() {
    if (sessionResults.isEmpty) {
      return [
        (
          id: 1,
          title: 'Complete Your First Workout',
          xp: 50,
          difficulty: 'Easy',
          category: 'Starter',
          icon: '🔥'
        ),
      ];
    }

    final lastSession = sessionResults.first;

    final reps = lastSession['reps'] ?? 0;
    final accuracy = lastSession['accuracy'] ?? 0;

    // HARD USER
    if (reps > 40 && accuracy > 85) {
      return [
        (
          id: 1,
          title: '60 Pushups Challenge',
          xp: 200,
          difficulty: 'Hard',
          category: 'Strength',
          icon: '💪'
        ),
        (
          id: 2,
          title: '5km Endurance Run',
          xp: 180,
          difficulty: 'Hard',
          category: 'Cardio',
          icon: '🏃'
        ),
      ];
    }

    // MEDIUM USER
    if (reps > 20) {
      return [
        (
          id: 1,
          title: '35 Pushups Challenge',
          xp: 120,
          difficulty: 'Medium',
          category: 'Strength',
          icon: '🔥'
        ),
        (
          id: 2,
          title: '2km Run',
          xp: 100,
          difficulty: 'Medium',
          category: 'Cardio',
          icon: '🏃'
        ),
      ];
    }

    // BEGINNER USER
    return [
      (
        id: 1,
        title: '15 Pushups Challenge',
        xp: 60,
        difficulty: 'Easy',
        category: 'Starter',
        icon: '✨'
      ),
      (
        id: 2,
        title: '10 Minute Walk',
        xp: 40,
        difficulty: 'Easy',
        category: 'Recovery',
        icon: '🚶'
      ),
    ];
  }

  List<Map<String, dynamic>> sessionResults = [];
  // LOAD SESSION RESULTS
  Future<void> loadSessionResults() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final data = await Supabase.instance.client
          .from('session_results')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        sessionResults = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user!.id)
          .single();

      if (!mounted) return;

      setState(() {
        userXP = data['total_xp'] ?? 0;
        userLevel = data['level'] ?? 1;
        streak = data['streak'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  // XP pop animation
  late final _popCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
  late final _popOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _popCtrl,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
  late final _popSlide =
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.4))
          .animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadSessionResults();
    WidgetsBinding.instance.addPostFrameCallback((_) => _countUp());
  }

  void _countUp() {
    const steps = 60;
    final step = userXP / steps;
    var count = 0;
    _countTimer = Timer.periodic(const Duration(milliseconds: 18), (t) {
      count++;
      setState(() => _displayXP = (step * count).round().clamp(0, userXP));
      if (count >= steps) t.cancel();
    });
  }

  void _claimChallenge(int id, int xp) {
    if (_claimed.contains(id)) return;
    setState(() {
      _claimed.add(id);
      _xpPopText = '+$xp XP ⚡';
      _showPop = true;
    });
    _popCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _showPop = false);
    });
  }

  @override
  void dispose() {
    _countTimer?.cancel();
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildHeroCard(),
                _buildQuickStats(),
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
              ],
            ),
          ),
          // Floating XP pop
          if (_showPop)
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.35,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _popOpacity,
                  child: SlideTransition(
                    position: _popSlide,
                    child: Center(
                      child: Text(
                        _xpPopText,
                        style: TextStyle(
                          color: _gold,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                                color: _gold.withValues(alpha: 0.60),
                                blurRadius: 16)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Header

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800),
              children: [
                TextSpan(text: 'XP '),
                TextSpan(text: 'Experience', style: TextStyle(color: _gold)),
                TextSpan(text: ' Hub'),
              ],
            ),
          ),
          const Text('Track progress, earn rewards, crush challenges',
              style: TextStyle(color: _muted, fontSize: 12)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _red.withValues(alpha: 0.10),
            border: Border.all(color: _red.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(children: [
            const Text('🔥', style: TextStyle(fontSize: 15)),
            const SizedBox(width: 4),
            Text('$streak Day Streak',
                style: const TextStyle(
                    color: Color(0xFFF87171),
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  //XP Hero Card

  Widget _buildHeroCard() {
    final pct = userXP / 1000;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_card, _cardD],
          ),
          border: Border.all(color: _gold.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          _LevelBadge(level: userLevel),
          const SizedBox(width: 20),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total XP Earned',
                            style: TextStyle(color: _muted, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('$_displayXP',
                            style: const TextStyle(
                                color: _gold,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1)),
                      ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Next Level',
                        style: TextStyle(color: _muted, fontSize: 11)),
                    Text('${kNextLevelXP - userXP} XP away',
                        style: const TextStyle(
                            color: _slate,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Stack(children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_cyan, _indigo, _purple]),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                            color: _cyan.withValues(alpha: 0.50), blurRadius: 8)
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lvl $userLevel — Warrior Athlete',
                      style: const TextStyle(
                          color: _green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  Text('Lvl ${userLevel + 1} — Elite →',
                      style: const TextStyle(color: _sub, fontSize: 11)),
                ],
              ),
            ],
          )),
        ]),
      ),
    );
  }

  //Quick Stats

  Widget _buildQuickStats() {
    const stats = [
      (label: 'This Week', value: '920', unit: 'XP', icon: '📈', color: _cyan),
      (
        label: 'Challenges',
        value: '14',
        unit: 'done',
        icon: '💥',
        color: _orange
      ),
      (
        label: 'Competitions',
        value: '3',
        unit: 'entered',
        icon: '🏆',
        color: _gold
      ),
      (label: 'Rank', value: '#47', unit: 'global', icon: '⭐', color: _green),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          for (final s in stats)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_card, _cardD]),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  Text(s.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(s.value,
                      style: TextStyle(
                          color: s.color,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  Text(s.unit,
                      style: const TextStyle(color: _sub, fontSize: 10)),
                  Text(s.label,
                      style: const TextStyle(color: _muted, fontSize: 10)),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  //Tab bar

  Widget _buildTabBar() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final active = _tabIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    active ? _cyan.withValues(alpha: 0.12) : Colors.transparent,
                border: Border.all(
                    color: active
                        ? _cyan.withValues(alpha: 0.30)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_tabs[i],
                  style: TextStyle(
                    color: active ? _cyan : _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          );
        },
      ),
    );
  }

  //Tab content

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: switch (_tabIndex) {
        0 => const _OverviewTab(key: ValueKey(0)),
        1 => _ChallengesTab(
            key: const ValueKey(1),
            claimed: _claimed,
            onClaim: _claimChallenge,
            challenges: generateAdaptiveChallenges(),
          ),
        2 => _CompetitionsTab(
            key: const ValueKey(2),
            joined: _joined,
            onJoin: (id) => setState(() => _joined.add(id)),
          ),
        3 => const _RewardsTab(key: ValueKey(3)),
        _ => const _HistoryTab(key: ValueKey(4)),
      },
    );
  }
}

//  TAB: OVERVIEW
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final maxXP = _weeklyData.map((d) => d.xp).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Weekly XP chart
        _SectionCard(
          title: "This Week's XP 📈",
          child: SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in _weeklyData)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (d.xp > 0) ...[
                            Text('${d.xp}',
                                style: const TextStyle(
                                    color: _cyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                          ],
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.elasticOut,
                            height: maxXP > 0
                                ? (d.xp / maxXP * 80).clamp(6.0, 80.0)
                                : 6.0,
                            decoration: BoxDecoration(
                              gradient: d.xp > 0
                                  ? const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [_cyan, _indigo])
                                  : null,
                              color: d.xp > 0
                                  ? null
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(d.day,
                              style:
                                  const TextStyle(color: _sub, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recent activitY
        _SectionCard(
          title: 'Recent Activity',
          child: Column(
            children: [for (final e in _history.take(4)) _HistoryRow(event: e)],
          ),
        ),
        const SizedBox(height: 16),

        // Streak calendar
        _SectionCard(
          title: 'March Streak 🔥',
          child: Column(children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, crossAxisSpacing: 6, mainAxisSpacing: 6),
              itemCount: 31,
              itemBuilder: (_, i) {
                final day = i + 1;
                final done = day <= streak;
                return Container(
                  decoration: BoxDecoration(
                    gradient: done
                        ? const LinearGradient(colors: [_orange, _red])
                        : null,
                    color: done ? null : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: done
                        ? [
                            BoxShadow(
                                color: _orange.withValues(alpha: 0.30),
                                blurRadius: 4)
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      done ? '🔥' : '$day',
                      style: TextStyle(
                        fontSize: done ? 10 : 9,
                        color: done ? Colors.white : _sub,
                        fontWeight: done ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.08),
                border: Border.all(color: _orange.withValues(alpha: 0.20)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '🔥  Keep it up! 5-day bonus incoming at Day 17',
                style: TextStyle(color: _orange, fontSize: 13),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

//  TAB: CHALLENGES
class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({
    super.key,
    required this.claimed,
    required this.onClaim,
    required this.challenges,
  });
  final Set<int> claimed;
  final void Function(int id, int xp) onClaim;
  final List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    final done = claimed.length;
    final total = challenges.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Challenges',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Resets in 4h 32m  •  Complete all for +200 XP',
                      style: TextStyle(color: _muted, fontSize: 12)),
                ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.10),
                border: Border.all(color: _green.withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('$done/$total Done',
                  style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        for (final c in challenges) ...[
          Opacity(
            opacity: claimed.contains(c.id) ? 0.65 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_card, _cardD]),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(c.icon, style: const TextStyle(fontSize: 30)),
                      const Spacer(),
                      if (claimed.contains(c.id))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.12),
                            border: Border.all(
                                color: _green.withValues(alpha: 0.25)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('✓ DONE',
                              style: TextStyle(
                                  color: _green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ]),
                    const SizedBox(height: 10),
                    Text(c.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _DiffChip(difficulty: c.difficulty),
                      const SizedBox(width: 8),
                      _CatChip(label: c.category),
                      const Spacer(),
                      Text('+${c.xp} XP',
                          style: const TextStyle(
                              color: _gold,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => onClaim(c.id, c.xp),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: claimed.contains(c.id)
                                ? null
                                : const LinearGradient(
                                    colors: [_gold, _orange]),
                            color: claimed.contains(c.id)
                                ? _green.withValues(alpha: 0.10)
                                : null,
                            border: claimed.contains(c.id)
                                ? Border.all(
                                    color: _green.withValues(alpha: 0.20))
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: claimed.contains(c.id)
                                ? null
                                : [
                                    BoxShadow(
                                        color: _gold.withValues(alpha: 0.30),
                                        blurRadius: 10)
                                  ],
                          ),
                          child: Text(
                            claimed.contains(c.id) ? '✓ Claimed' : 'Claim →',
                            style: TextStyle(
                              color: claimed.contains(c.id)
                                  ? _green
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ]),
            ),
          ),
        ],

        // All-complete bonus meter
        if (done > 0) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _gold.withValues(alpha: 0.06),
                _orange.withValues(alpha: 0.06),
              ]),
              border: Border.all(color: _gold.withValues(alpha: 0.20)),
              borderRadius: BorderRadius.circular(18),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All-Complete Bonus',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  Text('+200 XP',
                      style: TextStyle(
                          color: _gold,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              Stack(children: [
                Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(100),
                    )),
                FractionallySizedBox(
                  widthFactor: done / total,
                  child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: [_gold, _orange]),
                        borderRadius: BorderRadius.circular(100),
                      )),
                ),
              ]),
              const SizedBox(height: 8),
              Text('$done/$total challenges completed',
                  style: const TextStyle(color: _muted, fontSize: 12)),
            ]),
          ),
        ],
      ],
    );
  }
}

//  TAB: COMPETITIONS
class _CompetitionsTab extends StatelessWidget {
  const _CompetitionsTab(
      {super.key, required this.joined, required this.onJoin});
  final Set<int> joined;
  final ValueChanged<int> onJoin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const Text('Active Competitions',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Compete globally and earn massive XP',
            style: TextStyle(color: _muted, fontSize: 13)),
        const SizedBox(height: 16),
        for (final c in _competitions) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_card, _cardD]),
              border: Border.all(
                color: joined.contains(c.id)
                    ? _gold.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.10),
                    border: Border.all(color: _gold.withValues(alpha: 0.20)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                      child:
                          Text(c.icon, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(c.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                          '👥 ${c.participants} participants  •  📅 ${c.endDate}',
                          style: const TextStyle(color: _muted, fontSize: 12)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('+${c.xp} XP',
                      style: const TextStyle(
                          color: _gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => onJoin(c.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: joined.contains(c.id)
                            ? null
                            : const LinearGradient(colors: [_gold, _orange]),
                        color: joined.contains(c.id)
                            ? _cyan.withValues(alpha: 0.10)
                            : null,
                        border: joined.contains(c.id)
                            ? Border.all(color: _cyan.withValues(alpha: 0.20))
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        joined.contains(c.id) ? '✓ Joined' : 'Join →',
                        style: TextStyle(
                          color: joined.contains(c.id) ? _cyan : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
              if (joined.contains(c.id) && c.rank != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.06),
                    border: Border.all(color: _cyan.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your current rank',
                          style: TextStyle(color: _slate, fontSize: 14)),
                      Text('#${c.rank} of ${c.participants}',
                          style: const TextStyle(
                              color: _cyan,
                              fontWeight: FontWeight.w800,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ]),
          ),
        ],
      ],
    );
  }
}

//  TAB: REWARDS
class _RewardsTab extends StatelessWidget {
  const _RewardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const Text('Level Rewards 🎁',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Level up to unlock free consultations & perks',
            style: TextStyle(color: _muted, fontSize: 13)),
        const SizedBox(height: 16),

        for (final r in _rewards) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: r.unlocked
                  ? _green.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.02),
              border: Border.all(
                color: r.unlocked
                    ? _green.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: r.unlocked
                      ? _green.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: r.unlocked
                        ? _green.withValues(alpha: 0.30)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(r.icon,
                      style: TextStyle(
                          fontSize: 22,
                          color: r.unlocked
                              ? null
                              : Colors.white.withValues(alpha: 0.25))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(r.reward,
                        style: TextStyle(
                          color: r.unlocked ? Colors.white : _sub,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        )),
                    Text('Level ${r.level} required',
                        style: const TextStyle(color: _sub, fontSize: 12)),
                  ])),
              if (r.unlocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.15),
                    border: Border.all(color: _green.withValues(alpha: 0.25)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Claim →',
                      style: TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                )
              else
                Text('🔒 Lvl ${r.level}',
                    style: const TextStyle(color: _sub, fontSize: 12)),
            ]),
          ),
        ],

        const SizedBox(height: 8),
        // XP Store teaser
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              _indigo.withValues(alpha: 0.10),
              _purple.withValues(alpha: 0.10),
            ]),
            border: Border.all(color: _indigo.withValues(alpha: 0.20)),
            borderRadius: BorderRadius.circular(18),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🛒  XP Store — Coming Soon',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Spend XP on trainer consultations, premium plans, exclusive gear discounts, and more.',
              style: TextStyle(color: _muted, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final s in [
                  '1 Free Session — 500 XP',
                  'Premium Plan — 800 XP',
                  'Pro Badge — 1200 XP'
                ])
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10)),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(s,
                        style: const TextStyle(color: _slate, fontSize: 12)),
                  ),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}

//  TAB: HISTORY
class _HistoryTab extends StatelessWidget {
  const _HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final total = _history.fold(0, (sum, e) => sum + e.xp);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('XP History',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: _muted, fontSize: 13),
                children: [
                  const TextSpan(text: 'Total: '),
                  TextSpan(
                      text: '+$total XP',
                      style: const TextStyle(
                          color: _gold, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final e in _history) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _HistoryRow(event: e, showType: true),
          ),
        ],
      ],
    );
  }
}

//  ATOMS
class _LevelBadge extends StatefulWidget {
  const _LevelBadge({required this.level});
  final int level;
  @override
  State<_LevelBadge> createState() => _LevelBadgeState();
}

class _LevelBadgeState extends State<_LevelBadge>
    with SingleTickerProviderStateMixin {
  late final _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat(reverse: true);
  late final _float = Tween<double>(begin: 0, end: -6)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  late final _glow = Tween<double>(begin: 0.30, end: 0.70)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _float.value),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_gold, _orange],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: _gold.withValues(alpha: _glow.value),
                  blurRadius: 24,
                  spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${widget.level}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1)),
              const Text('LEVEL',
                  style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_card, _cardD]),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          child,
        ]),
      );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.event, this.showType = false});
  final XPEvent event;
  final bool showType;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.12),
              border: Border.all(color: event.color.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(event.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.action,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Row(children: [
                Text(event.time,
                    style: const TextStyle(color: _sub, fontSize: 11)),
                if (showType) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.12),
                      border: Border.all(
                          color: event.color.withValues(alpha: 0.20)),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(event.type,
                        style: TextStyle(
                            color: event.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
            ],
          )),
          Text('+${event.xp}',
              style: const TextStyle(
                  color: _gold, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _DiffChip extends StatelessWidget {
  const _DiffChip({required this.difficulty});
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    // Dart 3 switch expression
    final color = switch (difficulty) {
      'Easy' => _green,
      'Hard' => _red,
      _ => _gold,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(difficulty,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: const TextStyle(
                color: _slate, fontSize: 11, fontWeight: FontWeight.w500)),
      );
}
