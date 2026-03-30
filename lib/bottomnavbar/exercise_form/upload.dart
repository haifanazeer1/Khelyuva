import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khel_yuva/constants/config.dart';

class UploadFormScreen extends StatefulWidget {
  const UploadFormScreen({super.key});

  @override
  State<UploadFormScreen> createState() => _UploadFormScreenState();
}

class _UploadFormScreenState extends State<UploadFormScreen> {
  final TextEditingController _type = TextEditingController();

  VideoPlayerController? _videoController;
  File? _videoFile;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Uint8List? _videoBytes; // for web

  // ================= PICK VIDEO =================
  Future<void> _pickVideo() async {
    try {
      final XFile? pickedVideo =
          await _picker.pickVideo(source: ImageSource.gallery);

      if (pickedVideo != null) {
        await _videoController?.dispose();

        if (kIsWeb) {
          // Web: read as bytes
          final bytes = await pickedVideo.readAsBytes();
          _videoBytes = bytes;

          _videoController = VideoPlayerController.network(pickedVideo.path)
            ..initialize().then((_) {
              setState(() {});
            });
        } else {
          // Mobile: use File
          File file = File(pickedVideo.path);
          _videoFile = file;
          _videoBytes = await file.readAsBytes();

          _videoController = VideoPlayerController.file(file)
            ..initialize().then((_) {
              setState(() {});
            });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick video: $e')),
      );
    }
  }

// ================= SUBMIT =================
  Future<void> _submitForm() async {
    if (_videoController == null || !_videoController!.value.isInitialized) {
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

    if (_videoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video data not found, please re-upload')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Upload video to Supabase Storage
      final fileName = 'exercise_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await supabase.storage.from('videos').uploadBinary(
            fileName,
            _videoBytes!,
            fileOptions: const FileOptions(contentType: 'video/mp4'),
          );

      // 2. Get the public URL
      final videoUrl = supabase.storage.from('videos').getPublicUrl(fileName);

      // 3. Save to database
      // ✅ To this
      await supabase.schema('upload_form').from('exercises').insert({
        'type': _type.text.trim(),
        'video_url': videoUrl,
      });

      // 4. Reset form
      setState(() {
        _isLoading = false;
        _type.clear();
        _videoController?.dispose();
        _videoController = null;
        _videoFile = null;
        _videoBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise uploaded successfully!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
              /// ───────── HERO HEADER ─────────
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
                      style: TextStyle(
                        color: Color(0xFF9090B0),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              /// ───────── VIDEO CARD ─────────
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF2A2A4A),
                    ),
                  ),
                  child: _videoController != null &&
                          _videoController!.value.isInitialized
                      ? Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                size: 36,
                                color: const Color(0xFF6C63FF),
                              ),
                              onPressed: () {
                                setState(() {
                                  _videoController!.value.isPlaying
                                      ? _videoController!.pause()
                                      : _videoController!.play();
                                });
                              },
                            ),
                          ],
                        )
                      : const SizedBox(
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_rounded,
                                  color: Color(0xFF6C63FF),
                                  size: 40,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Tap to upload video",
                                  style: TextStyle(
                                    color: Color(0xFF9090B0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              /// ───────── EXERCISE TYPE FIELD ─────────
              TextField(
                controller: _type,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFF6C63FF),
                  ),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF6C63FF),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// ───────── SUBMIT BUTTON ─────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Submit Exercise",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
