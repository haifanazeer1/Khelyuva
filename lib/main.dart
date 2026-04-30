import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/*import 'package:khel_yuva/bottomnavbar/exercise_form/real_time_analysis/exercise_selection.dart';
import 'package:khel_yuva/bottomnavbar/exercise_form/real_time_analysis/live_workout.dart';
import 'package:khel_yuva/bottomnavbar/exercise_form/real_time_analysis/result_screen.dart';
import 'package:khel_yuva/home/chatbotbk/chatbotscreen.dart';*/
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khel_yuva/constants/config.dart';
/*import 'package:khel_yuva/bottomnavbar/leaderboard.dart';
import 'package:khel_yuva/bottomnavbar/exercise_form/upload.dart';
import 'package:khel_yuva/faq.dart';*/
import 'package:khel_yuva/home/homepage.dart';
import 'package:khel_yuva/sidenavbar/aboutus.dart';
import 'package:khel_yuva/sidenavbar/dietrecommendation/diet.dart';
import 'package:khel_yuva/sidenavbar/profile.dart';
import 'package:khel_yuva/sidenavbar/settings.dart';
import 'package:khel_yuva/widgets/login.dart';
import 'package:khel_yuva/widgets/register.dart';
import 'package:khel_yuva/home/dashboard.dart';
import 'package:khel_yuva/home/exp points/xp.dart';
import 'package:khel_yuva/home/personal_trainer/ptrainer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
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
      home: Supabase.instance.client.auth.currentSession == null
          ? const SignInScreen()
          : const HomePage(),
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
