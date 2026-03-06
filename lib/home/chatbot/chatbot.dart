import 'package:flutter/material.dart';
import 'package:khel_yuva/res/colors.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  void sendMessage() {
    if (controller.text.isEmpty) return;

    setState(() {
      messages.add({"type": "user", "text": controller.text});
      messages.add({"type": "bot", "text": "I'm your fitness assistant 💪"});
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KY.bg,
      appBar: AppBar(
        backgroundColor: KY.surface,
        title: const Text(
          "AI Fitness Assistant",
          style: TextStyle(color: KY.textPri),
        ),
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["type"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? KY.accent : KY.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: KY.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      hintStyle: TextStyle(color: KY.textSec),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: KY.accent),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
