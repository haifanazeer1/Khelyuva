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

  final String baseUrl = "http://192.168.1.5:5000";

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/results?key=${Uri.encodeComponent(widget.exercise)}",
        ),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() {
          imageBase64 = response.body;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "No data received";
          isLoading = false;
        });
      }
    } catch (e) {
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
                        Text(
                          widget.exercise,
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
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
                            child: Image.memory(
                              base64Decode(imageBase64!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
