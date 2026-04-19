import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khel_yuva/res/colors.dart';

class PaymentScreen extends StatefulWidget {
  final Map trainer;

  const PaymentScreen({super.key, required this.trainer});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = false;

  Future<void> confirmBooking() async {
    setState(() => isLoading = true);

    final user = supabase.auth.currentUser;

    await supabase.from('bookings').insert({
      'user_id': user!.id,
      'trainer_id': widget.trainer['id'],
      'amount': widget.trainer['price_per_session'],
      'status': 'paid',
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful 🎉")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final trainer = widget.trainer;

    return Scaffold(
      backgroundColor: KY.bg,
      appBar: AppBar(
        backgroundColor: KY.surface,
        title: const Text("Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🧑 Trainer Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KY.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: KY.accent,
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer['name'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        trainer['specialization'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 💰 Payment Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KY.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _row("Session Price", "₹${trainer['price_per_session']}"),
                  const SizedBox(height: 10),
                  _row("Platform Fee", "₹20"),
                  const Divider(color: Colors.white24),
                  _row("Total", "₹${trainer['price_per_session'] + 20}",
                      bold: true),
                ],
              ),
            ),

            const Spacer(),

            // 🔥 PAY BUTTON
            GestureDetector(
              onTap: isLoading ? null : confirmBooking,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: KY.gradientAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "Pay Now",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            color: bold ? KY.accent : Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
