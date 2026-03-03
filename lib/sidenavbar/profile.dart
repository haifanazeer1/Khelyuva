import 'package:flutter/material.dart';
import 'package:khel_yuva/home/homepage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final TextEditingController _name = TextEditingController(text: "Name");
  final TextEditingController _email =
      TextEditingController(text: "name@example.com");
  final TextEditingController _phone =
      TextEditingController(text: "+1234567890");
  final TextEditingController _state = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
            icon: Icon(
              isEditing ? Icons.save_rounded : Icons.edit_rounded,
              color: const Color(0xFF6C63FF),
            ),
            label: Text(
              isEditing ? "Save" : "Edit",
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHero(),
            const SizedBox(height: 30),
            _ProfileForm(
              isEditing: isEditing,
              name: _name,
              email: _email,
              phone: _phone,
              state: _state,
              city: _city,
              address: _address,
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// HERO SECTION
////////////////////////////////////////////////////////////////

class _ProfileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A3E), Color(0xFF0F0F1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFE040FB)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "N",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Name",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Athlete • KhelYuva Member",
            style: TextStyle(
              color: Color(0xFF9090B0),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// FORM SECTION
////////////////////////////////////////////////////////////////

class _ProfileForm extends StatelessWidget {
  final bool isEditing;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController state;
  final TextEditingController city;
  final TextEditingController address;

  const _ProfileForm({
    required this.isEditing,
    required this.name,
    required this.email,
    required this.phone,
    required this.state,
    required this.city,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A4A)),
        ),
        child: Column(
          children: [
            _buildField("Name", name),
            _buildField("Email", email),
            _buildField("Phone", phone),
            _buildField("State", state),
            _buildField("City", city),
            _buildField("Address", address, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF9090B0)),
          filled: true,
          fillColor: const Color(0xFF141428),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          ),
        ),
      ),
    );
  }
}
