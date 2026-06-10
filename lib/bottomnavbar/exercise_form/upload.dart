import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:khel_yuva/home/exppoints/activity_model.dart';

class UploadFormScreen extends StatefulWidget {
  const UploadFormScreen({super.key});

  @override
  State<UploadFormScreen> createState() => _UploadFormScreenState();
}

class _UploadFormScreenState extends State<UploadFormScreen> {
  final TextEditingController _type = TextEditingController();
  bool _isAnalyzing = false;
  bool _isSaving = false;
  Uint8List? _videoBytes;
  String? _videoFileName;

  // Analysis results
  Map<String, dynamic>? _analysisResult;

  // Use 10.0.2.2 for Android emulator
  static const String _backendUrl = "http://192.168.29.21:8001";

  //PICK VIDEO
  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;
      final bytes =
          pickedFile.bytes ?? await File(pickedFile.path!).readAsBytes();

      if (!mounted) return;
      setState(() {
        _videoBytes = bytes;
        _videoFileName = pickedFile.name;
        _analysisResult = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick video: $e')),
      );
    }
  }

  //ANALYSING VIDEO
  Future<void> _analyseVideo() async {
    if (_videoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a video first')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_backendUrl/analyze-video'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _videoBytes!,
          filename: _videoFileName ?? 'exercise.mp4',
          contentType: MediaType('video', 'mp4'),
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 120),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final angles = data['angles'];

        final result = ActivityEngine.analyze(
          knee: (angles['average_knee_angle'] as num).toDouble(),
          hip: (angles['average_hip_angle'] as num).toDouble(),
          shoulder: (angles['average_shoulder_angle'] as num).toDouble(),
          feedback: data['feedback']['overall'],
        );
        final user = Supabase.instance.client.auth.currentUser;

        if (user != null) {
          await Supabase.instance.client.from('session_results').insert({
            'user_id': user.id,
            'knee_angle': result.kneeAngle,
            'hip_angle': result.hipAngle,
            'shoulder_angle': result.shoulderAngle,
            'activity_level': result.activityLevel,
            'badge': result.badge,
            'xp': result.xp,
          });
        }

        setState(() {
          _analysisResult = data;
          _isAnalyzing = false;
        });

        if (user != null) {
          // SAVE XP HISTORY
          await Supabase.instance.client.from('xp_history').insert({
            'user_id': user.id,
            'action': 'Completed Pushup Analysis',
            'xp': result.xp,
            'type': 'workout',
          });
          // GET CURRENT XP
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('total_xp')
              .eq('id', user.id)
              .single();

          final currentXP = profile['total_xp'] ?? 0;

          final updatedXP = currentXP + result.xp;

          final level = (updatedXP ~/ 300) + 1;

          await Supabase.instance.client.from('profiles').update({
            'total_xp': updatedXP,
            'level': level,
          }).eq('id', user.id);
          // OPTIONAL SUCCESS MESSAGE
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('+${result.xp} XP Earned! ⚡'),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        final error = jsonDecode(response.body);
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Analysis failed: ${error['detail'] ?? response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not connect to backend. Make sure it\'s running.\nError: $e',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  //SAVE TO PROFILE
  Future<void> _saveToProfile() async {
    if (_videoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a video')),
      );
      return;
    }

    if (_type.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter type of exercise')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      final fileName = 'exercise_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await supabase.storage.from('videos').uploadBinary(
            fileName,
            _videoBytes!,
            fileOptions: const FileOptions(contentType: 'video/mp4'),
          );

      final videoUrl = supabase.storage.from('videos').getPublicUrl(fileName);

      await supabase.schema('upload_form').from('exercises').insert({
        'type': _type.text.trim(),
        'video_url': videoUrl,
        if (_analysisResult != null) ...{
          'analysis_overall': _analysisResult!['feedback']?['overall'],
          'analysis_frames': _analysisResult!['frames_analyzed'],
        }
      });

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _type.clear();
        _videoBytes = null;
        _videoFileName = null;
        _analysisResult = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise saved to profile!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _type.dispose();
    super.dispose();
  }

  Widget _buildAngleChip(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A3E),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            '${value.toStringAsFixed(1)}°',
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9090B0), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final feedback = _analysisResult!['feedback'] as Map<String, dynamic>;
    final angles = _analysisResult!['angles'] as Map<String, dynamic>;
    final issues = feedback['issues'] as List<dynamic>;
    final tips = feedback['tips'] as List<dynamic>;
    final overall = feedback['overall'] as String;

    return Container(
      margin: const EdgeInsets.only(top: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: Color(0xFF6C63FF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Analysis Results',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '${_analysisResult!['frames_analyzed']} frames',
                style: const TextStyle(color: Color(0xFF9090B0), fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Overall verdict
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              overall,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Angle chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAngleChip(
                  'Knee', (angles['average_knee_angle'] as num).toDouble()),
              _buildAngleChip(
                  'Hip', (angles['average_hip_angle'] as num).toDouble()),
              _buildAngleChip('Shoulder',
                  (angles['average_shoulder_angle'] as num).toDouble()),
            ],
          ),

          const SizedBox(height: 16),

          // Issues
          const Text(
            'Form Assessment',
            style: TextStyle(
              color: Color(0xFF9090B0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...issues.map((issue) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      (issue as String).contains('✅')
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      color: issue.contains('✅')
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        issue,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),

          if (tips.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Tips to Improve',
              style: TextStyle(
                color: Color(0xFF9090B0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: Color(0xFF6C63FF), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip as String,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text(
          "Upload Exercise",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //HERO HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A3E), Color(0xFF0F0F1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upload Your Performance",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "AI will analyse your exercise form",
                      style: TextStyle(color: Color(0xFF9090B0), fontSize: 13),
                    ),
                  ],
                ),
              ),

              //VIDEO CARD
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _videoFileName != null
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF2A2A4A),
                    ),
                  ),
                  child: Center(
                    child: _videoFileName != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF6C63FF), size: 40),
                              const SizedBox(height: 10),
                              Text(
                                _videoFileName!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Tap to change",
                                style: TextStyle(
                                    color: Color(0xFF9090B0), fontSize: 11),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_rounded,
                                  color: Color(0xFF6C63FF), size: 40),
                              SizedBox(height: 10),
                              Text("Tap to upload video",
                                  style: TextStyle(color: Color(0xFF9090B0))),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //EXERCISE TYPE FIELD
              TextField(
                controller: _type,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.fitness_center_rounded,
                      color: Color(0xFF6C63FF)),
                  hintText: "Type of Exercise",
                  hintStyle: const TextStyle(color: Color(0xFF9090B0)),
                  filled: true,
                  fillColor: const Color(0xFF1A1A2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //ANALYSE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isAnalyzing
                    ? Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFF00E5FF),
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Analysing your form...',
                              style: TextStyle(
                                  color: Color(0xFF00E5FF), fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _analyseVideo,
                        icon: const Icon(Icons.bar_chart_rounded,
                            color: Colors.black),
                        label: const Text(
                          "Analyse My Form",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
              ),

              // ANALYSIS RESULTS
              _buildAnalysisResults(),

              const SizedBox(height: 20),

              //SAVE TO PROFILE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isSaving
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF6C63FF)))
                    : ElevatedButton.icon(
                        onPressed: _saveToProfile,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text(
                          "Save to Profile",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
