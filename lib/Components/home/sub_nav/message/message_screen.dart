import 'package:async/async.dart';
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
  String searchQuery = "";

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (_) => AddFriendDialog(currentUser: currentUser),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(context: context, builder: (_) => const CreateGroupDialog());
  }

  void _openChat(String friendUid, String friendName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(friendUid: friendUid, friendName: friendName),
      ),
    );
  }

  void _openGroupChat(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(groupId: groupId, groupName: groupName),
      ),
    );
  }

  String getChatId(String user1, String user2) {
    final uids = [user1, user2]..sort();
    return uids.join('_');
  }

  Stream<List<Map<String, dynamic>>> combinedChatStream(String userId) async* {
    final friendStream =
        FirebaseFirestore.instance.collection('users').doc(userId).collection('friends').snapshots();
    final groupStream =
        FirebaseFirestore.instance.collection('groups').where('members', arrayContains: userId).snapshots();

    await for (final combined in StreamZip([friendStream, groupStream])) {
      final friendDocs = combined[0].docs;
      final groupDocs = combined[1].docs;

      List<Map<String, dynamic>> allChats = [];

      // Groups
      for (var group in groupDocs) {
        final msgStream = FirebaseFirestore.instance
            .collection('groups')
            .doc(group.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots();

        final msgSnapshot = await msgStream.first;
        Timestamp? lastTime;
        String lastText = "No messages yet";

        if (msgSnapshot.docs.isNotEmpty) {
          lastText = msgSnapshot.docs.first['text'] ?? '';
          lastTime = msgSnapshot.docs.first['timestamp'] as Timestamp?;
        }

        allChats.add({
          'type': 'group',
          'id': group.id,
          'name': group['name'],
          'lastMessage': lastText,
          'timestamp': lastTime ?? Timestamp.fromDate(DateTime(2000)),
        });
      }

      // Friends
      for (var friend in friendDocs) {
        final friendUid = friend['uid'];
        final friendName = "${friend['firstName']} ${friend['lastName']}";

        final msgStream = FirebaseFirestore.instance
            .collection('chats')
            .doc(getChatId(userId, friendUid))
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots();

        final msgSnapshot = await msgStream.first;
        Timestamp? lastTime;
        String lastText = "Tap to chat";

        if (msgSnapshot.docs.isNotEmpty) {
          lastText = msgSnapshot.docs.first['text'] ?? '';
          lastTime = msgSnapshot.docs.first['timestamp'] as Timestamp?;
        }

        allChats.add({
          'type': 'friend',
          'id': friendUid,
          'name': friendName,
          'lastMessage': lastText,
          'timestamp': lastTime ?? Timestamp.fromDate(DateTime(2000)),
        });
      }

      allChats.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        allChats = allChats
            .where((chat) => chat['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      yield allChats;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUser.uid;
    final userName = currentUser.displayName ?? "Student";
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? Colors.black : const Color(0xfff0f2f5);
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final searchBackground = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final searchTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff6c5ce7),
        title: const Text("Messages"),
        centerTitle: true,
        elevation: 4,
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
                        "https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId"),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SelectableText(
                          userId,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: userId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("UID copied to clipboard")),
                          );
                        },
                      )
                    ],
                  ),
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
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
// Place this inside the body Column above the Expanded ListView
Padding(
  padding: const EdgeInsets.all(12.0),
  child: Container(
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        if (!isDarkMode)
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
      ],
    ),
    child: TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: "Search friends or groups",
        hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  ),
),

          // Chat List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: combinedChatStream(userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data!;
                if (chats.isEmpty) {
                  return Center(
                    child: Text(
                      "No chats yet",
                      style: TextStyle(color: subTextColor, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return Card(
                      color: cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(
                            chat['type'] == 'friend'
                                ? "https://api.dicebear.com/7.x/fun-emoji/png?seed=${chat['id']}"
                                : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(chat['name'])}&background=6c5ce7&color=fff&size=128",
                          ),
                        ),
                        title: Text(chat['name'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text(chat['lastMessage'], style: TextStyle(color: subTextColor)),
                        trailing: chat['type'] == 'friend'
                            ? const Icon(Icons.chat, color: Color(0xff6c5ce7))
                            : null,
                        onTap: () {
                          if (chat['type'] == 'friend') {
                            _openChat(chat['id'], chat['name']);
                          } else {
                            _openGroupChat(chat['id'], chat['name']);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
