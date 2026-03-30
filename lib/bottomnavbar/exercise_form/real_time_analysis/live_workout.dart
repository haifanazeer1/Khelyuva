import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:khel_yuva/bottomnavbar/exercise_form/real_time_analysis/result_screen.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final String exercise;

  LiveWorkoutScreen({required this.exercise});

  @override
  _LiveWorkoutScreenState createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  int reps = 0;
  String feedback = "Starting...";

  final String baseUrl = "http://192.168.1.5:5000";

  Timer? timer;
  late String videoUrl;

  @override
  void initState() {
    super.initState();

    // ✅ FIX 1: Set video URL ONCE
    videoUrl = "$baseUrl/video_feed?key=${widget.exercise}";

    // ✅ FIX 2: Prevent multiple timers
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      fetchStatus();
    });
  }

  Future<void> fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/status"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            reps = data["reps"] ?? 0;
            feedback = data["feedback"] ?? "Starting...";
          });
        }
      }
    } catch (e) {
      print("Error fetching status: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.exercise),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🎥 VIDEO STREAM (FIXED)
          Expanded(
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  videoUrl,
                  fit: BoxFit.cover,
                  gaplessPlayback: true, // ✅ important
                  headers: {"Connection": "keep-alive"}, // ✅ helps MJPEG
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        "⚠️ Unable to load video",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 📊 LIVE DATA
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  "Reps: $reps",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  feedback,
                  style: TextStyle(
                    color: feedback == "Good form"
                        ? Colors.green
                        : Colors.redAccent,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // 🔴 STOP BUTTON
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                timer?.cancel();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(exercise: widget.exercise),
                  ),
                );
              },
              child: Text(
                "STOP & VIEW RESULTS",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
