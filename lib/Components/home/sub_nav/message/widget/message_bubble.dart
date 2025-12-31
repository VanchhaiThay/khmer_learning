import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final User currentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUser,
  });

  Future<String> _getSenderName() async {
    if (message['senderUid'] == currentUser.uid) {
      return currentUser.displayName ?? "Me";
    }

    // If senderName exists, use it
    if (message['senderName'] != null) {
      return message['senderName'];
    }

    // Otherwise fetch from Firestore
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(message['senderUid'])
            .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final firstName = data['first_name'] ?? '';
        final lastName = data['last_name'] ?? '';
        return "$firstName $lastName".trim();
      }
    }

    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message['senderUid'] == currentUser.uid;
    final bgColor = isMe ? Colors.deepPurpleAccent : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black87;

    // Original timestamp
    String time = "";
    if (message['timestamp'] != null) {
      final dt = (message['timestamp'] as dynamic).toDate();
      time =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    // Edited timestamp
    String editedTime = "";
    if (message['editedAt'] != null) {
      final dt = (message['editedAt'] as dynamic).toDate();
      editedTime =
          "Edited: ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return FutureBuilder<String>(
      future: _getSenderName(),
      builder: (context, snapshot) {
        final senderName = snapshot.data ?? "Loading...";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      "https://api.dicebear.com/7.x/fun-emoji/png?seed=${message['senderUid']}",
                    ),
                  ),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width *
                        0.7, // max width 70% of screen
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message['text'],
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                          if (editedTime.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              editedTime,
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}
