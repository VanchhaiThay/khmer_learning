import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _showAddFriendDialog() {
    final uidController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add Friend",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: uidController,
                    decoration: const InputDecoration(
                      labelText: "Friend's UID",
                      prefixIcon: Icon(Icons.fingerprint),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final friendUid = uidController.text.trim();
                          if (friendUid.isEmpty) return;
                          if (friendUid == currentUser.uid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("You cannot add yourself"),
                              ),
                            );
                            return;
                          }

                          final friendDoc =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(friendUid)
                                  .get();
                          if (!friendDoc.exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User UID not found"),
                              ),
                            );
                            return;
                          }

                          final friendData = friendDoc.data()!;
                          final firstName = friendData['first_name'] ?? '';
                          final lastName = friendData['last_name'] ?? '';

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('friends')
                              .doc(friendUid)
                              .set({
                                'uid': friendUid,
                                'firstName': firstName,
                                'lastName': lastName,
                                'addedAt': FieldValue.serverTimestamp(),
                              });

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(friendUid)
                              .collection('friends')
                              .doc(currentUser.uid)
                              .set({
                                'uid': currentUser.uid,
                                'firstName':
                                    currentUser.displayName?.split(' ').first ??
                                    '',
                                'lastName':
                                    currentUser.displayName?.split(' ').last ??
                                    '',
                                'addedAt': FieldValue.serverTimestamp(),
                              });

                          final chatIdList = [currentUser.uid, friendUid]
                            ..sort();
                          final chatDocId = chatIdList.join('_');
                          final chatDocRef = FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatDocId);
                          if (!(await chatDocRef.get()).exists) {
                            await chatDocRef.set({'users': chatIdList});
                          }

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Friend added successfully"),
                            ),
                          );
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _openChat(String friendUid, String friendName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(friendUid: friendUid, friendName: friendName),
      ),
    );
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
              decoration: BoxDecoration(color: const Color(0xff6c5ce7)),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        "https://api.dicebear.com/7.x/fun-emoji/png?seed=$userId",
                      ),
                    ),
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: SelectableText(
                            userId,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            showCursor: false,
                            toolbarOptions: const ToolbarOptions(
                              copy: true,
                              selectAll: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white70,
                            size: 18,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('UID copied to clipboard'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
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
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('friends')
                .orderBy('addedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final friends = snapshot.data!.docs;
          if (friends.isEmpty)
            return const Center(child: Text("No friends. Add some!"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final friendName = "${friend['firstName']} ${friend['lastName']}";
              final friendUid = friend['uid'];

              final chatIdList = [userId, friendUid]..sort();
              final chatDocId = chatIdList.join('_');

              return FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatDocId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .get(),
                builder: (context, chatSnapshot) {
                  String lastMessage = "";
                  if (chatSnapshot.hasData &&
                      chatSnapshot.data!.docs.isNotEmpty) {
                    lastMessage = chatSnapshot.data!.docs.first['text'];
                  }

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://api.dicebear.com/7.x/fun-emoji/png?seed=$friendUid",
                        ),
                      ),
                      title: Text(
                        friendName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        lastMessage.isEmpty ? "No messages yet" : lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.chat,
                        color: Color(0xff6c5ce7),
                      ),
                      onTap: () => _openChat(friendUid, friendName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    final uids = [currentUser.uid, widget.friendUid]..sort();
    chatDocId = uids.join('_');
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .add({
          'senderUid': currentUser.uid,
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

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['senderUid'] == currentUser.uid;
    final bgColor = isMe ? Colors.deepPurpleAccent : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black87;

    Timestamp? timestamp = msg['timestamp'];
    String time = "";
    if (timestamp != null) {
      final dt = timestamp.toDate();
      time =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

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
                  "https://api.dicebear.com/7.x/fun-emoji/png?seed=${msg['senderUid']}",
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg['text'],
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.friendName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 134, 201),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatDocId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final messages =
                    snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder:
                      (context, index) => _buildMessage(messages[index]),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color.fromARGB(255, 224, 224, 224),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
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
        ],
      ),
    );
  }
}
