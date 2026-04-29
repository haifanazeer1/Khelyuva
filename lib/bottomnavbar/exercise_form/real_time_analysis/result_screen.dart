import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultScreen extends StatefulWidget {
  final String exercise;

  ResultScreen({required this.exercise});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? imageBase64;
  bool isLoading = true;
  String errorMessage = "";

  // BASE URL
  final String baseUrl = "http://192.168.0.101:5000";

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/results"),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY LENGTH: ${response.body.length}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          imageBase64 = response.body;
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          errorMessage = "No data received";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Error loading results";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Results"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.cyanAccent)
            : errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: TextStyle(color: Colors.redAccent),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),

                        //TITLE
                        Text(
                          widget.exercise,
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 20),

                        //GRAPH
                        Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1A1F3A),
                                Color(0xFF0D1330),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: imageBase64 != null
                                ? Image.memory(
                                    base64Decode(imageBase64!),
                                    fit: BoxFit.contain, // 🔥 better fit
                                  )
                                : Text(
                                    "No image",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // BACK BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Back",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}
