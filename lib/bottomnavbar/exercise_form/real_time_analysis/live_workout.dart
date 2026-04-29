import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
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

  final String baseUrl = "http://192.168.0.101:5000";

  Timer? timer;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    final videoUrl =
        "$baseUrl/video_feed?key=${Uri.encodeComponent(widget.exercise)}";
    print("VIDEO URL: $videoUrl");
    // WebView setup
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(videoUrl));

    // Fetch status every 1 sec
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
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

        setState(() {
          reps = data["reps"] ?? 0;
          feedback = data["feedback"] ?? "Starting...";
        });
      }
    } catch (e) {
      print("Error fetching status: $e");
    }
  }

  Color getFeedbackColor(String feedback) {
    if (feedback.toLowerCase().contains("good")) {
      return Colors.green;
    } else if (feedback.toLowerCase().contains("keep")) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
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
          // VIDEO STREAM (FIXED)
          Expanded(
            child: Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: WebViewWidget(controller: controller),
              ),
            ),
          ),

          // DATA
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
                    color: getFeedbackColor(feedback),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // STOP BUTTON
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                timer?.cancel();

                Navigator.push(
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
