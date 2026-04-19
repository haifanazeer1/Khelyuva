import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:khel_yuva/home/personal_trainer/paymentscreen.dart';

class NearbyTrainersScreen extends StatefulWidget {
  const NearbyTrainersScreen({super.key});

  @override
  State<NearbyTrainersScreen> createState() => _NearbyTrainersScreenState();
}

class _NearbyTrainersScreenState extends State<NearbyTrainersScreen> {
  final supabase = Supabase.instance.client;

  List trainers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNearbyTrainers();
  }

  // 🔥 FETCH DATA
  Future<void> fetchNearbyTrainers() async {
    try {
      final data = await supabase.rpc('nearby_trainers', params: {
        'lat': 17.385,
        'lng': 78.486,
      });

      setState(() {
        trainers = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // 🗺️ CREATE MARKERS
  Set<Marker> _buildMarkers() {
    return trainers.map<Marker>((t) {
      final lat = t['latitude'] ?? 17.385;
      final lng = t['longitude'] ?? 78.486;

      return Marker(
        markerId: MarkerId(t['id'].toString()),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: t['name']),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KY.bg,
      appBar: AppBar(
        backgroundColor: KY.surface,
        elevation: 0,
        title: const Text(
          "Find Trainers",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildMapPreview(),
                _buildSectionTitle("Nearby Trainers"),
                Expanded(child: _buildTrainerList()),
              ],
            ),
    );
  }

  // 🔍 SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: KY.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KY.divider),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: KY.textSec),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search trainers...",
                  hintStyle: TextStyle(color: KY.textSec),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🗺️ REAL GOOGLE MAP
  Widget _buildMapPreview() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.hardEdge,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(17.385, 78.486), // default center
            zoom: 13,
          ),
          markers: _buildMarkers(),
          myLocationEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text('See All', style: TextStyle(color: KY.accent.withOpacity(0.8))),
        ],
      ),
    );
  }

  // 📋 TRAINER LIST
  Widget _buildTrainerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: trainers.length,
      itemBuilder: (context, index) {
        final t = trainers[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KY.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KY.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: KY.gradientAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['name'] ?? "Trainer",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['specialization'] ?? "",
                      style: const TextStyle(color: KY.textSec, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text("${t['rating'] ?? 0}",
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(width: 10),
                        Text(
                          "₹${t['price_per_session'] ?? 0}",
                          style: const TextStyle(
                              color: KY.accent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(trainer: t),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: KY.gradientAccent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: KY.accent.withValues(alpha: 0.4),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Text(
                    "Book",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 📅 BOOKING
  Future<void> bookTrainer(String trainerId) async {
    final user = supabase.auth.currentUser;

    await supabase.from('bookings').insert({
      'user_id': user!.id,
      'trainer_id': trainerId,
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking sent 🚀")),
    );
  }
}
