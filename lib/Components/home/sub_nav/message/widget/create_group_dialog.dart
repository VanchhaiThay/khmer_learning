import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _friendsScrollController = ScrollController(); // added
  final currentUser = FirebaseAuth.instance.currentUser!;
  final List<String> selectedFriends = [];
  String searchQuery = "";

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    _friendsScrollController.dispose(); // dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final buttonColor = const Color(0xff6c5ce7);

    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Create Group",
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Group name input
              TextField(
                controller: _groupNameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Group Name",
                  labelStyle: TextStyle(color: subTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: subTextColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              
              const SizedBox(height: 20),
              // Divider line
              Divider(
                color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                thickness: 1,
                height: 0,
              ),
              const SizedBox(height: 10),

              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search friends",
                  hintStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Friend list
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('friends')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final friends = snapshot.data!.docs.where((doc) {
                    final firstName = doc['firstName'] ?? '';
                    final lastName = doc['lastName'] ?? '';
                    final fullName = "$firstName $lastName".toLowerCase();
                    return fullName.contains(searchQuery);
                  }).toList();

                  if (friends.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No friends found.",
                        style: TextStyle(color: subTextColor),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 200, // fixed height for scrollable friend list
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _friendsScrollController, // attach controller
                      radius: const Radius.circular(12),
                      child: ListView(
                        controller: _friendsScrollController, // attach controller
                        children: friends.map((doc) {
                          final uid = doc['uid'];
                          final firstName = doc['firstName'] ?? '';
                          final lastName = doc['lastName'] ?? '';
                          final name = "$firstName $lastName";

                          final photoUrl =
                              "https://api.dicebear.com/7.x/fun-emoji/png?seed=$uid";

                          return CheckboxListTile(
                            checkColor: Colors.white,
                            activeColor: buttonColor,
                            value: selectedFriends.contains(uid),
                            onChanged: (value) {
                              setState(() {
                                if (value ?? false) {
                                  selectedFriends.add(uid);
                                } else {
                                  selectedFriends.remove(uid);
                                }
                              });
                            },
                            title: Text(name, style: TextStyle(color: textColor)),
                            secondary: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(photoUrl),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel", style: TextStyle(color: subTextColor)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Create"),
          onPressed: _createGroup,
        ),
      ],
    );
  }

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) return;

    await FirebaseFirestore.instance.collection('groups').add({
      'name': groupName,
      'members': [currentUser.uid, ...selectedFriends],
      'createdBy': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }
}
