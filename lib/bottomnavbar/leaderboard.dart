import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaderboardScreen(),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              // Navigate to profile/settings page
              // Navigator.push(context,
              //   MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFE040FB)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        title: const Text(
          "LEADERBOARD",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A1F44), Color(0xFF102E66)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // PODIUM
              const PodiumSection(),

              const SizedBox(height: 30),

              // LEADER LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    LeaderTile(
                      medalColor: Colors.amber,
                      medalText: "1",
                      name: "Mia",
                      points: "2,000 points",
                    ),
                    LeaderTile(
                      medalColor: Colors.grey,
                      medalText: "2",
                      name: "Brain",
                      points: "1,700 points",
                    ),
                    LeaderTile(
                      medalColor: Color(0xFFCD7F32),
                      medalText: "3",
                      name: "Jake",
                      points: "1,500 points",
                    ),
                    LeaderTile(
                      medalColor: Colors.amber,
                      medalText: "",
                      name: "Tony",
                      points: "1,300 points",
                    ),
                    LeaderTile(
                      medalColor: Colors.amber,
                      medalText: "",
                      name: "Nat",
                      points: "1,100 points",
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
}

class PodiumSection extends StatelessWidget {
  const PodiumSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          podiumBox("2", 80, Colors.orange),
          const SizedBox(width: 15),
          podiumBox("1", 120, Colors.blue),
          const SizedBox(width: 15),
          podiumBox("3", 60, Colors.deepOrange),
        ],
      ),
    );
  }

  Widget podiumBox(String text, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (text == "1") const Icon(Icons.star, color: Colors.amber, size: 30),
        Container(
          width: 60,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class LeaderTile extends StatelessWidget {
  final Color medalColor;
  final String medalText;
  final String name;
  final String points;

  const LeaderTile({
    super.key,
    required this.medalColor,
    required this.medalText,
    required this.name,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: medalColor,
            child: Text(
              medalText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
