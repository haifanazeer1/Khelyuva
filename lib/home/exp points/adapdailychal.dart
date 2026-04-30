// AdaptiveChallengesPage — the gamified challenge hub that:
//   • reads the athlete's real-time & video-analysis performance
//     history and auto-generates DAILY challenges at +20–40% above
//     their best recent attempt
//   • shows WEEKLY elite challenges (fixed hard targets) used to
//     rank athletes on the global leaderboard
//   • animates an XP pop on claim, syncs with the XPPage tokens

import 'package:flutter/material.dart';
import 'tokens.dart';
import 'chalservices.dart'; // re-exports challenge_models.dart

//  MOCK DATA  (replace with real ChallengeService calls)
final _mockPerformance = [
  PerformanceRecord(
    exerciseKey: 'pullups',
    bestValue: 5,
    unit: 'reps',
    lastUpdated: DateTime.now(),
    formScore: 0.85, // ≥ 0.80  →  +40% Stretch challenge
  ),
  PerformanceRecord(
    exerciseKey: 'pushups',
    bestValue: 32,
    unit: 'reps',
    lastUpdated: DateTime.now(),
    formScore: 0.72, // < 0.80  →  +20% Adaptive challenge
  ),
  PerformanceRecord(
    exerciseKey: 'squats',
    bestValue: 20,
    unit: 'reps',
    lastUpdated: DateTime.now(),
    formScore: 0.90,
  ),
  PerformanceRecord(
    exerciseKey: 'plank_seconds',
    bestValue: 45,
    unit: 'seconds',
    lastUpdated: DateTime.now(),
    formScore: 0.68,
  ),
];

final _weeklyList = [
  const WeeklyChallenge(
    id: 1,
    title: 'Iron Mile',
    description: 'Run 5 miles in under 45 minutes. Recorded via GPS '
        'or video — form & pace analysed on completion.',
    targetValue: 8.0,
    unit: 'km',
    xp: 600,
    leaderboardPoints: 250,
    category: 'Endurance',
    icon: '🛤️',
    endDate: 'Apr 13',
    totalParticipants: 312,
    userRank: 18,
    userProgress: 0.62,
    isJoined: true,
  ),
  const WeeklyChallenge(
    id: 2,
    title: 'Century Push',
    description: '100 perfect push-ups (any number of sets). '
        'Video analysis grades form — partial reps don\'t count.',
    targetValue: 100,
    unit: 'reps',
    xp: 500,
    leaderboardPoints: 200,
    category: 'Strength',
    icon: '💪',
    endDate: 'Apr 13',
    totalParticipants: 487,
    userRank: null,
    userProgress: 0.0,
    isJoined: false,
  ),
  const WeeklyChallenge(
    id: 3,
    title: 'Vertical King',
    description: 'Maximum pull-ups in a single set, verified by '
        'video analysis. Top 3 earn exclusive Pro Badge.',
    targetValue: 20,
    unit: 'reps',
    xp: 800,
    leaderboardPoints: 400,
    category: 'Strength',
    icon: '👑',
    endDate: 'Apr 13',
    totalParticipants: 156,
    userRank: null,
    userProgress: 0.0,
    isJoined: false,
  ),
  const WeeklyChallenge(
    id: 4,
    title: 'Sprint Gauntlet',
    description: '5 × 100m sprints with under 60 s rest between. '
        'Fastest combined time wins. Timed via video.',
    targetValue: 5,
    unit: 'reps',
    xp: 700,
    leaderboardPoints: 300,
    category: 'Speed',
    icon: '⚡',
    endDate: 'Apr 15',
    totalParticipants: 224,
    userRank: null,
    userProgress: 0.0,
    isJoined: false,
  ),
];

//  PAGE
class AdaptiveChallengesPage extends StatefulWidget {
  const AdaptiveChallengesPage({super.key});
  @override
  State<AdaptiveChallengesPage> createState() => _AdaptiveChallengesPageState();
}

class _AdaptiveChallengesPageState extends State<AdaptiveChallengesPage>
    with TickerProviderStateMixin {
  late List<AdaptiveChallenge> _daily;
  final List<int> _joinedWeekly = [1];

  var _tab = 0; // 0 = Daily, 1 = Weekly

  String _popText = '';
  bool _showPop = false;

  late final _popCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
  late final _popOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _popCtrl,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
  late final _popSlide =
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, -2.0))
          .animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    // In production, replace with:
    //   _daily = ChallengeService.instance.getDailyChallenges();
    _daily = AdaptiveChallengeEngine.generate(_mockPerformance);
  }

  void _claimDaily(AdaptiveChallenge c) {
    if (c.isClaimed) return;
    setState(() {
      c.isClaimed = true;
      _popText = '+${c.xp} XP ⚡';
      _showPop = true;
    });
    _popCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _showPop = false);
    });
  }

  void _joinWeekly(WeeklyChallenge w) {
    if (_joinedWeekly.contains(w.id)) return;
    setState(() {
      _joinedWeekly.add(w.id);
      _popText = '+${w.leaderboardPoints} LP 🏆';
      _showPop = true;
    });
    _popCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _showPop = false);
    });
  }

  @override
  void dispose() {
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Stack(children: [
        SafeArea(
          child: Column(children: [
            const _Header(),
            _TabSwitch(current: _tab, onTap: (i) => setState(() => _tab = i)),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _tab == 0
                    ? _DailyTab(
                        key: const ValueKey('d'),
                        challenges: _daily,
                        onClaim: _claimDaily,
                      )
                    : _WeeklyTab(
                        key: const ValueKey('w'),
                        challenges: _weeklyList,
                        joined: _joinedWeekly,
                        onJoin: _joinWeekly,
                      ),
              ),
            ),
          ]),
        ),
        // Floating XP / LP pop
        if (_showPop)
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.38,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: FadeTransition(
                opacity: _popOpacity,
                child: SlideTransition(
                  position: _popSlide,
                  child: Center(
                    child: Text(_popText,
                        style: TextStyle(
                          color: appGold,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                                color: appGold.withValues(alpha: 0.55),
                                blurRadius: 18)
                          ],
                        )),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

//  HEADER
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Padding(
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
                TextSpan(text: '⚡ '),
                TextSpan(text: 'Adaptive', style: TextStyle(color: appCyan)),
                TextSpan(text: ' Challenges'),
              ],
            )),
            const Text('AI-personalised to your last performance',
                style: TextStyle(color: appMuted, fontSize: 12)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: appIndigo.withValues(alpha: 0.12),
              border: Border.all(color: appIndigo.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(children: [
              Icon(Icons.timer_outlined, color: appIndigo, size: 15),
              SizedBox(width: 5),
              Text('Resets in 6h 12m',
                  style: TextStyle(
                      color: appIndigo,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      );
}

//  TAB SWITCH
class _TabSwitch extends StatelessWidget {
  const _TabSwitch({required this.current, required this.onTap});
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            _TabButton(
                label: '🗓️  Daily',
                active: current == 0,
                color: appCyan,
                onTap: () => onTap(0)),
            const SizedBox(width: 6),
            _TabButton(
                label: '🏆  Weekly Elite',
                active: current == 1,
                color: appGold,
                onTap: () => onTap(1)),
          ]),
        ),
      );
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: active
                  ? LinearGradient(colors: [
                      color.withValues(alpha: 0.20),
                      color.withValues(alpha: 0.08)
                    ])
                  : null,
              border: active
                  ? Border.all(color: color.withValues(alpha: 0.30))
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? color : appMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ),
      );
}

//  TAB: DAILY ADAPTIVE CHALLENGES
class _DailyTab extends StatelessWidget {
  const _DailyTab({super.key, required this.challenges, required this.onClaim});
  final List<AdaptiveChallenge> challenges;
  final ValueChanged<AdaptiveChallenge> onClaim;

  @override
  Widget build(BuildContext context) {
    final done = challenges.where((c) => c.isClaimed).length;
    final total = challenges.length;
    final pct = total > 0 ? done / total : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        const _AiBanner(),
        const SizedBox(height: 16),
        _AllDoneMeter(done: done, total: total, pct: pct),
        const SizedBox(height: 20),
        for (final c in challenges) ...[
          _DailyChallengeCard(challenge: c, onClaim: () => onClaim(c)),
          const SizedBox(height: 14),
        ],
        const _TipCard(),
      ],
    );
  }
}

class _AiBanner extends StatelessWidget {
  const _AiBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appCyan.withValues(alpha: 0.10),
              appIndigo.withValues(alpha: 0.10)
            ],
          ),
          border: Border.all(color: appCyan.withValues(alpha: 0.20)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: appCyan.withValues(alpha: 0.15),
              border: Border.all(color: appCyan.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          const Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Performance Insight',
                  style: TextStyle(
                      color: appCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 3),
              Text(
                  'Challenges updated from your last session. '
                  'Great pull-up form detected — targets bumped +40% today.',
                  style: TextStyle(color: appSlate, fontSize: 12, height: 1.5)),
            ],
          )),
        ]),
      );
}

class _AllDoneMeter extends StatelessWidget {
  const _AllDoneMeter({
    required this.done,
    required this.total,
    required this.pct,
  });
  final int done, total;
  final double pct;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [appCard, appCardD]),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Today's Progress",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('$done of $total challenges completed',
                  style: const TextStyle(color: appMuted, fontSize: 12)),
            ]),
            RichText(
                text: const TextSpan(
              style: TextStyle(fontSize: 13, color: appMuted),
              children: [
                TextSpan(text: 'Bonus '),
                TextSpan(
                    text: '+200 XP',
                    style: TextStyle(
                        color: appGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ],
            )),
          ]),
          const SizedBox(height: 14),
          Stack(children: [
            Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(100),
                )),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              widthFactor: pct.clamp(0.0, 1.0),
              child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [appCyan, appIndigo, appPurple]),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                          color: appCyan.withValues(alpha: 0.40), blurRadius: 8)
                    ],
                  )),
            ),
          ]),
          if (done == total && total > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: appGreen.withValues(alpha: 0.08),
                border: Border.all(color: appGreen.withValues(alpha: 0.20)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('All done! +200 Bonus XP claimed',
                      style: TextStyle(
                          color: appGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ]),
      );
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.challenge, required this.onClaim});
  final AdaptiveChallenge challenge;
  final VoidCallback onClaim;

  Color get _diffColor => switch (challenge.difficulty) {
        'Stretch' => appOrange,
        'Peak' => appRed,
        _ => appCyan,
      };

  @override
  Widget build(BuildContext context) {
    final c = challenge;
    return AnimatedOpacity(
      opacity: c.isClaimed ? 0.60 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [appCard, appCardD]),
          border: Border.all(
            color: c.isClaimed
                ? appGreen.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.07),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row
          Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _diffColor.withValues(alpha: 0.12),
                border: Border.all(color: _diffColor.withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(c.icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
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
                  Row(children: [
                    _Chip(label: c.difficulty, color: _diffColor),
                    const SizedBox(width: 6),
                    _Chip(
                        label: c.category,
                        color: Colors.white.withValues(alpha: 0.40),
                        textColor: appSlate),
                  ]),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [appGold, appOrange]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: appGold.withValues(alpha: 0.30), blurRadius: 10)
                ],
              ),
              child: Text('+${c.xp} XP',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 14),

          _ProgressComparison(challenge: c),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _diffColor.withValues(alpha: 0.06),
              border: Border.all(color: _diffColor.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(c.adaptationNote,
                style: TextStyle(color: _diffColor, fontSize: 12)),
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: onClaim,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: c.isClaimed
                    ? null
                    : LinearGradient(colors: [
                        _diffColor,
                        _diffColor.withValues(alpha: 0.70)
                      ]),
                color: c.isClaimed ? appGreen.withValues(alpha: 0.10) : null,
                border: c.isClaimed
                    ? Border.all(color: appGreen.withValues(alpha: 0.25))
                    : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: c.isClaimed
                    ? null
                    : [
                        BoxShadow(
                            color: _diffColor.withValues(alpha: 0.30),
                            blurRadius: 12)
                      ],
              ),
              child: Text(
                c.isClaimed ? '✓  Challenge Completed' : 'Mark as Completed →',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.isClaimed ? appGreen : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProgressComparison extends StatelessWidget {
  const _ProgressComparison({required this.challenge});
  final AdaptiveChallenge challenge;

  Color get _diffColor => switch (challenge.difficulty) {
        'Stretch' => appOrange,
        'Peak' => appRed,
        _ => appCyan,
      };

  String _fmt(double v) => challenge.unit == 'reps'
      ? '${v.toInt()} reps'
      : challenge.unit == 'seconds'
          ? '${v.toStringAsFixed(0)} s'
          : '${v.toStringAsFixed(1)} ${challenge.unit}';

  @override
  Widget build(BuildContext context) {
    final c = challenge;
    final max = c.targetValue * 1.1;
    final prevFrac = (c.previousBest / max).clamp(0.0, 1.0);
    final tgtFrac = (c.targetValue / max).clamp(0.0, 1.0);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Previous best bar
      Row(children: [
        SizedBox(
            width: 90,
            child: Text('Your best',
                style: const TextStyle(color: appSub, fontSize: 11))),
        Expanded(
            child: Stack(children: [
          Container(
              height: 8,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(100))),
          FractionallySizedBox(
              widthFactor: prevFrac,
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: appMuted,
                    borderRadius: BorderRadius.circular(100),
                  ))),
        ])),
        const SizedBox(width: 8),
        Text(_fmt(c.previousBest),
            style: const TextStyle(
                color: appSlate, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 8),
      // New target bar
      Row(children: [
        SizedBox(
            width: 90,
            child: Text("Today's target",
                style: TextStyle(
                    color: _diffColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600))),
        Expanded(
            child: Stack(children: [
          Container(
              height: 8,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(100))),
          FractionallySizedBox(
              widthFactor: tgtFrac,
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _diffColor,
                      _diffColor.withValues(alpha: 0.60)
                    ]),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                          color: _diffColor.withValues(alpha: 0.35),
                          blurRadius: 6)
                    ],
                  ))),
        ])),
        const SizedBox(width: 8),
        Text(_fmt(c.targetValue),
            style: TextStyle(
                color: _diffColor, fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
    ]);
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appPurple.withValues(alpha: 0.06),
          border: Border.all(color: appPurple.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(children: [
          Text('💡', style: TextStyle(fontSize: 22)),
          SizedBox(width: 12),
          Expanded(
              child: Text(
            'Tip: Submit a video after each session. '
            'Better form = higher targets = more XP tomorrow.',
            style: TextStyle(color: appSlate, fontSize: 12, height: 1.55),
          )),
        ]),
      );
}

//  TAB: WEEKLY ELITE CHALLENGES
class _WeeklyTab extends StatelessWidget {
  const _WeeklyTab({
    super.key,
    required this.challenges,
    required this.joined,
    required this.onJoin,
  });
  final List<WeeklyChallenge> challenges;
  final List<int> joined;
  final ValueChanged<WeeklyChallenge> onJoin;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
        children: [
          const _WeeklyBanner(),
          const SizedBox(height: 20),
          for (final c in challenges) ...[
            _WeeklyChallengeCard(
              challenge: c,
              isJoined: joined.contains(c.id),
              onJoin: () => onJoin(c),
            ),
            const SizedBox(height: 16),
          ],
        ],
      );
}

class _WeeklyBanner extends StatelessWidget {
  const _WeeklyBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appGold.withValues(alpha: 0.12),
              appOrange.withValues(alpha: 0.08)
            ],
          ),
          border: Border.all(color: appGold.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Text('🏆', style: TextStyle(fontSize: 26)),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Weekly Elite Challenges',
                  style: TextStyle(
                      color: appGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              Text('Results feed the Global Leaderboard',
                  style: TextStyle(color: appMuted, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 12),
          const Text(
            'These are tough, extraordinary challenges set by coaches. '
            'Your verified results (via video analysis) are compared against '
            'all athletes — top performers earn Leaderboard Points (LP) that '
            'determine your rank.',
            style: TextStyle(color: appSlate, fontSize: 13, height: 1.55),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _StatPill(icon: '⚡', label: 'XP', color: appGold),
            const SizedBox(width: 8),
            _StatPill(icon: '🎖️', label: 'LP → Rank', color: appCyan),
            const SizedBox(width: 8),
            _StatPill(icon: '📹', label: 'Video verified', color: appGreen),
          ]),
        ]),
      );
}

class _StatPill extends StatelessWidget {
  const _StatPill(
      {required this.icon, required this.label, required this.color});
  final String icon, label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.20)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _WeeklyChallengeCard extends StatelessWidget {
  const _WeeklyChallengeCard({
    required this.challenge,
    required this.isJoined,
    required this.onJoin,
  });
  final WeeklyChallenge challenge;
  final bool isJoined;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final c = challenge;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [appCard, appCardD]),
        border: Border.all(
          color: isJoined
              ? appGold.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
          width: isJoined ? 1.2 : 0.8,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                appGold.withValues(alpha: 0.20),
                appOrange.withValues(alpha: 0.10),
              ]),
              border: Border.all(color: appGold.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
                child: Text(c.icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(c.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(children: [
                  _Chip(label: c.category, color: appGold),
                  const SizedBox(width: 6),
                  Text('📅 Ends ${c.endDate}',
                      style: const TextStyle(color: appSub, fontSize: 11)),
                ]),
              ])),
        ]),
        const SizedBox(height: 14),
        Text(c.description,
            style: const TextStyle(color: appSlate, fontSize: 13, height: 1.6)),
        const SizedBox(height: 16),
        Row(children: [
          _RewardBadge(icon: '⚡', value: '+${c.xp} XP', color: appGold),
          const SizedBox(width: 10),
          _RewardBadge(
              icon: '🎖️', value: '+${c.leaderboardPoints} LP', color: appCyan),
          const SizedBox(width: 10),
          _RewardBadge(
              icon: '👥', value: '${c.totalParticipants}', color: appMuted),
        ]),
        const SizedBox(height: 16),
        if (isJoined && c.userProgress > 0.0) ...[
          _WeeklyProgress(challenge: c),
          const SizedBox(height: 14),
        ],
        if (isJoined && c.userRank != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: appCyan.withValues(alpha: 0.06),
              border: Border.all(color: appCyan.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your leaderboard rank',
                    style: TextStyle(color: appSlate, fontSize: 14)),
                Text('#${c.userRank} of ${c.totalParticipants}',
                    style: const TextStyle(
                        color: appCyan,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        GestureDetector(
          onTap: onJoin,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: isJoined
                  ? null
                  : const LinearGradient(colors: [appGold, appOrange]),
              color: isJoined ? appCyan.withValues(alpha: 0.08) : null,
              border: isJoined
                  ? Border.all(color: appCyan.withValues(alpha: 0.20))
                  : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isJoined
                  ? null
                  : [
                      BoxShadow(
                          color: appGold.withValues(alpha: 0.30),
                          blurRadius: 14)
                    ],
            ),
            child: Text(
              isJoined
                  ? '✓  Enrolled — Submit Video to Complete'
                  : 'Join Challenge →',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isJoined ? appCyan : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({required this.challenge});
  final WeeklyChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final pct = challenge.userProgress.clamp(0.0, 1.0);
    final done = challenge.targetValue * pct;
    final label = challenge.unit == 'reps'
        ? '${done.toInt()} / ${challenge.targetValue.toInt()} reps'
        : '${done.toStringAsFixed(1)} / '
            '${challenge.targetValue.toStringAsFixed(1)} ${challenge.unit}';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Your progress',
            style: TextStyle(color: appMuted, fontSize: 12)),
        Text(label,
            style: const TextStyle(
                color: appCyan, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      Stack(children: [
        Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
            )),
        FractionallySizedBox(
            widthFactor: pct,
            child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [appCyan, appIndigo]),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                        color: appCyan.withValues(alpha: 0.40), blurRadius: 6)
                  ],
                ))),
      ]),
    ]);
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({
    required this.icon,
    required this.value,
    required this.color,
  });
  final String icon, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      );
}

//  SHARED ATOM — used by both Daily and Weekly cards
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.textColor});
  final String label;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: TextStyle(
                color: textColor ?? color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
}
