import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

typedef _Gradient = ({Color a, Color b});

final class Trainer {
  const Trainer({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.reviews,
    required this.xpRequired,
    required this.isFree,
    required this.tags,
    required this.experience,
    required this.sessions,
    required this.initials,
    required this.gradient,
    required this.available,
    required this.badge,
    required this.badgeColor,
  });

  final int id;
  final String name, title, experience, initials, badge;
  final double rating;
  final int reviews, xpRequired, sessions;
  final bool isFree, available;
  final List<String> tags;
  final _Gradient gradient;
  final Color badgeColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────

const int _kUserXP = 620;

const _kTrainers = <Trainer>[
  Trainer(
    id: 1,
    name: 'Arjun Mehta',
    title: 'Elite Strength Coach',
    rating: 4.9,
    reviews: 312,
    xpRequired: 0,
    isFree: true,
    tags: ['Strength', 'Powerlifting', 'Nutrition'],
    experience: '8 yrs',
    sessions: 1240,
    initials: 'AM',
    gradient: (a: Color(0xFF06B6D4), b: Color(0xFF2563EB)),
    available: true,
    badge: 'Top Rated',
    badgeColor: Color(0xFF06B6D4),
  ),
  Trainer(
    id: 2,
    name: 'Priya Sharma',
    title: 'Yoga & Flexibility Expert',
    rating: 4.8,
    reviews: 198,
    xpRequired: 500,
    isFree: false,
    tags: ['Yoga', 'Flexibility', 'Mindfulness'],
    experience: '6 yrs',
    sessions: 890,
    initials: 'PS',
    gradient: (a: Color(0xFF8B5CF6), b: Color(0xFFDB2777)),
    available: true,
    badge: 'Rising Star',
    badgeColor: Color(0xFF8B5CF6),
  ),
  Trainer(
    id: 3,
    name: 'Rohan Das',
    title: 'HIIT & Cardio Specialist',
    rating: 4.7,
    reviews: 256,
    xpRequired: 300,
    isFree: false,
    tags: ['HIIT', 'Cardio', 'Weight Loss'],
    experience: '5 yrs',
    sessions: 760,
    initials: 'RD',
    gradient: (a: Color(0xFFF97316), b: Color(0xFFDC2626)),
    available: false,
    badge: 'Popular',
    badgeColor: Color(0xFFF97316),
  ),
  Trainer(
    id: 4,
    name: 'Neha Kapoor',
    title: 'Sports Performance Coach',
    rating: 5.0,
    reviews: 87,
    xpRequired: 1000,
    isFree: false,
    tags: ['Athletics', 'Speed', 'Agility'],
    experience: '10 yrs',
    sessions: 2100,
    initials: 'NK',
    gradient: (a: Color(0xFF22C55E), b: Color(0xFF0D9488)),
    available: true,
    badge: 'Expert',
    badgeColor: Color(0xFF22C55E),
  ),
  Trainer(
    id: 5,
    name: 'Vikram Bose',
    title: 'Calisthenics & Bodyweight',
    rating: 4.6,
    reviews: 143,
    xpRequired: 200,
    isFree: false,
    tags: ['Calisthenics', 'Bodyweight', 'Core'],
    experience: '4 yrs',
    sessions: 430,
    initials: 'VB',
    gradient: (a: Color(0xFFEAB308), b: Color(0xFFD97706)),
    available: true,
    badge: 'New',
    badgeColor: Color(0xFFEAB308),
  ),
  Trainer(
    id: 6,
    name: 'Meera Iyer',
    title: 'Rehabilitation Specialist',
    rating: 4.9,
    reviews: 221,
    xpRequired: 750,
    isFree: false,
    tags: ['Rehab', 'Recovery', 'Mobility'],
    experience: '9 yrs',
    sessions: 1580,
    initials: 'MI',
    gradient: (a: Color(0xFFF43F5E), b: Color(0xFFDB2777)),
    available: true,
    badge: 'Certified',
    badgeColor: Color(0xFFF43F5E),
  ),
];

const _kTags = [
  'All',
  'Strength',
  'Yoga',
  'HIIT',
  'Athletics',
  'Calisthenics',
  'Rehab'
];

const _kConsultTypes = [
  'Muscle Building',
  'Weight Loss',
  'Injury Recovery',
  'Sports Performance',
  'Flexibility & Mobility',
  'Mental Fitness',
  'Nutrition Guidance',
  'Endurance Training',
];

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class TrainersPage extends StatefulWidget {
  const TrainersPage({super.key});

  @override
  State<TrainersPage> createState() => _TrainersPageState();
}

class _TrainersPageState extends State<TrainersPage> {
  final _search = TextEditingController();
  String _tag = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Trainer> get _filtered {
    final q = _query.toLowerCase();
    return _kTrainers.where((t) {
      final matchQ = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.title.toLowerCase().contains(q) ||
          t.tags.any((s) => s.toLowerCase().contains(q));
      final matchT = _tag == 'All' || t.tags.contains(_tag);
      return matchQ && matchT;
    }).toList();
  }

  bool _unlocked(Trainer t) => t.isFree || _kUserXP >= t.xpRequired;

  void _book(Trainer t) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _BookingSheet(trainer: t),
      );

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppColor.trainerBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            _SearchBar(ctrl: _search),
            _TagBar(active: _tag, onTap: (t) => setState(() => _tag = t)),
            _CountRow(
                total: list.length,
                online: list.where((t) => t.available).length),
            Expanded(
              child: list.isEmpty
                  ? const _Empty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: list.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _Card(
                          trainer: list[i],
                          unlocked: _unlocked(list[i]),
                          onBook: () => _book(list[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          // icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.trainerCyan, AppColor.trainerIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AppColor.trainerCyan.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🏋️', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),

          // title + subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                  children: [
                    TextSpan(text: 'Khel'),
                    TextSpan(
                        text: 'Coaches',
                        style: TextStyle(color: AppColor.trainerCyan)),
                  ],
                )),
                SizedBox(height: 2),
                Text(
                  'Connect with certified personal trainers',
                  style: TextStyle(color: AppColor.trainerMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          // XP pill  — Color.fromRGBO used in const context since withValues isn't const
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Color.fromRGBO(251, 191, 36, 0.12),
              border: Border.all(color: Color.fromRGBO(251, 191, 36, 0.28)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('⚡', style: TextStyle(fontSize: 13)),
              SizedBox(width: 4),
              Text(
                '$_kUserXP XP',
                style: TextStyle(
                  color: AppColor.trainerGold,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.ctrl});

  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name or specialty…',
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.28), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColor.trainerMuted, size: 20),
          suffixIcon: ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColor.trainerMuted, size: 18),
                  onPressed: ctrl.clear,
                )
              : null,
          filled: true,
          fillColor: AppColor.trainerCard,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide:
                const BorderSide(color: AppColor.trainerCyan, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAG BAR
// ─────────────────────────────────────────────────────────────────────────────

class _TagBar extends StatelessWidget {
  const _TagBar({required this.active, required this.onTap});

  final String active;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        itemCount: _kTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tag = _kTags[i];
          final on = active == tag;
          return GestureDetector(
            onTap: () => onTap(tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: on
                    ? const LinearGradient(
                        colors: [AppColor.trainerCyan, AppColor.trainerIndigo])
                    : null,
                color: on ? null : AppColor.trainerCard,
                border: Border.all(
                  color: on
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.08),
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: on
                    ? [
                        BoxShadow(
                            color: AppColor.trainerCyan.withValues(alpha: 0.25),
                            blurRadius: 10)
                      ]
                    : null,
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: on ? Colors.white : AppColor.trainerMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COUNT ROW
// ─────────────────────────────────────────────────────────────────────────────

class _CountRow extends StatelessWidget {
  const _CountRow({required this.total, required this.online});

  final int total, online;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text.rich(TextSpan(
        style: const TextStyle(fontSize: 12, color: AppColor.trainerMuted),
        children: [
          TextSpan(
            text: '$total',
            style: const TextStyle(
                color: AppColor.trainerCyan, fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' trainers  •  '),
          TextSpan(
            text: '$online',
            style: const TextStyle(
                color: AppColor.trainerGreen, fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' available now'),
        ],
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRAINER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatefulWidget {
  const _Card(
      {required this.trainer, required this.unlocked, required this.onBook});

  final Trainer trainer;
  final bool unlocked;
  final VoidCallback onBook;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.trainer;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColor.trainerCard,
            border: Border.all(
              color: _down
                  ? AppColor.trainerCyan.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.07),
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _down
                ? [
                    BoxShadow(
                        color: AppColor.trainerCyan.withValues(alpha: 0.10),
                        blurRadius: 18)
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── row 1: badge / status ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Pill(label: t.badge, color: t.badgeColor),
                  _Dot(available: t.available),
                ],
              ),
              const SizedBox(height: 16),

              // ── row 2: avatar / name ─────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(initials: t.initials, gradient: t.gradient),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(t.title,
                            style: const TextStyle(
                                color: AppColor.trainerMuted, fontSize: 12)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              color: AppColor.trainerGold, size: 13),
                          const SizedBox(width: 3),
                          Text(t.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: AppColor.trainerGold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Text('(${t.reviews})',
                              style: const TextStyle(
                                  color: AppColor.trainerSub, fontSize: 11)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── tags ─────────────────────────────────────────
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final tag in t.tags) _TagChip(label: tag)],
              ),
              const SizedBox(height: 14),

              // ── stats strip ──────────────────────────────────
              _Stats(
                experience: t.experience,
                sessions: t.sessions,
                isFree: t.isFree,
                xpRequired: t.xpRequired,
              ),

              // ── xp lock ──────────────────────────────────────
              if (!t.isFree && _kUserXP < t.xpRequired) ...[
                const SizedBox(height: 12),
                _LockNote(needed: t.xpRequired - _kUserXP),
              ],
              const SizedBox(height: 14),

              // ── cta ──────────────────────────────────────────
              widget.unlocked
                  ? _BookBtn(onTap: widget.onBook)
                  : _LockedBtn(xp: t.xpRequired),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({required this.trainer});

  final Trainer trainer;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _step = 1;
  String _type = '';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColor.trainerCard,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: switch (_step) {
              1 => _SheetStep1(
                  key: const ValueKey(1),
                  trainer: widget.trainer,
                  selected: _type,
                  onSelect: (v) => setState(() => _type = v),
                  onNext: () => setState(() => _step = 2),
                  onClose: () => Navigator.pop(context),
                ),
              2 => _SheetStep2(
                  key: const ValueKey(2),
                  trainer: widget.trainer,
                  type: _type,
                  note: _note,
                  onBack: () => setState(() => _step = 1),
                  onConfirm: () => setState(() => _step = 3),
                ),
              _ => _SheetDone(
                  key: const ValueKey(3),
                  name: widget.trainer.name,
                  onDone: () => Navigator.pop(context),
                ),
            },
          ),
        ),
      ),
    );
  }
}

// ── step 1 ───────────────────────────────────────────────────────────────────

class _SheetStep1 extends StatelessWidget {
  const _SheetStep1({
    super.key,
    required this.trainer,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onClose,
  });

  final Trainer trainer;
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext, onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Book a Session',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppColor.trainerMuted, size: 17),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _MiniTrainer(trainer: trainer),
        const SizedBox(height: 18),

        const Text('Select consultation type',
            style: TextStyle(
                color: AppColor.trainerSlate,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        // grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _kConsultTypes.length,
          itemBuilder: (_, i) {
            final type = _kConsultTypes[i];
            final on = selected == type;
            return GestureDetector(
              onTap: () => onSelect(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: on
                      ? AppColor.trainerCyan.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: on
                        ? AppColor.trainerCyan
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  if (on) ...[
                    const Icon(Icons.check_circle_rounded,
                        color: AppColor.trainerCyan, size: 12),
                    const SizedBox(width: 5),
                  ],
                  Expanded(
                    child: Text(type,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              on ? AppColor.trainerCyan : AppColor.trainerSlate,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        AnimatedOpacity(
          opacity: selected.isEmpty ? 0.38 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: _ActionBtn(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onTap: selected.isEmpty ? null : onNext,
          ),
        ),
      ],
    );
  }
}

// ── step 2 ───────────────────────────────────────────────────────────────────

class _SheetStep2 extends StatelessWidget {
  const _SheetStep2({
    super.key,
    required this.trainer,
    required this.type,
    required this.note,
    required this.onBack,
    required this.onConfirm,
  });

  final Trainer trainer;
  final String type;
  final TextEditingController note;
  final VoidCallback onBack, onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header
        Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Row(children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 11),
                SizedBox(width: 4),
                Text('Back',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add Details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 16),

        // selected type display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColor.trainerCyan.withValues(alpha: 0.07),
            border:
                Border.all(color: AppColor.trainerCyan.withValues(alpha: 0.22)),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CONSULTATION TYPE',
                style: TextStyle(
                    color: AppColor.trainerMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0)),
            const SizedBox(height: 4),
            Text(type,
                style: const TextStyle(
                    color: AppColor.trainerCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 14),

        const Text('Describe your goals',
            style: TextStyle(
                color: AppColor.trainerSlate,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        // note field
        TextField(
          controller: note,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. I want to build endurance for my 5K race…',
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.22), fontSize: 13),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColor.trainerCyan, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 14),

        // cost card
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColor.trainerGold.withValues(alpha: 0.06),
            border:
                Border.all(color: AppColor.trainerGold.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            _CostLine(
              label: 'XP Cost',
              value: trainer.isFree ? 'Free' : '${trainer.xpRequired} XP',
              color:
                  trainer.isFree ? AppColor.trainerGreen : AppColor.trainerGold,
            ),
            const SizedBox(height: 8),
            const _CostLine(
                label: 'Your Balance',
                value: '$_kUserXP XP',
                color: AppColor.trainerGreen),
          ]),
        ),
        const SizedBox(height: 16),

        _ActionBtn(
            label: 'Confirm Booking',
            icon: Icons.check_rounded,
            onTap: onConfirm),
      ],
    );
  }
}

// ── step 3: done ─────────────────────────────────────────────────────────────

class _SheetDone extends StatelessWidget {
  const _SheetDone({super.key, required this.name, required this.onDone});

  final String name;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text('🎉', style: TextStyle(fontSize: 58)),
        const SizedBox(height: 14),
        const Text('Booking Confirmed!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          'Your session with $name has been booked.\nThey\'ll reach out within 24 hours.',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColor.trainerMuted, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 18),

        // XP reward
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: AppColor.trainerGreen.withValues(alpha: 0.07),
            border: Border.all(
                color: AppColor.trainerGreen.withValues(alpha: 0.20)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('+50 XP Earned!',
                    style: TextStyle(
                        color: AppColor.trainerGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                Text('Booking bonus for this week',
                    style: TextStyle(
                        color: AppColor.trainerMuted.withValues(alpha: 0.75),
                        fontSize: 12)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 18),

        _ActionBtn(label: 'Done', icon: Icons.done_rounded, onTap: onDone),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATOMS
// ─────────────────────────────────────────────────────────────────────────────

/// Coloured pill (badge label)
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          border: Border.all(color: color.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text('✦ $label',
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3)),
      );
}

/// Pulsing availability indicator
class _Dot extends StatefulWidget {
  const _Dot({required this.available});
  final bool available;
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);
  late final _anim = Tween<double>(begin: 0.30, end: 1.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.available ? AppColor.trainerGreen : AppColor.trainerRed;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      FadeTransition(
        opacity: _anim,
        child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      ),
      const SizedBox(width: 5),
      Text(widget.available ? 'Available' : 'Busy',
          style:
              TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}

/// Gradient initials avatar
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.gradient});
  final String initials;
  final _Gradient gradient;

  @override
  Widget build(BuildContext context) => Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [gradient.a, gradient.b]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: gradient.a.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: Center(
          child: Text(initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
        ),
      );
}

/// Small tag chip
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppColor.trainerSlate,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      );
}

/// 3-cell stats strip
class _Stats extends StatelessWidget {
  const _Stats({
    required this.experience,
    required this.sessions,
    required this.isFree,
    required this.xpRequired,
  });
  final String experience;
  final int sessions, xpRequired;
  final bool isFree;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            _StatCell(label: 'Exp.', value: experience),
            VerticalDivider(
                color: Colors.white.withValues(alpha: 0.07), width: 1),
            _StatCell(label: 'Sessions', value: '$sessions'),
            VerticalDivider(
                color: Colors.white.withValues(alpha: 0.07), width: 1),
            _StatCell(
              label: 'To Book',
              value: isFree ? 'Free' : '$xpRequired XP',
              color: isFree ? AppColor.trainerGreen : AppColor.trainerGold,
            ),
          ]),
        ),
      );
}

class _StatCell extends StatelessWidget {
  const _StatCell(
      {required this.label, required this.value, this.color = Colors.white});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColor.trainerSub, fontSize: 9)),
        ]),
      );
}

/// XP lock warning
class _LockNote extends StatelessWidget {
  const _LockNote({required this.needed});
  final int needed;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColor.trainerRed.withValues(alpha: 0.07),
          border:
              Border.all(color: AppColor.trainerRed.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(children: [
          const Text('🔒', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 7),
          Text('Need $needed more XP to unlock',
              style: const TextStyle(color: Color(0xFFF87171), fontSize: 11)),
        ]),
      );
}

/// Gradient book button
class _BookBtn extends StatelessWidget {
  const _BookBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColor.trainerCyan, AppColor.trainerIndigo]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppColor.trainerCyan.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Center(
            child: Text('Book Consultation  →',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.3)),
          ),
        ),
      );
}

/// Greyed locked button
class _LockedBtn extends StatelessWidget {
  const _LockedBtn({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('🔒  $xp XP Required to Unlock',
              style: const TextStyle(
                  color: AppColor.trainerMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      );
}

/// Generic action button (used in sheet steps)
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColor.trainerCyan, AppColor.trainerIndigo]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppColor.trainerCyan.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3)),
            const SizedBox(width: 6),
            Icon(icon, color: Colors.white, size: 15),
          ]),
        ),
      );
}

/// Cost summary line in sheet step 2
class _CostLine extends StatelessWidget {
  const _CostLine(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColor.trainerSlate, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      );
}

/// Mini trainer card shown at top of sheet
class _MiniTrainer extends StatelessWidget {
  const _MiniTrainer({required this.trainer});
  final Trainer trainer;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(children: [
          _Avatar(initials: trainer.initials, gradient: trainer.gradient),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(trainer.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            const SizedBox(height: 2),
            Text(trainer.title,
                style: const TextStyle(
                    color: AppColor.trainerMuted, fontSize: 12)),
          ]),
        ]),
      );
}

/// Empty search state
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🔍', style: TextStyle(fontSize: 44)),
          SizedBox(height: 14),
          Text('No trainers found',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text('Try a different search or filter',
              style: TextStyle(color: AppColor.trainerMuted, fontSize: 13)),
        ]),
      );
}
