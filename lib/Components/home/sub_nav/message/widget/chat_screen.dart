import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khmerlearning/Components/home/sub_nav/message/widget/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String friendUid;
  final String friendName;

  const ChatScreen({
    super.key,
    required this.friendUid,
    required this.friendName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  late String chatDocId;
  final ScrollController _scrollController = ScrollController();
  bool showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    final uids = [currentUser.uid, widget.friendUid]..sort();
    chatDocId = uids.join('_');

    _scrollController.addListener(() {
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - 100) {
        if (!showScrollToBottom) {
          setState(() {
            showScrollToBottom = true;
          });
        }
      } else {
        if (showScrollToBottom) {
          setState(() {
            showScrollToBottom = false;
          });
        }
      }
    });
  }

  void sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final senderName = currentUser.displayName ?? "Me";

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .add({
      'senderUid': currentUser.uid,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  void editMessage(String messageId, String currentText) {
    final TextEditingController editController =
        TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "Edit your message",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                final newText = editController.text.trim();
                if (newText.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatDocId)
                      .collection('messages')
                      .doc(messageId)
                      .update({
                    'text': newText,
                    'editedAt': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  void deleteAllMessages() async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .get();

    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All messages deleted")),
    );
  }

  void deleteFriend() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .doc(widget.friendUid)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.friendUid)
        .collection('friends')
        .doc(currentUser.uid)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Friend removed")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 134, 201),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Delete all chat",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Chat"),
                  content:
                      const Text("Are you sure you want to delete all messages?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          deleteAllMessages();
                          Navigator.pop(ctx);
                        },
                        child: const Text("Delete")),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_remove),
            tooltip: "Remove friend",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Remove Friend"),
                  content: const Text(
                      "Are you sure you want to remove this friend?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          deleteFriend();
                          Navigator.pop(ctx);
                        },
                        child: const Text("Remove")),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatDocId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final msgData = msg.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onLongPress: () {
                            if (msgData['senderUid'] == currentUser.uid) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Message Management"),
                                  content: const Text(
                                      "Do you want to delete or edit this message?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Cancel")),
                                    TextButton(
                                        onPressed: () {
                                          deleteMessage(msg.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text("Delete")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          editMessage(msg.id, msgData['text']);
                                        },
                                        child: const Text("Edit")),
                                  ],
                                ),
                              );
                            }
                          },
                          child: MessageBubble(
                            message: msgData,
                            currentUser: currentUser,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Input field
              Material(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : const Color.fromARGB(255, 224, 224, 224),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[850]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            cursorColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                              isDense: true, // reduces vertical space
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xff6c5ce7),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showScrollToBottom)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xff6c5ce7),
                onPressed: scrollToBottom,
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
