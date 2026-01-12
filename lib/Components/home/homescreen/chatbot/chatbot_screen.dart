import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ChatBotScreen extends StatefulWidget {
  @override
  State<ChatBotScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatBotScreen> {
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool botTyping = false;

  @override
  void initState() {
    super.initState();
    _showInitialBotMessage();
  }

  void _showInitialBotMessage() {
    setState(() => botTyping = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add({"bot": "Hi! How can I help you today?"});
        botTyping = false;
      });
      _scrollToBottom();
    });
  }

  void sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      messages.add({"user": message});
      botTyping = true;
    });

    controller.clear();
    _scrollToBottom();

    var url = Uri.parse("http://10.0.2.2:5000/chat");

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      String reply = response.statusCode == 200
          ? jsonDecode(response.body)["reply"]
          : "Server connection failed.";

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          messages.add({"bot": reply});
          botTyping = false;
        });
        _scrollToBottom();
      });
    } catch (_) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          messages.add({"bot": "Server connection failed."});
          botTyping = false;
        });
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> msg) {
    bool isUser = msg.containsKey("user");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    const AssetImage("assets/bot/chatboticon.png"),
              ),
            ),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.blueAccent
                    : isDark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 12),
                ),
              ),
              child: Text(
                isUser ? msg["user"]! : msg["bot"]!,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Chatbot"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length + (botTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (botTyping && index == messages.length) {
                  return _typingIndicator(isDark);
                }
                return _buildMessage(messages[index]);
              },
            ),
          ),
          _inputBar(isDark),
        ],
      ),
    );
  }

  Widget _typingIndicator(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage("assets/bot/chatboticon.png"),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Text("Typing..."),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: sendMessage,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white54
                        : Colors.black54),
                filled: true,
                fillColor:
                    isDark ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => sendMessage(controller.text),
            ),
          ),
        ],
      ),
    );
  }
}