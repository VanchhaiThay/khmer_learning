import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'widget/add_friend_dialog.dart';
import 'widget/chat_screen.dart';
import 'widget/create_group_dialog.dart';
import 'widget/group_chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (_) => AddFriendDialog(currentUser: currentUser),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (_) => const CreateGroupDialog(),
    );
  }

  void _openChat(String friendUid, String friendName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(friendUid: friendUid, friendName: friendName),
      ),
    );
  }

  void _openGroupChat(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GroupChatScreen(groupId: groupId, groupName: groupName),
      ),
    );
  }

  /// Helper for chat ID (consistent for private chats)
  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '$user1\_$user2'
        : '$user2\_$user1';
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUser.uid;
    final userName = currentUser.displayName ?? "Student";
    final email = currentUser.email ?? "No email";

    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        backgroundColor: const Color(0xff6c5ce7),
        title: const Text("Messages"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xff6c5ce7)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      "https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(email,
                      style: const TextStyle(color: Colors.white70)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectableText(
                        userId,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            size: 18, color: Colors.white70),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: userId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("UID copied to clipboard")),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Add Friend"),
              onTap: () {
                Navigator.pop(context);
                _showAddFriendDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text("Create Group"),
              onTap: () {
                Navigator.pop(context);
                _showCreateGroupDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              },
            ),
          ],
        ),
      ),

      /// BODY
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          /// ===== GROUPS =====
          const Text("Groups",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .where('members', arrayContains: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("No groups"),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((group) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('group_chats')
                        .doc(group.id)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      String lastMessage = "";
                      if (messageSnapshot.hasData &&
                          messageSnapshot.data!.docs.isNotEmpty) {
                        lastMessage =
                            messageSnapshot.data!.docs.first['text'] ?? '';
                      }

                      return Card(
                        child: ListTile(
                          leading:
                              const CircleAvatar(child: Icon(Icons.group)),
                          title: Text(group['name']),
                          subtitle: Text(
                              lastMessage.isNotEmpty ? lastMessage : "Group chat"),
                          onTap: () =>
                              _openGroupChat(group.id, group['name']),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          /// ===== FRIENDS =====
          const Text("Friends",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('friends')
                .orderBy('addedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("No friends yet"),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((friend) {
                  final friendUid = friend['uid'];
                  final friendName =
                      "${friend['firstName']} ${friend['lastName']}";

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(getChatId(userId, friendUid))
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, chatSnapshot) {
                      String lastMessage = "";
                      if (chatSnapshot.hasData &&
                          chatSnapshot.data!.docs.isNotEmpty) {
                        lastMessage =
                            chatSnapshot.data!.docs.first['text'] ?? '';
                      }

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              "https://api.dicebear.com/7.x/fun-emoji/png?seed=$friendUid",
                            ),
                          ),
                          title: Text(friendName),
                          subtitle: Text(
                              lastMessage.isNotEmpty ? lastMessage : "Tap to chat"),
                          trailing: const Icon(Icons.chat,
                              color: Color(0xff6c5ce7)),
                          onTap: () => _openChat(friendUid, friendName),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
