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
  final currentUser = FirebaseAuth.instance.currentUser!;
  final List<String> selectedFriends = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Group"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('friends')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Expanded(
                  child: ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final uid = doc['uid'];
                      final name =
                          "${doc['firstName']} ${doc['lastName']}";

                      return CheckboxListTile(
                        value: selectedFriends.contains(uid),
                        title: Text(name),
                        onChanged: (value) {
                          setState(() {
                            value!
                                ? selectedFriends.add(uid)
                                : selectedFriends.remove(uid);
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Create"),
          onPressed: _createGroup,
        ),
      ],
    );
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('groups').add({
      'name': _groupNameController.text.trim(),
      'members': [currentUser.uid, ...selectedFriends],
      'createdBy': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }
}
