import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final ScrollController _scrollController = ScrollController();
  bool showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - 100) {
        if (!showScrollToBottom) setState(() => showScrollToBottom = true);
      } else {
        if (showScrollToBottom) setState(() => showScrollToBottom = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ------------------- MESSAGE FUNCTIONS -------------------
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<Map<String, String>> _getUserInfo(String uid) async {
    if (uid == currentUser.uid) {
      return {'name': currentUser.displayName ?? "Me", 'avatar': ""};
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final first = data['first_name'] ?? '';
        final last = data['last_name'] ?? '';
        return {
          'name': "$first $last".trim().isNotEmpty ? "$first $last" : "Unknown",
          'avatar': "https://api.dicebear.com/7.x/fun-emoji/png?seed=$uid",
        };
      }
    } catch (_) {}
    return {'name': 'Unknown', 'avatar': "https://api.dicebear.com/7.x/fun-emoji/png?seed=unknown"};
  }

  void _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  void _editMessage(String messageId, String currentText) {
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                final newText = editController.text.trim();
                if (newText.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
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

  void _deleteAllMessages() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("All messages deleted")));
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    return DateFormat('hh:mm a').format(date);
  }

  // ------------------- GROUP MEMBERS -------------------
  Future<void> _showGroupMembers() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (!groupDoc.exists) return;

      final members = List<String>.from(groupDoc['members'] ?? []);

      final memberData = await Future.wait(members.map((uid) async {
        if (uid == currentUser.uid) {
          return {'uid': uid, 'name': currentUser.displayName ?? "Me", 'avatar': ""};
        }
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data();
        final first = data?['first_name'] ?? '';
        final last = data?['last_name'] ?? '';
        return {
          'uid': uid,
          'name': "$first $last".trim().isNotEmpty ? "$first $last" : "Unknown",
          'avatar': "https://api.dicebear.com/7.x/fun-emoji/png?seed=$uid",
        };
      }));

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Group Members"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: memberData.length,
              itemBuilder: (context, index) {
                final member = memberData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (member['avatar'] ?? '').isNotEmpty
                        ? NetworkImage(member['avatar']!)
                        : null,
                    child: (member['avatar'] ?? '').isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(member['name'] ?? 'Unknown'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close")),
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _addGroupMembers();
                },
                child: const Text("Add Members")),
          ],
        ),
      );
    } catch (e) {
      print("Error fetching members: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load group members")),
      );
    }
  }

  Future<void> _addGroupMembers() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();
      final currentMembers = List<String>.from(groupDoc['members'] ?? []);

      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final allUsers = usersSnapshot.docs
          .where((doc) => !currentMembers.contains(doc.id))
          .map((doc) {
        final data = doc.data();
        final first = data['first_name'] ?? '';
        final last = data['last_name'] ?? '';
        return {
          'uid': doc.id,
          'name': "$first $last".trim().isNotEmpty ? "$first $last" : "Unknown",
          'avatar': "https://api.dicebear.com/7.x/fun-emoji/png?seed=${doc.id}",
        };
      }).toList();

      List<String> selectedUids = [];

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text("Add Members"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  final user = allUsers[index];
                  final isSelected = selectedUids.contains(user['uid']);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['avatar']!),
                    ),
                    title: Text(user['name']!),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          final uid = user['uid']!;
                          if (val == true) {
                            selectedUids.add(uid);
                          } else {
                            selectedUids.remove(uid);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              TextButton(
                onPressed: () async {
                  if (selectedUids.isNotEmpty) {
                    // 1. Update group members
                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .update({
                      'members': FieldValue.arrayUnion(selectedUids),
                    });

                    // 2. Add system message for each new member
                    for (var uid in selectedUids) {
                      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                      final userData = userDoc.data();
                      final first = userData?['first_name'] ?? '';
                      final last = userData?['last_name'] ?? '';
                      final fullName = "$first $last".trim().isNotEmpty ? "$first $last" : "Unknown";

                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(widget.groupId)
                          .collection('messages')
                          .add({
                        'text': "$fullName has been added by ${currentUser.displayName ?? "Me"}",
                        'senderId': 'system',
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    }
                  }

                  Navigator.pop(ctx);
                  if (selectedUids.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${selectedUids.length} member(s) added")),
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print("Error adding members: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add members")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showGroupMembers,
          child: Row(
            children: [
              Text(widget.groupName),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 18),
            ],
          ),
        ),
        backgroundColor: primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Delete all messages",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete All Messages"),
                  content: const Text("Are you sure you want to delete all messages?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          _deleteAllMessages();
                          Navigator.pop(ctx);
                        },
                        child: const Text("Delete All")),
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
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final msgData = msg.data() as Map<String, dynamic>;

                        // Check for system message
                        final isSystemMessage = msgData['senderId'] == 'system';
                        if (isSystemMessage) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msgData['text'],
                                  style: const TextStyle(
                                      fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                                ),
                              ),
                            ),
                          );
                        }

                        final isMe = msgData['senderId'] == currentUser.uid;

                        return FutureBuilder<Map<String, String>>(
                          future: _getUserInfo(msgData['senderId']),
                          builder: (context, userSnapshot) {
                            final name = userSnapshot.data?['name'] ?? 'Unknown';
                            final avatar = userSnapshot.data?['avatar'] ?? "";

                            final bubbleColor = isMe
                                ? primary
                                : (isDark ? Colors.grey[800] : Colors.grey[300]);
                            final textColor =
                                isMe ? Colors.white : theme.textTheme.bodyMedium!.color!;

                            return GestureDetector(
                              onLongPress: isMe
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Message Management"),
                                          content: const Text(
                                              "Do you want to edit or delete this message?"),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text("Cancel")),
                                            TextButton(
                                                onPressed: () {
                                                  _deleteMessage(msg.id);
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text("Delete")),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  _editMessage(msg.id, msgData['text']);
                                                },
                                                child: const Text("Edit")),
                                          ],
                                        ),
                                      );
                                    }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundImage: avatar.isNotEmpty
                                              ? NetworkImage(avatar)
                                              : null,
                                          child: avatar.isEmpty ? const Icon(Icons.person) : null,
                                        ),
                                      ),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: bubbleColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                                            bottomRight: Radius.circular(isMe ? 0 : 16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark ? Colors.black54 : Colors.black26,
                                              blurRadius: 3,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (!isMe)
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor.withOpacity(0.8),
                                                ),
                                              ),
                                            if (!isMe) const SizedBox(height: 4),
                                            Text(
                                              msgData['text'],
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              msgData['editedAt'] != null
                                                  ? "Edited: ${_formatTimestamp(msgData['editedAt'])}"
                                                  : _formatTimestamp(msgData['timestamp']),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: textColor.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // MESSAGE INPUT
              Material(
                color: theme.scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _messageController,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            cursorColor: primary,
                            decoration: const InputDecoration(
                              hintText: "Type a message…",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: primary,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
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
                backgroundColor: primary,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
