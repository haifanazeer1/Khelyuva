import 'package:flutter/material.dart';
import 'package:khel_yuva/bottomnavbar/exercise_form/upload.dart';
import 'package:khel_yuva/home/chatbotbk/chatbotscreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khel_yuva/home/exppoints/xp.dart';
import 'package:khel_yuva/res/colors.dart';
import 'package:khel_yuva/bottomnavbar/leaderboard.dart';
import 'package:khel_yuva/sidenavbar/aboutus.dart';
import 'package:khel_yuva/sidenavbar/dietrecommendation/diet.dart';
import 'package:khel_yuva/sidenavbar/profile.dart';
import 'package:khel_yuva/sidenavbar/settings.dart';
import 'package:khel_yuva/bottomnavbar/progresspage.dart';
import 'package:khel_yuva/widgets/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khel_yuva/bottomnavbar/exercise_form/model_selection_screen.dart';
import 'package:khel_yuva/home/personal_trainer/ptrainer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  String _username = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late List<Widget> _pages; //  Important: NOT const

  Future<void> _loadUsername() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('profiles')
        .select('name')
        .eq('id', user.id)
        .maybeSingle();

    if (data != null && mounted) {
      setState(() => _username = data['name'] ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Pages list moved here
    _pages = [
      _buildHomeContent(), //full UI
      const LeaderboardScreen(),
      ModeSelectionScreen(),
      const ProgressPage(),
      const ProfilePage(),
      const DietHomePage(),
      XPPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KY.bg,
      appBar: AppBar(
        backgroundColor: KY.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(), // Drawer added
      body: Stack(
        children: [
          IndexedStack(
            index: _navIndex,
            children: _pages,
          ),

          // Chatbot floating button
          Positioned(
            right: 18,
            bottom: 110,
            child: _buildChatBot(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildHeroBanner(),
            _buildQuickStats(),
            _buildPersonalTrainerCard(),
            _buildSectionTitle("Today's Workout Plan"),
            _buildWorkoutPlan(),
            _buildSectionTitle("Choose a Sport to Play"),
            _buildSportsPicker(),
            _buildSectionTitle("AI Performance Feedback"),
            _buildAIFeedbackCard(),
            _buildSectionTitle("Analyse Your Form"),
            _buildVideoAnalysisSection(),
            _buildSectionTitle("Leaderboard"),
            _buildLeaderboard(),
            _buildSectionTitle("Offline AI Status"),
            _buildAIStatusCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: KY.gradientAccent,
                  boxShadow: [
                    BoxShadow(
                      color: KY.accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundColor: KY.card,
                    child: Icon(Icons.person_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: KY.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: KY.bg, width: 2),
                ),
                child: const Center(
                  child: Text('7',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello there 👋',
                    style: TextStyle(color: KY.textSec, fontSize: 12)),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Khel',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5),
                      ),
                      TextSpan(
                        text: 'Yuva',
                        style: TextStyle(
                            color: KY.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: KY.gradientFire,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: KY.orange.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1)
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('12 Day',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: KY.accent, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //HERO BANNER(and overflow was fixed)
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        // clips any stray pixels
        borderRadius: BorderRadius.circular(24),
        child: Container(
          // height not fixed so let content decide, avoids 3-pixel overflow
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1B4B), Color(0xFF1A0533)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: KY.purple.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Stack(
            children: [
              // Decorative glow circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      KY.accent.withValues(alpha: 0.15),
                      Colors.transparent
                    ]),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      KY.purple.withValues(alpha: 0.2),
                      Colors.transparent
                    ]),
                  ),
                ),
              ),
              // Content intrinsic height and padding handles sizing
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 24), // vertical padding
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: KY.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: KY.accent.withValues(alpha: 0.4)),
                            ),
                            child: const Text('AI POWERED TRAINING',
                                style: TextStyle(
                                    color: KY.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1)),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Train Smarter,\nNot Harder',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: KY.gradientAccent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: KY.accent.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: const Text('Start Session',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Pulsing record icon
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KY.accent.withValues(alpha: 0.1),
                          border: Border.all(
                              color: KY.accent.withValues(alpha: 0.5),
                              width: 2),
                        ),
                        child: const Icon(Icons.videocam_rounded,
                            color: KY.accent, size: 38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //quick stats
  Widget _buildQuickStats() {
    final stats = [
      {
        'label': 'Form Score',
        'value': '87%',
        'icon': Icons.self_improvement,
        'gradient': KY.gradientAccent,
      },
      {
        'label': 'Calories',
        'value': '312',
        'icon': Icons.local_fire_department,
        'gradient': KY.gradientFire,
      },
      {
        'label': 'Sessions',
        'value': '24',
        'icon': Icons.fitness_center,
        'gradient': KY.gradientGreen,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(stats.length, (i) {
          final s = stats[i];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KY.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: KY.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: s['gradient'] as LinearGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s['icon'] as IconData,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(s['value'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text(s['label'] as String,
                      style: const TextStyle(color: KY.textSec, fontSize: 11)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalTrainerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NearbyTrainersScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: KY.gradientAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: KY.accent.withValues(alpha: 0.4),
                blurRadius: 16,
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.black, size: 32),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hire a Personal Trainer",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Get expert guidance near you",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.black, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text('See All',
              style: TextStyle(
                  color: KY.accent.withValues(alpha: 0.8), fontSize: 12)),
        ],
      ),
    );
  }

  // Workout PLAN
  Widget _buildWorkoutPlan() {
    final workouts = [
      {
        'name': 'Warm Up',
        'duration': '5 min',
        'type': 'Stretching',
        'done': true,
        'color': KY.green
      },
      {
        'name': 'Jump Squats',
        'duration': '3 × 15',
        'type': 'Strength',
        'done': false,
        'color': KY.accent
      },
      {
        'name': 'Sprint Drills',
        'duration': '4 × 30m',
        'type': 'Speed',
        'done': false,
        'color': KY.orange
      },
      {
        'name': 'Core Circuit',
        'duration': '10 min',
        'type': 'Endurance',
        'done': false,
        'color': KY.purple
      },
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: workouts.length,
        itemBuilder: (context, i) {
          final w = workouts[i];
          final done = w['done'] as bool;
          final color = w['color'] as Color;
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: done ? color.withValues(alpha: 0.15) : KY.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: done ? color.withValues(alpha: 0.5) : KY.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    if (done)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            shape: BoxShape.circle),
                        child: Icon(Icons.check, color: color, size: 12),
                      ),
                  ],
                ),
                const Spacer(),
                Text(w['name'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(w['type'] as String,
                    style: TextStyle(color: color, fontSize: 11)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.timer_outlined, color: KY.textSec, size: 12),
                  const SizedBox(width: 4),
                  Text(w['duration'] as String,
                      style: const TextStyle(color: KY.textSec, fontSize: 11)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  //SPORTS PICKER
  Widget _buildSportsPicker() {
    final sports = [
      {
        'name': 'Badminton',
        'icon': Icons.sports_tennis,
        'color': const Color(0xFF00E5FF),
        'players': '2–4 players',
        'tag': 'Popular'
      },
      {
        'name': 'Golf',
        'icon': Icons.golf_course,
        'color': const Color(0xFF00E676),
        'players': '1–4 players',
        'tag': 'Relaxed'
      },
      {
        'name': 'Tennis',
        'icon': Icons.sports_tennis,
        'color': const Color(0xFFFF6D00),
        'players': '2–4 players',
        'tag': 'Intense'
      },
      {
        'name': 'Football',
        'icon': Icons.sports_soccer,
        'color': const Color(0xFF7C4DFF),
        'players': '11 per side',
        'tag': 'Team'
      },
      {
        'name': 'Basketball',
        'icon': Icons.sports_basketball,
        'color': const Color(0xFFFF1744),
        'players': '5 per side',
        'tag': 'Team'
      },
      {
        'name': 'Cricket',
        'icon': Icons.sports_cricket,
        'color': const Color(0xFFFFD600),
        'players': '11 per side',
        'tag': 'National'
      },
    ];

    int selectedSport = 0;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return SizedBox(
          height: 148,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: sports.length,
            itemBuilder: (context, i) {
              final s = sports[i];
              final color = s['color'] as Color;
              final selected = selectedSport == i;

              return GestureDetector(
                onTap: () => setLocalState(() => selectedSport = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: 115,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.18) : KY.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? color : KY.divider,
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: color.withValues(alpha: 0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 4))
                          ]
                        : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              color.withValues(alpha: selected ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            Icon(s['icon'] as IconData, color: color, size: 22),
                      ),
                      const Spacer(),
                      Text(
                        s['name'] as String,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(s['players'] as String,
                          style:
                              const TextStyle(color: KY.textSec, fontSize: 10)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(s['tag'] as String,
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // AI FEEDBACK CARD
  Widget _buildAIFeedbackCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KY.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KY.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: KY.gradientAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Session Analysis',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text('Jump Squat • 2 hrs ago',
                        style: TextStyle(color: KY.textSec, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KY.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: KY.green.withValues(alpha: 0.4)),
                ),
                child: const Text('Good',
                    style: TextStyle(
                        color: KY.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 18),
            _buildFormBar('Knee Alignment', 0.88, KY.green),
            const SizedBox(height: 10),
            _buildFormBar('Back Posture', 0.72, KY.accent),
            const SizedBox(height: 10),
            _buildFormBar('Depth & Range', 0.61, KY.orange),
            const SizedBox(height: 18),
            Row(children: [
              _buildBadge('✓ No Cheat Detected', KY.green),
              const SizedBox(width: 8),
              _buildBadge('⚡ Form Correction: 2', KY.orange),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KY.accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KY.accent.withValues(alpha: 0.2)),
              ),
              child: const Row(children: [
                Icon(Icons.lightbulb_outline, color: KY.accent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: Keep your knees behind your toes during the squat descent for better form.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: KY.textSec, fontSize: 12)),
          Text('${(value * 100).toInt()}%',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: KY.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  // VIDEO ANALYSIS SECTION
  Widget _buildVideoAnalysisSection() {
    final exercises = [
      {
        'name': 'Push Ups',
        'icon': Icons.accessibility_new_rounded,
        'color': KY.accent
      },
      {'name': 'Squats', 'icon': Icons.directions_run, 'color': KY.purple},
      {'name': 'Deadlift', 'icon': Icons.fitness_center, 'color': KY.orange},
      {'name': 'Plank', 'icon': Icons.self_improvement, 'color': KY.green},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: _buildActionTile(
              icon: Icons.upload_file_rounded,
              label: 'Upload\nVideo',
              sublabel: 'From Gallery',
              gradient: KY.gradientAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionTile(
              icon: Icons.videocam_rounded,
              label: 'Record\nLive',
              sublabel: 'Real-time AI',
              gradient: KY.gradientFire,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(
          children: List.generate(exercises.length, (i) {
            final e = exercises[i];
            final color = e['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin:
                      EdgeInsets.only(right: i < exercises.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: KY.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: KY.divider),
                  ),
                  child: Column(children: [
                    Icon(e['icon'] as IconData, color: color, size: 22),
                    const SizedBox(height: 6),
                    Text(e['name'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String sublabel,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.2)),
          const SizedBox(height: 2),
          Text(sublabel,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
        ]),
      ]),
    );
  }

  //LEADERBOARD
  Widget _buildLeaderboard() {
    final players = [
      {'rank': 1, 'name': 'Haifa Nazeer', 'score': 980, 'state': 'MH'},
      {
        'rank': 2,
        'name': 'Hareem (You)',
        'score': 940,
        'state': 'UP',
        'isMe': true
      },
      {'rank': 3, 'name': 'Naseema Maryam', 'score': 910, 'state': 'GJ'},
      {'rank': 4, 'name': 'Nofa Fadil', 'score': 875, 'state': 'RJ'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KY.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KY.divider),
        ),
        child: Column(
          children: players.map((p) {
            final isMe = p['isMe'] == true;
            final rank = p['rank'] as int;
            final medal = rank == 1
                ? '🥇'
                : rank == 2
                    ? '🥈'
                    : rank == 3
                        ? '🥉'
                        : '   $rank';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? KY.accent.withValues(alpha: 0.1) : KY.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isMe
                        ? KY.accent.withValues(alpha: 0.4)
                        : Colors.transparent),
              ),
              child: Row(children: [
                Text(medal, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      isMe ? KY.accent.withValues(alpha: 0.2) : KY.divider,
                  child: Text(
                    (p['name'] as String)[0],
                    style: TextStyle(
                        color: isMe ? KY.accent : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String,
                          style: TextStyle(
                              color: isMe ? KY.accent : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      Text(p['state'] as String,
                          style:
                              const TextStyle(color: KY.textSec, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isMe ? KY.accent.withValues(alpha: 0.15) : KY.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${p['score']} pts',
                      style: TextStyle(
                          color: isMe ? KY.accent : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }

  //OFFLINE AI STATUS
  Widget _buildAIStatusCard() {
    final features = [
      {
        'label': 'Form Correction',
        'status': 'Active',
        'icon': Icons.check_circle_outline,
        'color': KY.green
      },
      {
        'label': 'Cheat Detection',
        'status': 'Enabled',
        'icon': Icons.security_rounded,
        'color': KY.accent
      },
      {
        'label': 'Real-time Feedback',
        'status': 'Offline Ready',
        'icon': Icons.offline_bolt_rounded,
        'color': KY.purple
      },
      {
        'label': 'Pose Estimation',
        'status': 'Loaded',
        'icon': Icons.accessibility_new_rounded,
        'color': KY.orange
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KY.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KY.divider),
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: KY.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KY.green.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: KY.green, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offline AI Engine',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text('All systems operational',
                      style: TextStyle(color: KY.textSec, fontSize: 12)),
                ],
              ),
            ),
            const _PulsingDot(color: KY.green),
            const SizedBox(width: 6),
            const Text('Online',
                style: TextStyle(
                    color: KY.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          const Divider(color: KY.divider),
          const SizedBox(height: 12),
          ...features.map((f) {
            final color = f['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Icon(f['icon'] as IconData, color: color, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(f['label'] as String,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(f['status'] as String,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            );
          })
        ]),
      ),
    );
  }

  //    BOTTOM NAV
  Widget _buildBottomNav() {
    return BottomAppBar(
      color: KY.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', 0),
            _navItem(Icons.bar_chart_rounded, 'LeaderBoard', 1),
            const SizedBox(width: 48),
            _navItem(Icons.emoji_events_rounded, 'Ranks', 6),
            _navItem(Icons.person_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: active ? KY.accent : KY.textSec, size: active ? 26 : 22),
          Text(label,
              style: TextStyle(
                  color: active ? KY.accent : KY.textSec,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  //  FAB
  Widget _buildFAB() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: KY.gradientAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: KY.accent.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2)
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
        onPressed: () {
          setState(() {
            _navIndex = 2; // Upload screen index
          });
        },
      ),
    );
  }

  Widget _buildChatBot() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderScope(child: ChatBotScreen()),
          ),
        );
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: KY.gradientAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: KY.accent.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: KY.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: KY.gradientAccent,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.black,
                  child:
                      Icon(Icons.person_rounded, color: Colors.white, size: 28),
                ),
                SizedBox(width: 14),
                Text(
                  _username.isNotEmpty ? _username : 'User',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home_rounded, "Home", 0),
          _drawerItem(Icons.person_outline_rounded, "Profile", 4),
          _drawerItem(Icons.food_bank_rounded, "Diet", 5),
          const Divider(color: KY.divider),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: KY.accent),
            title:
                const Text("About Us", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutUsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: KY.accent),
            title:
                const Text("Settings", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          const Spacer(),
          const Divider(color: KY.divider),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title:
                const Text("Logout", style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: KY.accent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        setState(() => _navIndex = index);
      },
    );
  }
}

//  PULSING DOT WIDGET
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({super.key, required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
