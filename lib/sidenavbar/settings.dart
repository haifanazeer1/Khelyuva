import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';
import 'package:khel_yuva/sidenavbar/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() => runApp(const SettingsApp());

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  /// Pass the logged-in user's display name here.
  /// Defaults to an empty string so it's always safe to use.
  final String username;

  const SettingsPage({super.key, this.username = ''});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  String appearanceMode = 'dark';
  String _username = '';
  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.setbg,
      appBar: AppBar(
        backgroundColor: AppColor.setbg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColor.settextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColor.settextPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Quick-View ─────────────────────────────────────────
            _ProfileCard(username: _username),
            const SizedBox(height: 28),

            // ── Account ───────────────────────────────────────────────────
            const _SectionHeader(title: 'Account'),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColor.setaccent,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFFE040FB),
                  title: 'Change Password',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Notifications ─────────────────────────────────────────────
            const _SectionHeader(title: 'Notifications'),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsToggle(
                  icon: Icons.notifications_outlined,
                  iconColor: const Color(0xFFFFAB40),
                  title: 'Push Notifications',
                  subtitle: 'Receive in-app alerts',
                  value: pushNotifications,
                  onChanged: (val) => setState(() => pushNotifications = val),
                ),
                _SettingsDivider(),
                _SettingsToggle(
                  icon: Icons.email_outlined,
                  iconColor: const Color(0xFF00BFA5),
                  title: 'Email Notifications',
                  subtitle: 'Get updates via email',
                  value: emailNotifications,
                  onChanged: (val) => setState(() => emailNotifications = val),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Appearance ────────────────────────────────────────────────
            const _SectionHeader(title: 'Appearance'),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _AppearanceTile(
                  icon: Icons.light_mode_rounded,
                  iconColor: const Color(0xFFFFAB40),
                  label: 'Light Mode',
                  value: 'light',
                  groupValue: appearanceMode,
                  onChanged: (val) => setState(() => appearanceMode = val!),
                ),
                _SettingsDivider(),
                _AppearanceTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: AppColor.setaccent,
                  label: 'Dark Mode',
                  value: 'dark',
                  groupValue: appearanceMode,
                  onChanged: (val) => setState(() => appearanceMode = val!),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Support ───────────────────────────────────────────────────
            const _SectionHeader(title: 'Support'),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColor.settextSecondary,
                  title: 'Help & FAQ',
                  onTap: () {},
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColor.settextSecondary,
                  title: 'About KhelYuva',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Logout ────────────────────────────────────────────────────
            _LogoutButton(
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.setsurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColor.setborder),
        ),
        title: const Text('Log Out?',
            style: TextStyle(
                color: AppColor.settextPrimary, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: AppColor.settextSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColor.settextSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Handle logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.setdanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String username;

  static const _accent = Color(0xFF6C63FF);
  static const _surface = Color(0xFF1A1A2E);
  static const _border = Color(0xFF2A2A4A);

  const _ProfileCard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent, Color(0xFFE040FB)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              username.isNotEmpty ? username : 'User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Settings Group (card container) ──────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(children: children),
    );
  }
}

// ── Settings Divider ──────────────────────────────────────────────────────────
class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFF2A2A4A),
      indent: 56,
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _IconBadge(icon: icon, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: const TextStyle(
                              color: Color(0xFF9090B0), fontSize: 12)),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF9090B0), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings Toggle ───────────────────────────────────────────────────────────
class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          color: Color(0xFF9090B0), fontSize: 12)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6C63FF),
            inactiveThumbColor: const Color(0xFF9090B0),
            inactiveTrackColor: const Color(0xFF2A2A4A),
          ),
        ],
      ),
    );
  }
}

// ── Appearance Tile ───────────────────────────────────────────────────────────
class _AppearanceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _AppearanceTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _IconBadge(icon: icon, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF4A4A6A),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5370).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF5370).withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFFF5370), size: 20),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFFF5370),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Icon Badge ────────────────────────────────────────────────────────────────
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
