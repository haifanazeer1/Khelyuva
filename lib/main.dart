import 'package:flutter/material.dart';
import 'package:khel_yuva/bottomnavbar/leaderboard.dart';
import 'package:khel_yuva/bottomnavbar/upload.dart';
import 'package:khel_yuva/sidenavbar/profile.dart';
import 'package:khel_yuva/widgets/Login.dart';
import 'package:khel_yuva/widgets/register.dart';
import 'sidenavbar/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KhelYuva',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: UploadFormScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KhelYuva'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to Khel Yuva',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
