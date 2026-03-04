import 'package:flutter/material.dart';

void main() {
  runApp(const KhelYuva());
}

class KhelYuva extends StatelessWidget {
  const KhelYuva({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KhelYuva FAQ',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFF1A1A2E),
        ),
      ),
      home: const FAQPage(),
    );
  }
}

class _C {
  static const bg = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const card = Color(0xFF1E1E35);
  static const border = Color(0xFF2A2A4A);
  static const accent = Color(0xFF6C63FF);
  static const amber = Color(0xFFFFAB40);
  static const pink = Color(0xFFE040FB);
  static const teal = Color(0xFF00BFA5);
  static const textSecondary = Color(0xFF9090B0);
}

class FAQItem {
  final String question;
  final String answer;
  const FAQItem({required this.question, required this.answer});
}

class FAQCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<FAQItem> items;
  const FAQCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

const List<FAQCategory> _faqData = [
  FAQCategory(
    title: 'App Usage',
    icon: Icons.sports_rounded,
    color: _C.accent,
    items: [
      FAQItem(
        question: 'What is KhelYuva and who is it for?',
        answer:
            'KhelYuva is a performance-driven sports platform built for rural and urban youth athletes. Whether you have access to a professional coach or not, KhelYuva helps you improve your fitness and athletic skills through AI-powered video analysis, form correction, and progress tracking — right from your smartphone.',
      ),
      FAQItem(
        question: 'How does the AI form correction work?',
        answer:
            'KhelYuva uses an offline AI model that analyzes your body posture and movement during exercises through your phone camera. It detects key body landmarks in real time and compares them against ideal form patterns. You receive instant feedback on your posture, joint angles, and movement flow — no internet connection required.',
      ),
      FAQItem(
        question: 'What is cheat detection and why does it matter?',
        answer:
            'Cheat detection ensures that your reps and exercises are counted fairly. The AI monitors your movement patterns to verify that each repetition meets the minimum quality threshold. This keeps your performance data honest and your training effective — especially important for remote assessments and competitions.',
      ),
      FAQItem(
        question: 'How do I log my calories and steps?',
        answer:
            'From the Dashboard, tap any stat card (Steps or Calories Burned) to open a quick-log sheet. You can also tap the + icons next to the Food and Burned rows in the Exercise card. Enter the value and confirm — your progress ring and stats will update immediately.',
      ),
      FAQItem(
        question: 'Can I edit my daily goals?',
        answer:
            'Yes! Tap the Edit button at the top of the Today section on the Dashboard. A sheet will appear where you can update your Step Goal, Calorie Burn Goal, and Base Calorie Goal. Changes take effect instantly and all progress bars will recalculate.',
      ),
      FAQItem(
        question: 'What does the Remaining value on the exercise ring mean?',
        answer:
            'The Remaining value is: Base Goal minus Calories Burned plus Food Calories. It represents how many net calories you still need to burn to meet your daily goal. As you log exercise and food, this number updates in real time and the ring fills up.',
      ),
      FAQItem(
        question: 'Does KhelYuva work without an internet connection?',
        answer:
            'Yes. The core AI features — form correction, cheat detection, and real-time feedback — are all powered by offline models stored on your device. You only need internet for account login, syncing data to the cloud, and accessing premium content.',
      ),
      FAQItem(
        question: 'How do I reset my daily data?',
        answer:
            'Tap the Reset button next to Today on the Dashboard. A confirmation dialog will appear. Once confirmed, your steps, calories burned, and food intake for the day will be cleared. This is useful if you want to start fresh or correct a logging mistake.',
      ),
    ],
  ),
  FAQCategory(
    title: 'Navigation',
    icon: Icons.explore_rounded,
    color: _C.teal,
    items: [
      FAQItem(
        question: 'How do I navigate between pages in the app?',
        answer:
            'KhelYuva uses a bottom navigation bar for quick access to the main sections: Dashboard, Workouts, Progress, and Profile. You can also access Settings and About Us from the profile screen or the side menu.',
      ),
      FAQItem(
        question: 'Where can I find the Settings page?',
        answer:
            'Tap your profile avatar in the top-left corner of the Dashboard, then select Settings from the profile menu. Alternatively, navigate to the Profile tab via the bottom bar and look for the Settings option there.',
      ),
      FAQItem(
        question: 'How do I access the About Us page?',
        answer:
            'Go to Settings and scroll to the Support section. Tap About KhelYuva to open the About Us page, which includes information about the app mission and the development team.',
      ),
      FAQItem(
        question: 'What does the notification bell do?',
        answer:
            'The bell icon in the top-right corner of the Dashboard shows you recent alerts — such as goal milestones, AI feedback from your last session, and activity reminders. A purple dot on the bell means you have unread notifications. Tap it to view and dismiss them.',
      ),
      FAQItem(
        question: 'How do I edit my profile?',
        answer:
            'Navigate to Settings, then Account Settings, then Edit Profile. You can update your name, age, sport, profile photo, and physical stats like height and weight. Keeping your profile accurate helps the AI provide better-calibrated feedback.',
      ),
      FAQItem(
        question: 'Where can I see my weekly performance chart?',
        answer:
            'Your Weekly Performance chart is on the Dashboard — scroll down past the Steps and Calories cards. It shows your performance score across the week as a smooth line chart. The most recent day dot is highlighted.',
      ),
    ],
  ),
  FAQCategory(
    title: 'Account',
    icon: Icons.contact_page_rounded,
    color: _C.amber,
    items: [
      FAQItem(
        question: 'How do I change my password?',
        answer:
            'Go to Settings, then Account Settings, then Change Password. You will be asked to enter your current password followed by your new password. Make sure your new password is at least 8 characters long and includes a mix of letters and numbers.',
      ),
      FAQItem(
        question: 'How do I log out of the app?',
        answer:
            'Open Settings and scroll to the bottom. Tap Log Out and confirm when prompted. Your locally stored progress data remains on the device, but your session will end and you will be taken to the login screen.',
      ),
    ],
  ),
  FAQCategory(
    title: 'Privacy & Data',
    icon: Icons.shield_rounded,
    color: _C.pink,
    items: [
      FAQItem(
        question: 'Is my workout data stored on the cloud?',
        answer:
            'By default, your data is stored locally on your device. If you enable cloud sync in Settings, your progress data will be securely backed up to our servers so you can restore it on a new device. We do not share your personal data with third parties.',
      ),
      FAQItem(
        question: 'Does the camera record or upload my video?',
        answer:
            'No. KhelYuva processes camera input entirely on-device using offline AI models. No video footage is recorded, stored, or transmitted to our servers. The camera feed is analyzed in real time and discarded immediately after processing.',
      ),
      FAQItem(
        question: 'How do I delete my account and data?',
        answer:
            'To permanently delete your account, go to Settings, then Privacy Settings, then Delete Account. This action is irreversible and will remove all your profile information and cloud-synced data. Locally stored data can be cleared from your device settings.',
      ),
      FAQItem(
        question: 'What permissions does the app need and why?',
        answer:
            'KhelYuva requests Camera (for AI form analysis), Activity Recognition (for step counting), and Storage (for saving session reports). All permissions are optional — the app will function in limited capacity if any are denied. We never access your contacts, messages, or location.',
      ),
    ],
  ),
  FAQCategory(
    title: 'Troubleshooting',
    icon: Icons.build_rounded,
    color: Color(0xFF4FC3F7),
    items: [
      FAQItem(
        question:
            'The AI camera is not detecting my movements. What should I do?',
        answer:
            'Make sure you are in a well-lit area with your full body visible in the frame. Stand 2 to 3 metres from the phone and ensure the camera lens is clean. If the issue persists, toggle Form Correction off and back on in Settings to restart the AI module.',
      ),
      FAQItem(
        question: 'My step count seems incorrect. How is it measured?',
        answer:
            'Steps are counted using your device built-in accelerometer and activity recognition sensor. Accuracy can vary based on how you carry your phone. For best results, keep your phone in your pocket or in hand while walking. You can manually adjust the count via the Steps card on the Dashboard.',
      ),
      FAQItem(
        question: 'The app is running slowly on my device. What can I do?',
        answer:
            'Close other background apps to free up memory. You can also reduce AI processing load by toggling off Real-time Feedback in the AI Status card on the Dashboard when not actively training. If the issue continues, try reinstalling the app — your cloud-synced data will be preserved.',
      ),
      FAQItem(
        question: 'I forgot my password. How do I recover my account?',
        answer:
            'On the login screen, tap Forgot Password and enter your registered email address. You will receive a password reset link within a few minutes. Check your spam folder if it does not arrive. The reset link expires after 24 hours.',
      ),
      FAQItem(
        question: 'How do I report a bug or send feedback?',
        answer:
            'Go to Settings, then Support, then Help and FAQ, and tap Send Feedback. You can describe the issue, attach a screenshot, and submit it to our team. We review all reports and release fixes in regular updates. You can also email us at support@khelyuva.app.',
      ),
    ],
  ),
];

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategory;
  final Set<String> _expandedQuestions = {};

  List<FAQCategory> get _filteredCategories {
    final query = _searchQuery.toLowerCase().trim();
    final cats =
        _selectedCategory != null ? [_faqData[_selectedCategory!]] : _faqData;
    if (query.isEmpty) return cats;
    return cats
        .map((cat) {
          final filtered = cat.items
              .where((item) =>
                  item.question.toLowerCase().contains(query) ||
                  item.answer.toLowerCase().contains(query))
              .toList();
          return filtered.isEmpty
              ? null
              : FAQCategory(
                  title: cat.title,
                  icon: cat.icon,
                  color: cat.color,
                  items: filtered);
        })
        .whereType<FAQCategory>()
        .toList();
  }

  int get _totalResults =>
      _filteredCategories.fold(0, (sum, cat) => sum + cat.items.length);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCategories;
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & FAQ',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                // Hero banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _C.accent.withValues(alpha: 0.2),
                        _C.pink.withValues(alpha: 0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _C.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.help_outline_rounded,
                            color: _C.accent, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How can we help you?',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 3),
                            Text('Browse categories or search below',
                                style: TextStyle(
                                    color: _C.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search questions...',
                      hintStyle: const TextStyle(color: _C.textSecondary),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: _C.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: _C.textSecondary, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              })
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _faqData.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final isAll = i == 0;
                      final isSelected = isAll
                          ? _selectedCategory == null
                          : _selectedCategory == i - 1;
                      final cat = isAll ? null : _faqData[i - 1];
                      final color = isAll ? _C.accent : cat!.color;
                      return GestureDetector(
                        onTap: () => setState(
                            () => _selectedCategory = isAll ? null : i - 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.2)
                                : _C.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? color : _C.border,
                                width: isSelected ? 1.5 : 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isAll) ...[
                                Icon(cat!.icon,
                                    color:
                                        isSelected ? color : _C.textSecondary,
                                    size: 13),
                                const SizedBox(width: 5),
                              ],
                              Text(isAll ? 'All' : cat!.title,
                                  style: TextStyle(
                                    color:
                                        isSelected ? color : _C.textSecondary,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (_searchQuery.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        '$_totalResults result${_totalResults == 1 ? '' : 's'} found',
                        style: const TextStyle(
                            color: _C.textSecondary, fontSize: 12)),
                  ),
              ],
            ),
          ),

          // FAQ list
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(query: _searchQuery)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, catIdx) {
                      final cat = filtered[catIdx];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 10),
                            child: Row(children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: cat.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child:
                                    Icon(cat.icon, color: cat.color, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(cat.title,
                                  style: TextStyle(
                                      color: cat.color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cat.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${cat.items.length}',
                                    style: TextStyle(
                                        color: cat.color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: _C.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _C.border),
                            ),
                            child: Column(
                              children: cat.items.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final item = entry.value;
                                final isLast = idx == cat.items.length - 1;
                                final key = cat.title + item.question;
                                final isExpanded =
                                    _expandedQuestions.contains(key);
                                return Column(children: [
                                  _FAQTile(
                                    item: item,
                                    accentColor: cat.color,
                                    isExpanded: isExpanded,
                                    searchQuery: _searchQuery,
                                    onTap: () => setState(() {
                                      if (isExpanded) {
                                        _expandedQuestions.remove(key);
                                      } else {
                                        _expandedQuestions.add(key);
                                      }
                                    }),
                                  ),
                                  if (!isLast)
                                    const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: _C.border,
                                        indent: 16,
                                        endIndent: 16),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactSheet(context),
        backgroundColor: _C.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.headset_mic_rounded, size: 20),
        label: const Text('Contact Support',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Still need help?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Our team is available to assist you with any issue.',
                style: TextStyle(color: _C.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            _ContactOption(
                icon: Icons.email_outlined,
                iconColor: _C.accent,
                title: 'Email Support',
                subtitle: 'support@khelyuva.app',
                onTap: () => Navigator.pop(context)),
            const SizedBox(height: 12),
            _ContactOption(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: _C.teal,
                title: 'Live Chat',
                subtitle: 'Typically replies in under 5 minutes',
                onTap: () => Navigator.pop(context)),
            const SizedBox(height: 12),
            _ContactOption(
                icon: Icons.bug_report_outlined,
                iconColor: _C.pink,
                title: 'Report a Bug',
                subtitle: 'Help us improve the app',
                onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final FAQItem item;
  final Color accentColor;
  final bool isExpanded;
  final String searchQuery;
  final VoidCallback onTap;

  const _FAQTile({
    required this.item,
    required this.accentColor,
    required this.isExpanded,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _HighlightText(
                    text: item.question,
                    query: searchQuery,
                    baseStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4),
                    highlightColor: _C.accent,
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? accentColor : _C.textSecondary,
                      size: 22),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 1,
                                color: _C.border,
                                margin: const EdgeInsets.only(bottom: 10)),
                            _HighlightText(
                              text: item.answer,
                              query: searchQuery,
                              baseStyle: const TextStyle(
                                  color: _C.textSecondary,
                                  fontSize: 13,
                                  height: 1.6),
                              highlightColor: _C.amber,
                            ),
                          ]))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final Color highlightColor;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: baseStyle);
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx)));
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          backgroundColor: highlightColor.withValues(alpha: 0.25),
          color: highlightColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = idx + query.length;
    }
    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: _C.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.search_off_rounded,
                color: _C.accent, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No results found',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Try a different keyword or browse all categories.',
              style: TextStyle(color: _C.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                        const TextStyle(color: _C.textSecondary, fontSize: 12)),
              ])),
          const Icon(Icons.chevron_right_rounded,
              color: _C.textSecondary, size: 20),
        ]),
      ),
    );
  }
}
